// SPDX-License-Identifier: MIT
// Original from Fabian Vogelsteller <fabian@lukso.network>
pragma solidity ^0.8.15;

// interfaces
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC725Y} from "@erc725/smart-contracts/contracts/interfaces/IERC725Y.sol";

// modules
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// TODO understand this a little deeper
// import {OwnableUnset} from "@erc725/smart-contracts/contracts/custom/OwnableUnset.sol";

// constants
import {_INTERFACEID_ERC725Y} from "@erc725/smart-contracts/contracts/constants.sol";

import {Lib725Storage, Lib725} from "../libraries/Lib725.sol";
import {LibOwnership} from "../libraries/LibOwnership.sol";
import {BytesLib} from "solidity-bytes-utils/contracts/BytesLib.sol";

/**
 * @title Core implementation of ERC725Y General data key/value store
 * @author Fabian Vogelsteller <fabian@lukso.network>
 * @dev Contract module which provides the ability to set arbitrary data key/value pairs that can be changed over time
 * It is intended to standardise certain data key/value pairs to allow automated read and writes
 * from/to the contract storage
 */

contract ERC725YFacet is ERC165, IERC725Y {
    /**
     * @dev Map the dataKeys to their dataValues
     */

    /* Public functions */
    /**
     * @inheritdoc IERC725Y
     */
    function getData(bytes32 dataKey) public view virtual override returns (bytes memory dataValue) {
        dataValue = _getData(dataKey);
    }

    function getData(bytes32[] memory dataKeys) public view virtual returns (bytes[] memory dataValues) {
        dataValues = new bytes[](dataKeys.length);

        for (uint256 i = 0; i < dataKeys.length; i = _uncheckedIncrement(i)) {
            dataValues[i] = _getData(dataKeys[i]);
        }

        return dataValues;
    }

    function getDataBatch(bytes32[] memory dataKeys) public view virtual returns (bytes[] memory dataValues) {
        return getData(dataKeys);
    }

    /**
     *
     * @inheritdoc IERC725Y
     */
    function setData(bytes32 dataKey, bytes memory dataValue) public payable virtual onlyOwner {
        _setData(dataKey, dataValue);
    }

    function setData(bytes32[] memory dataKeys, bytes[] memory dataValues) public payable onlyOwner {
        require(dataKeys.length == dataValues.length, "Keys length not equal to values length");
        for (uint256 i = 0; i < dataKeys.length; i = _uncheckedIncrement(i)) {
            _setData(dataKeys[i], dataValues[i]);
        }
    }

    /**
     * @inheritdoc IERC725Y
     */
    function setDataBatch(bytes32[] memory dataKeys, bytes[] memory dataValues) public payable onlyOwner {
        return setData(dataKeys, dataValues);
    }

    /* Internal functions */

    function _getData(bytes32 dataKey) internal view virtual returns (bytes memory dataValue) {
        return Lib725.lib725Storage().store[dataKey];
    }

    function _setData(bytes32 dataKey, bytes memory dataValue) internal virtual {
        Lib725.lib725Storage().store[dataKey] = dataValue;
        emit DataChanged(dataKey, dataValue.length <= 256 ? dataValue : BytesLib.slice(dataValue, 0, 256));
    }

    /**
     * @dev Will return unchecked incremented uint256
     *      can be used to save gas when iterating over loops
     */
    function _uncheckedIncrement(uint256 i) internal pure returns (uint256) {
        unchecked {
            return i + 1;
        }
    }

    /* Overrides functions */

    /**
     * @inheritdoc ERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == _INTERFACEID_ERC725Y || super.supportsInterface(interfaceId);
    }

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

    modifier onlyOwner() {
        LibOwnership.OwnershipStorage storage ds = LibOwnership.diamondStorage();
        require(ds.contractOwner == _msgSender(), "only owner");
        _;
    }
}
