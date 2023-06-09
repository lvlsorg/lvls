// SPDX-License-Identifier: CC0-1.0
/**
 * @title LSP7DigitalAsset contract
 * @author Matthew Stevens, Modified by Zane Starr as a Facet
 * @dev Core Implementation of a LSP7 compliant contract.
 *
 * This contract implement the core logic of the functions for the {ILSP7DigitalAsset} interface.
 */
pragma solidity ^0.8.15;

// interfaces
import {ILSP1UniversalReceiver} from "../interfaces/ILSP1UniversalReceiver.sol";
import {ILSP7DigitalAsset} from "../interfaces/ILSP7DigitalAsset.sol";
import {IERC725Y} from "@erc725/smart-contracts/contracts/ERC725YCore.sol";

// libraries
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

// errors
import "../libraries/LSP7Errors.sol";
import "../libraries/LSP4Constants.sol";
import "../libraries/LSP4Errors.sol";
import {BytesLib} from "solidity-bytes-utils/contracts/BytesLib.sol";

import {LibLSP7, LibLSP7Storage} from "../libraries/LibLSP7Storage.sol";
import {LibOwnership} from "../libraries/LibOwnership.sol";

// constants
import {_INTERFACEID_LSP1} from "../libraries/LSP1Constants.sol";
import {_TYPEID_LSP7_TOKENSSENDER, _TYPEID_LSP7_TOKENSRECIPIENT} from "../libraries/LSP7Constants.sol";
import "hardhat/console.sol";

