import {LSP7DigitalAsset} from "@lukso/lsp-smart-contracts/contracts/LSP7DigitalAsset/LSP7DigitalAsset.sol";

contract LXPFacet is LSP7DigitalAsset {
    constructor(
        string memory name_,
        string memory symbol_,
        address newOwner_,
        bool isNonDivisible_
    ) LSP7DigitalAsset(name_, symbol_, newOwner_, isNonDivisible_) {}

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
