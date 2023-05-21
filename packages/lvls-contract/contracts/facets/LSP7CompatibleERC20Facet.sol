// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// interfaces
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ILSP7CompatibleERC20} from "../interfaces/ILSP7CompatibleERC20.sol";

// modules
import {ILSP4Compatibility} from "../interfaces/ILSP4Compatibility.sol";
import {IERC725Y} from "@erc725/smart-contracts/contracts/interfaces/IERC725Y.sol";
import {LSP7DigitalAssetFacet} from "./LSP7DigitalAssetFacet.sol";
import "../libraries/LSP4Constants.sol";

/**
 * @dev LSP7 extension, for compatibility for clients / tools that expect ERC20.
 */
contract LSP7CompatibleERC20Facet is LSP7DigitalAssetFacet, ILSP4Compatibility, ILSP7CompatibleERC20 {
    /**
     * @dev Returns the name of the token.
     * @return The name of the token
     */
    function name() public view virtual override returns (string memory) {
        return string(IERC725Y(address(this)).getData(_LSP4_TOKEN_NAME_KEY));
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the name.
     * @return The symbol of the token
     */
    function symbol() public view virtual override returns (string memory) {
        return string(IERC725Y(address(this)).getData(_LSP4_TOKEN_SYMBOL_KEY));
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(LSP7DigitalAssetFacet, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc ILSP7CompatibleERC20
     */
    function allowance(address tokenOwner, address operator) public view virtual returns (uint256) {
        return authorizedAmountFor(operator, tokenOwner);
    }

    /**
     * @inheritdoc ILSP7CompatibleERC20
     */
    function approve(address operator, uint256 amount) public virtual returns (bool) {
        authorizeOperator(operator, amount);
        return true;
    }

    /**
     * @inheritdoc ILSP7CompatibleERC20
     * @dev Compatible with ERC20 transferFrom.
     * Using allowNonLSP1Recipient=true so that EOA and any contract may receive the tokens.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        transfer(from, to, amount, true, "");
        return true;
    }

    // --- Overrides

    /**
     * @inheritdoc ILSP7CompatibleERC20
     * @dev Compatible with ERC20 transfer.
     * Using allowNonLSP1Recipient=true so that EOA and any contract may receive the tokens.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        transfer(msg.sender, to, amount, true, "");
        return true;
    }

    /**
     * @dev same behaviour as LSP7DigitalAssetCore
     * with the addition of emitting ERC20 Approval event.
     */
    function _updateOperator(address tokenOwner, address operator, uint256 amount) internal virtual override {
        super._updateOperator(tokenOwner, operator, amount);
        emit Approval(tokenOwner, operator, amount);
    }

    function _transfer(address from, address to, uint256 amount, bool allowNonLSP1Recipient, bytes memory data) internal virtual override {
        super._transfer(from, to, amount, allowNonLSP1Recipient, data);
        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount, bool allowNonLSP1Recipient, bytes memory data) internal virtual override {
        super._mint(to, amount, allowNonLSP1Recipient, data);
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount, bytes memory data) internal virtual override {
        super._burn(from, amount, data);
        emit Transfer(from, address(0), amount);
    }

    function _setData(bytes32 key, bytes memory value) internal virtual override {
        super._setData(key, value);
    }
}
