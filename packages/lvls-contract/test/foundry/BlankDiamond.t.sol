pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/StdJson.sol";

import {Diamond} from "../../contracts/Diamond.sol";
import {LibDiamond} from "../../contracts/libraries/LibDiamond.sol";
import {IDiamondCut} from "../../contracts/interfaces/IDiamondCut.sol";
import {TestFacetLookup} from "./TestFacetLookup.t.sol";
import {TestDiamondCore} from "./DiamondCore.t.sol";

using stdJson for string;

contract BlankDiamond is TestDiamondCore, TestFacetLookup {
    string json;

    constructor() {}

    function makeBlankDiamond(address owner) public returns (Diamond) {
        Diamond diamond = new Diamond(owner, address(cutFacet), address(loupeFacet));
        return diamond;
    }

    function makeBlankDiamondWithLoupe(address owner) public returns (Diamond) {
        vm.startPrank(owner);
        Diamond diamond = new Diamond(owner, address(cutFacet), address(loupeFacet));
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0].action = IDiamondCut.FacetCutAction.Add;
        cut[0].facetAddress = address(loupeFacet);
        cut[0].functionSelectors = facetNameLookup["DiamondLoupeFacet"].functionSelectors;
        IDiamondCut(address(diamond)).diamondCut(cut, address(0), new bytes(0));
        vm.stopPrank();
        return diamond;
    }
}
