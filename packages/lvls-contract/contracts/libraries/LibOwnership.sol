pragma solidity ^0.8.15;

library LibOwnership {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("1o1.lib.ownership");

    struct OwnershipStorage {
        address contractOwner;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function enforceIsContractOwner() internal view {
        require(_msgSender() == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    function setContractOwner(address _newOwner) internal {
        OwnershipStorage storage os = diamondStorage();
        address previousOwner = os.contractOwner;
        os.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function diamondStorage() internal pure returns (OwnershipStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
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