// TODO make this erc20 compatible
contract LSP7DigitalAssetFacet is ILSP7DigitalAsset {
    // --- Token queries
    constructor() {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        ds._isNonDivisible = false;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ILSP7DigitalAsset).interfaceId;
    }

    /**
     * @inheritdoc ILSP7DigitalAsset
     */
    function decimals() public view returns (uint8) {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        return ds._isNonDivisible ? 0 : 18;
    }

    /**
     * @inheritdoc ILSP7DigitalAsset
     */
    function totalSupply() public view virtual returns (uint256) {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        return ds._existingTokens;
    }

    // --- Token owner queries

    /**
     * @inheritdoc ILSP7DigitalAsset
     */
    function balanceOf(address tokenOwner) public view virtual returns (uint256) {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        return ds._tokenOwnerBalances[tokenOwner];
    }

    // --- Operator functionality

    /**
     * @inheritdoc ILSP7DigitalAsset
     *
     * @dev To avoid front-running and Allowance Double-Spend Exploit when
     * increasing or decreasing the authorized amount of an operator,
     * it is advised to:
     *     1. call {revokeOperator} first, and
     *     2. then re-call {authorizeOperator} with the new amount
     *
     * for more information, see:
     * https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/
     *
     */
    function authorizeOperator(address operator, uint256 amount) public virtual {
        _updateOperator(msg.sender, operator, amount);
    }

    /**
     * @inheritdoc ILSP7DigitalAsset
     */
    function revokeOperator(address operator) public virtual {
        _updateOperator(msg.sender, operator, 0);
    }

    /**
     * @inheritdoc ILSP7DigitalAsset
     */
    function authorizedAmountFor(address operator, address tokenOwner) public view virtual returns (uint256) {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        if (tokenOwner == operator) {
            return ds._tokenOwnerBalances[tokenOwner];
        } else {
            return ds._operatorAuthorizedAmount[tokenOwner][operator];
        }
    }

    // --- Transfer functionality

    /**
     * @inheritdoc ILSP7DigitalAsset
     */
    function transfer(address from, address to, uint256 amount, bool allowNonLSP1Recipient, bytes memory data) public virtual {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        if (from == to) revert LSP7CannotSendToSelf();

        address operator = msg.sender;
        if (operator != from) {
            uint256 operatorAmount = ds._operatorAuthorizedAmount[from][operator];
            if (amount > operatorAmount) {
                revert LSP7AmountExceedsAuthorizedAmount(from, operatorAmount, operator, amount);
            }

            _updateOperator(from, operator, operatorAmount - amount);
        }

        _transfer(from, to, amount, allowNonLSP1Recipient, data);
    }

    /**
     * @inheritdoc ILSP7DigitalAsset
     */
    function transferBatch(
        address[] memory from,
        address[] memory to,
        uint256[] memory amount,
        bool[] memory allowNonLSP1Recipient,
        bytes[] memory data
    ) public virtual {
        uint256 fromLength = from.length;
        if (fromLength != to.length || fromLength != amount.length || fromLength != allowNonLSP1Recipient.length || fromLength != data.length) {
            revert LSP7InvalidTransferBatch();
        }

        for (uint256 i = 0; i < fromLength; ) {
            // using the public transfer function to handle updates to operator authorized amounts
            transfer(from[i], to[i], amount[i], allowNonLSP1Recipient[i], data[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Changes token `amount` the `operator` has access to from `tokenOwner` tokens. If the
     * amount is zero then the operator is being revoked, otherwise the operator amount is being
     * modified.
     *
     * See {authorizedAmountFor}.
     *
     * Emits either {AuthorizedOperator} or {RevokedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be the zero address.
     */
    function _updateOperator(address tokenOwner, address operator, uint256 amount) internal virtual {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        if (operator == address(0)) {
            revert LSP7CannotUseAddressZeroAsOperator();
        }

        if (operator == tokenOwner) {
            revert LSP7TokenOwnerCannotBeOperator();
        }

        ds._operatorAuthorizedAmount[tokenOwner][operator] = amount;

        if (amount != 0) {
            emit AuthorizedOperator(operator, tokenOwner, amount);
        } else {
            emit RevokedOperator(operator, tokenOwner);
        }
    }

    /**
     * @dev Mints `amount` tokens and transfers it to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 amount, bool allowNonLSP1Recipient, bytes memory data) internal virtual {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        console.log("minting");
        console.logAddress(to);
        console.log(amount);
        if (to == address(0)) {
            revert LSP7CannotSendWithAddressZero();
        }

        address operator = msg.sender;
        console.log("before");
        _beforeTokenTransfer(address(0), to, amount);
        console.log("before - after");

        // tokens being minted
        ds._existingTokens += amount;

        ds._tokenOwnerBalances[to] += amount;

        emit Transfer(operator, address(0), to, amount, allowNonLSP1Recipient, data);

        console.log("encode data");
        bytes memory lsp1Data = abi.encodePacked(address(0), to, amount, data);
        console.log("encode data - after");
        _notifyTokenReceiver(to, allowNonLSP1Recipient, lsp1Data);
        console.log("receiver after");
    }

    /**
     * @dev Destroys `amount` tokens.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens.
     * - If the caller is not `from`, it must be an operator for `from` with access to at least
     * `amount` tokens.
     *
     * Emits a {Transfer} event.
     */
    function _burn(address from, uint256 amount, bytes memory data) internal virtual {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        if (from == address(0)) {
            revert LSP7CannotSendWithAddressZero();
        }

        uint256 balance = ds._tokenOwnerBalances[from];
        if (amount > balance) {
            revert LSP7AmountExceedsBalance(balance, from, amount);
        }

        address operator = msg.sender;
        if (operator != from) {
            uint256 authorizedAmount = ds._operatorAuthorizedAmount[from][operator];
            if (amount > authorizedAmount) {
                revert LSP7AmountExceedsAuthorizedAmount(from, authorizedAmount, operator, amount);
            }
            ds._operatorAuthorizedAmount[from][operator] -= amount;
        }

        _beforeTokenTransfer(from, address(0), amount);

        // tokens being burned
        ds._existingTokens -= amount;

        ds._tokenOwnerBalances[from] -= amount;

        emit Transfer(operator, from, address(0), amount, false, data);

        bytes memory lsp1Data = abi.encodePacked(from, address(0), amount, data);
        _notifyTokenSender(from, lsp1Data);
    }

    /**
     * @dev Transfers `amount` tokens from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens.
     * - If the caller is not `from`, it must be an operator for `from` with access to at least
     * `amount` tokens.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 amount, bool allowNonLSP1Recipient, bytes memory data) internal virtual {
        LibLSP7Storage storage ds = LibLSP7.libLSP7Storage();
        if (from == address(0) || to == address(0)) {
            revert LSP7CannotSendWithAddressZero();
        }

        uint256 balance = ds._tokenOwnerBalances[from];
        if (amount > balance) {
            revert LSP7AmountExceedsBalance(balance, from, amount);
        }

        address operator = msg.sender;

        _beforeTokenTransfer(from, to, amount);

        ds._tokenOwnerBalances[from] -= amount;
        ds._tokenOwnerBalances[to] += amount;

        emit Transfer(operator, from, to, amount, allowNonLSP1Recipient, data);

        bytes memory lsp1Data = abi.encodePacked(from, to, amount, data);

        _notifyTokenSender(from, lsp1Data);
        _notifyTokenReceiver(to, allowNonLSP1Recipient, lsp1Data);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `amount` tokens will be
     * transferred to `to`.
     * - When `from` is zero, `amount` tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s `amount` tokens will be burned.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev An attempt is made to notify the token sender about the `amount` tokens changing owners using
     * LSP1 interface.
     */
    function _notifyTokenSender(address from, bytes memory lsp1Data) internal virtual {
        if (ERC165Checker.supportsERC165InterfaceUnchecked(from, _INTERFACEID_LSP1)) {
            ILSP1UniversalReceiver(from).universalReceiver(_TYPEID_LSP7_TOKENSSENDER, lsp1Data);
        }
    }

    /**
     * @dev An attempt is made to notify the token receiver about the `amount` tokens changing owners
     * using LSP1 interface. When allowNonLSP1Recipient is FALSE the token receiver MUST support LSP1.
     *
     * The receiver may revert when the token being sent is not wanted.
     */
    function _notifyTokenReceiver(address to, bool allowNonLSP1Recipient, bytes memory lsp1Data) internal virtual {
        if (ERC165Checker.supportsERC165InterfaceUnchecked(to, _INTERFACEID_LSP1)) {
            ILSP1UniversalReceiver(to).universalReceiver(_TYPEID_LSP7_TOKENSRECIPIENT, lsp1Data);
        } else if (!allowNonLSP1Recipient) {
            if (to.code.length > 0) {
                revert LSP7NotifyTokenReceiverContractMissingLSP1Interface(to);
            } else {
                revert LSP7NotifyTokenReceiverIsEOA(to);
            }
        }
    }

    /**
     * @dev The ERC725Y data keys `LSP4TokenName` and `LSP4TokenSymbol` cannot be changed
     *      via this function once the digital asset contract has been deployed.
     *
     * @dev SAVE GAS by emitting the DataChanged event with only the first 256 bytes of dataValue
     */
    function _setData(bytes32 dataKey, bytes memory dataValue) internal virtual {
        if (dataKey == _LSP4_TOKEN_NAME_KEY) {
            revert LSP4TokenNameNotEditable();
        } else if (dataKey == _LSP4_TOKEN_SYMBOL_KEY) {
            revert LSP4TokenSymbolNotEditable();
        } else {
            IERC725Y(address(this)).setData(dataKey, dataValue);
        }
    }

    function mint(address to, uint256 amount, bool allowNonLSP1Recipient, bytes memory data) public virtual onlyOwner {
        _mint(to, amount, allowNonLSP1Recipient, data);
    }

    function burn(address from, uint256 amount, bytes memory data) public virtual {
        _burn(from, amount, data);
    }

    modifier onlyOwner() {
        LibOwnership.OwnershipStorage storage ds = LibOwnership.diamondStorage();
        require(ds.contractOwner == _msgSender(), "only owner");
        _;
    }

    function _msgSender() internal view returns (address sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }
}
