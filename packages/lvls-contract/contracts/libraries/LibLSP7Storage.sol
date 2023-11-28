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
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

using EnumerableSet for EnumerableSet.AddressSet;
struct LibLSP7Storage {
    // --- Storage
    // --- Storage

    // Mapping from `tokenOwner` to an `amount` of tokens
    mapping(address => uint256) _tokenOwnerBalances;
    // Mapping a `tokenOwner` to an `operator` to `amount` of tokens.
    mapping(address => mapping(address => uint256)) _operatorAuthorizedAmount;
    // Mapping an `address` to its authorized operator addresses.
    mapping(address => EnumerableSet.AddressSet) _operators;
    uint256 _existingTokens;
    bool _isNonDivisible;
}

library LibLSP7 {
    bytes32 constant LIB_LSP7_STORAGE_POSITION = keccak256("lvls.lsp7.storage");

    function libLSP7Storage() internal pure returns (LibLSP7Storage storage ds) {
        bytes32 position = LIB_LSP7_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
