// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {ERC725YFacet} from "./ERC725YFacet.sol";
import "../libraries/LSP4Constants.sol";

contract Metadata {
    function name() public view virtual returns (string memory) {
        return string(ERC725YFacet(address(this)).getData(_LSP4_TOKEN_NAME_KEY));
    }

    function symbol() public view virtual returns (string memory) {
        return string(ERC725YFacet(address(this)).getData(_LSP4_TOKEN_SYMBOL_KEY));
    }
}
