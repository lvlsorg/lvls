// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.15;
// interfaces
import {ILSP1UniversalReceiver} from "../interfaces/ILSP1UniversalReceiver.sol";
import {ILSP7DigitalAsset} from "../interfaces/ILSP7DigitalAsset.sol";

// libraries
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

// errors
import "./LSP7Errors.sol";

// constants
import {_INTERFACEID_LSP1} from "../libraries/LSP1Constants.sol";
import {_TYPEID_LSP7_TOKENSSENDER, _TYPEID_LSP7_TOKENSRECIPIENT} from "./LSP7Constants.sol";

library LibXP {
    struct Balance {
        uint256 inactiveVirtualBalance;
        uint256 activeVirtualBalance;
        uint256 lastDecayBlock;
    }

    struct LibXPStorage {
        uint256 _decayRate;
        mapping(address => Balance) _balances;
        address[] holders;
    }

    bytes32 constant LIB_XP_STORAGE_POSITION = keccak256("lvls.xp.storage");

    function libXPStorage() internal pure returns (LibXPStorage storage ds) {
        bytes32 position = LIB_XP_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
