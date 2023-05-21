// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

struct Lib725Storage {
    mapping(bytes32 => bytes) store;
}

library Lib725 {
    bytes32 constant LIB_725_STORAGE_POSITION = keccak256("one_of_one.725.storage");

    function lib725Storage() internal pure returns (Lib725Storage storage ds) {
        bytes32 position = LIB_725_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
