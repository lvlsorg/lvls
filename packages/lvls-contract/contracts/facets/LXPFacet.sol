pragma solidity ^0.8.15;
import {LSP7DigitalAssetFacet} from "./LSP7DigitalAssetFacet.sol";

contract LXPFacet is LSP7DigitalAssetFacet {
    function transfer(address from, address to, uint256 amount, bool allowNonLSPRecipient, bytes memory data) public virtual override {
        // Transfer should revert as this is Soul bound
        revert("soulbound non transferrable");
    }

    function transferBatch(
        address[] memory from,
        address[] memory to,
        uint256[] memory amounts,
        bool[] memory allowNonLSPRecipient,
        bytes[] memory data
    ) public virtual override {
        // Transfer should revert as this is Soul bound
        revert("soulbound non transferrable");
    }
}
