// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {LSP7DigitalAsset} from "@lukso/lsp-smart-contracts/contracts/LSP7DigitalAsset/LSP7DigitalAsset.sol";
import {LibXP} from "../libraries/LibXP.sol";
import "../libraries/LSP7Errors.sol";
import {ILSP7XP} from "../interfaces/ILSP7XP.sol";
import {LibOwnership} from "../libraries/LibOwnership.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XPLSP7Token is LSP7DigitalAsset {
    constructor(
        string memory name_,
        string memory symbol_,
        address newOwner_,
        bool isNonDivisible_
    ) LSP7DigitalAsset(name_, symbol_, newOwner_, isNonDivisible_) {}

    function _msgSender() internal view returns (address sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
            if (address(sender) == address(0)) {
                sender = msg.sender;
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }

    /*
    modifier onlyOwner() override {
        LibOwnership.OwnershipStorage storage ds = LibOwnership.diamondStorage();
        require(ds.contractOwner == _msgSender(), "only owner");
        _;
    }*/

    function mint(address to, uint256 amount, bool allowNonLSP1Recipient, bytes memory data) public virtual onlyOwner {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        // EOA account descrepancy
        _mint(to, amount, allowNonLSP1Recipient, data);
        console.log("minting complete");
        xps._balances[to].activeVirtualBalance += amount;
        // TODO: this is redundant as decay will set the block number to the current block
        // do this to make the hook apparent and more readable
        xps._balances[to].lastDecayBlock = block.number;
        updateHolders(to);
        console.log("updated holders");
    }

    function burn(address account, uint256 amount, bytes memory data) public {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        // EOA account descrepancy

        if (xps._balances[account].inactiveVirtualBalance > amount) {
            xps._balances[account].inactiveVirtualBalance -= amount;
        } else {
            // This will overflow and fail if the amount is too large TODO add better
            // signal
            xps._balances[account].inactiveVirtualBalance = 0;
            xps._balances[account].activeVirtualBalance -= amount - xps._balances[account].inactiveVirtualBalance;
        }

        xps._balances[account].lastDecayBlock = block.number;
        _burn(account, amount, "");
        updateHolders(account);
    }

    function decay(address account) internal {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        // when you initialize the contract, the last decay block is 0
        // so we need to set it to the current block number or just
        // return
        if (account == address(0)) {
            return;
        }

        if (xps._balances[account].lastDecayBlock == 0) {
            xps._balances[account].lastDecayBlock = block.number;
            return;
        }
        uint256 decayBlocks = block.number - xps._balances[account].lastDecayBlock;
        uint256 decayAmount = xps._decayRate * decayBlocks;
        console.log("decay amoutn", decayAmount);
        console.log("decay blocks", decayBlocks);
        console.log("decay rate", xps._decayRate);
        console.log("last decay block", xps._balances[account].lastDecayBlock);
        console.log("current block", block.number);
        console.log("active virtual balance", xps._balances[account].activeVirtualBalance);
        xps._balances[account].activeVirtualBalance -= decayAmount;
        xps._balances[account].inactiveVirtualBalance += decayAmount;
        xps._balances[account].lastDecayBlock = block.number;
    }

    function transfer(address from, address to, uint256 amount, bool allowNonLSP1Recipient, bytes memory data) public virtual override {
        // Transfer should revert as this is Soul bound
        revert("soulbound non transferrable");
    }

    function transferBatch(
        address[] memory from,
        address[] memory to,
        uint256[] memory amount,
        bool[] memory allowNonLSP1Recipient,
        bytes[] memory data
    ) public virtual override {
        // Transfer should revert as this is Soul bound
        revert LSP7InvalidTransferBatch();
    }

    /**
     * ILSP7CompatibleERC20
     */
    function allowance(address tokenOwner, address operator) public view virtual returns (uint256) {
        return authorizedAmountFor(operator, tokenOwner);
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        decay(msg.sender);
        decay(recipient);
        // TODO not we assume non EOA account
        _transfer(msg.sender, recipient, amount, false, "");
        xps._balances[msg.sender].lastDecayBlock = block.number;
        xps._balances[recipient].lastDecayBlock = block.number;
        updateHolders(msg.sender);
        updateHolders(recipient);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        decay(sender);
        decay(recipient);
        // NOTE this would be a discrepancy between the LSP7 and ERC20
        _transfer(sender, recipient, amount, false, "");
        // Double check this
        authorizeOperator(sender, allowance(sender, _msgSender()) - amount, "");
        xps._balances[sender].lastDecayBlock = block.number;
        xps._balances[recipient].lastDecayBlock = block.number;
        updateHolders(sender);
        updateHolders(recipient);
        return true;
    }

    // Note this shoudl actually just be the activeVirtualBalance we need another function for
    // t
    function balanceOf(address account) public view virtual override returns (uint256) {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        uint256 balance = super.balanceOf(account);
        //uint256 decayedBalance = xps._balances[account].activeVirtualBalance + xps._balances[account].inactiveVirtualBalance;
        return balance /* + decayedBalance*/;
    }

    // Decay amount should be a flat rate per block and not a percentage and we should be able to scale to 0.0001
    function activeVirtualBalanceOf(address account) public view returns (uint256) {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        uint256 decayBlocks = block.number - xps._balances[account].lastDecayBlock;
        uint256 decayAmount = xps._decayRate * decayBlocks;
        if (xps._balances[account].activeVirtualBalance > decayAmount) {
            return xps._balances[account].activeVirtualBalance - decayAmount;
        }
        return 0;
    }

    // Decay amount should be a flat rate per block and not a percentage
    // 1 xp per block or 100xp per block or 0.1xp per block up to 1000xp
    function inactiveVirtualBalanceOf(address account) public view returns (uint256) {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        uint256 decayBlocks = block.number - xps._balances[account].lastDecayBlock;
        uint256 decayAmount = xps._decayRate * decayBlocks;
        if (decayAmount > xps._balances[account].activeVirtualBalance) {
            decayAmount = xps._balances[account].activeVirtualBalance;
        }
        return xps._balances[account].inactiveVirtualBalance + decayAmount;
    }

    function setDecayRate(uint256 decayRate) public onlyOwner {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        xps._decayRate = decayRate;
    }

    function updateBalances(address[] memory accounts) public onlyOwner {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            decay(accounts[i]);
            xps._balances[accounts[i]].activeVirtualBalance = 0;
            xps._balances[accounts[i]].inactiveVirtualBalance = 0;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        decay(from);
        decay(to);
    }

    function updateHolders(address account) internal {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        if (xps._balances[account].lastDecayBlock > 0) {
            return;
        }
        xps.holders.push(account);
    }

    function listHolders() public view returns (address[] memory) {
        LibXP.LibXPStorage storage xps = LibXP.libXPStorage();
        return xps.holders;
    }
}