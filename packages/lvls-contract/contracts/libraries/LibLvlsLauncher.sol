// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

struct LibLvlsLauncherStorage {
    address[] deployedContractAddresses;
    mapping(address => address[]) userAddressToLvlsContract;
    address diamondCutAddress;
    address diamondLauncherAddress;
    address diamondLoupeAddress;
    address diamondInitAddress;
    IDiamondCut.FacetCut[] xpFacetCuts;
    IDiamondCut.FacetCut[] lxpFacetCuts;
    IDiamondCut.FacetCut[] lvlsFacetCuts;
    IDiamondCut.FacetCut[] rewardTokenFacetCuts;
    uint256 minFee;
    uint256 maxFee;
    uint256 feeMultiplier;
}

library LibLvlsContractLauncher {
    uint256 constant MIN_TX_GAS = 21000;
    bytes32 constant STORAGE_POSITION = keccak256("lib_lvls_launcher.storage");

    function libLvlsLauncherStorage() internal pure returns (LibLvlsLauncherStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
