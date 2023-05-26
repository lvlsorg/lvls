// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {Diamond} from "../../contracts/Diamond.sol";
import {LibDiamond} from "../../contracts/libraries/LibDiamond.sol";
import {DiamondLoupeFacet} from "../../contracts/facets/DiamondLoupeFacet.sol";
import {DiamondCutFacet} from "../../contracts/facets/DiamondCutFacet.sol";
import {Helper} from "./Helper.t.sol";
import {IERC165} from "../../contracts/interfaces/IERC165.sol";
import {IDiamondLoupe} from "../../contracts/interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../../contracts/interfaces/IDiamondCut.sol";

abstract contract TestDiamondCore is Test {
    DiamondLoupeFacet loupeFacet;
    DiamondCutFacet cutFacet;

    constructor() {
        loupeFacet = new DiamondLoupeFacet();
        cutFacet = new DiamondCutFacet();
    }
}
