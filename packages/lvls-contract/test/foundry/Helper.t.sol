pragma solidity ^0.8.15;
// SPDX-License-Identifier: Unlicense
import {LibDiamond} from "../../contracts/libraries/LibDiamond.sol";
import "forge-std/Test.sol";

abstract contract Helper is Test {
    function checkEq(bytes20[] memory a, bytes20[] memory b) internal {
        assertEq(a.length, b.length);
        for (uint256 i = 0; i < a.length; i++) {
            assertEq(abi.encodePacked(a[i]), abi.encodePacked(b[i]));
        }
    }
}
