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
    function _getData(bytes32 dataKey) internal view returns (bytes memory dataValue) {
        return lib725Storage().store[dataKey];
    }
    function _setData(bytes32 dataKey, bytes memory dataValue) internal {
        lib725Storage().store[dataKey] = dataValue;
    }

    function _setBatchData(bytes32[] memory dataKeys, bytes[] memory dataValues) internal {
        require(dataKeys.length == dataValues.length, "Keys length not equal to values length");
        for (uint256 i = 0; i < dataKeys.length; i++) {
            _setData(dataKeys[i], dataValues[i]);
        }
    }

    function _getBatchData(bytes32[] memory dataKeys) internal view returns (bytes[] memory dataValues) {
        dataValues = new bytes[](dataKeys.length);

        for (uint256 i = 0; i < dataKeys.length; i++) {
            dataValues[i] = _getData(dataKeys[i]);
        }
        return dataValues;
    }
}
