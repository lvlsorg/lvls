
// This is generated code that is used to have sane lookups for facets on 
// diamond testing run hardhat/scripts/forge.ts to generate more
// it currently defaults to using the production config for facets registered
// use this via contract:local-deploy2 scripts to read consumable facet data
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {IDiamondCut} from "../../contracts/interfaces/IDiamondCut.sol";

// import all facets so we can instantiate them for testing if needed
import {DiamondCutFacet} from "../../contracts/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../contracts/facets/DiamondLoupeFacet.sol";
import {OwnershipFacet} from "../../contracts/facets/OwnershipFacet.sol";
import {ERC725YFacet} from "../../contracts/facets/ERC725YFacet.sol";
import {LSP7DigitalAssetFacet} from "../../contracts/facets/LSP7DigitalAssetFacet.sol";
import {XPLSP7TokenFacet} from "../../contracts/facets/XPLSP7TokenFacet.sol";
import {LXPFacet} from "../../contracts/facets/LXPFacet.sol";
import {SoulboundDecayStakingFacet} from "../../contracts/facets/SoulboundDecayStakingFacet.sol";

struct FacetCutInfo {
  bytes20 id;
  bytes4[] functionSelectors;
}
contract TestFacetLookup {
  mapping(bytes20 => FacetCutInfo) public facetLookup;
  mapping(string => FacetCutInfo) public facetNameLookup;

  constructor() {
      bytes4[] memory functionSelectors1 = new bytes4[](1);
    functionSelectors1[0] = 0x1f931c1c;
    bytes20 id1 = hex"ad42985fd120c8d8864ab54d5cae09db456125ca";
    facetLookup[id1] = FacetCutInfo({id: id1, functionSelectors: functionSelectors1});
    facetNameLookup["DiamondCutFacet"] = FacetCutInfo({id: id1, functionSelectors: functionSelectors1});
    bytes4[] memory functionSelectors2 = new bytes4[](1);
    functionSelectors2[0] = 0x1f931c1c;
    bytes20 id2 = hex"ad42985fd120c8d8864ab54d5cae09db456125ca";
    facetLookup[id2] = FacetCutInfo({id: id2, functionSelectors: functionSelectors2});
    facetNameLookup["DiamondCutFacet"] = FacetCutInfo({id: id2, functionSelectors: functionSelectors2});
    bytes4[] memory functionSelectors3 = new bytes4[](4);
    functionSelectors3[0] = 0xcdffacc6;
    functionSelectors3[1] = 0x52ef6b2c;
    functionSelectors3[2] = 0xadfca15e;
    functionSelectors3[3] = 0x7a0ed627;
    bytes20 id3 = hex"2229211e4ea8f43facbc59c41df0b18e465737f2";
    facetLookup[id3] = FacetCutInfo({id: id3, functionSelectors: functionSelectors3});
    facetNameLookup["DiamondLoupeFacet"] = FacetCutInfo({id: id3, functionSelectors: functionSelectors3});
    bytes4[] memory functionSelectors4 = new bytes4[](4);
    functionSelectors4[0] = 0xcdffacc6;
    functionSelectors4[1] = 0x52ef6b2c;
    functionSelectors4[2] = 0xadfca15e;
    functionSelectors4[3] = 0x7a0ed627;
    bytes20 id4 = hex"2229211e4ea8f43facbc59c41df0b18e465737f2";
    facetLookup[id4] = FacetCutInfo({id: id4, functionSelectors: functionSelectors4});
    facetNameLookup["DiamondLoupeFacet"] = FacetCutInfo({id: id4, functionSelectors: functionSelectors4});
    bytes4[] memory functionSelectors5 = new bytes4[](2);
    functionSelectors5[0] = 0x8da5cb5b;
    functionSelectors5[1] = 0xf2fde38b;
    bytes20 id5 = hex"c270ea653cbd09aaba98a6cddbb78692b0762ac4";
    facetLookup[id5] = FacetCutInfo({id: id5, functionSelectors: functionSelectors5});
    facetNameLookup["OwnershipFacet"] = FacetCutInfo({id: id5, functionSelectors: functionSelectors5});
    bytes4[] memory functionSelectors6 = new bytes4[](2);
    functionSelectors6[0] = 0x8da5cb5b;
    functionSelectors6[1] = 0xf2fde38b;
    bytes20 id6 = hex"c270ea653cbd09aaba98a6cddbb78692b0762ac4";
    facetLookup[id6] = FacetCutInfo({id: id6, functionSelectors: functionSelectors6});
    facetNameLookup["OwnershipFacet"] = FacetCutInfo({id: id6, functionSelectors: functionSelectors6});
    bytes4[] memory functionSelectors7 = new bytes4[](6);
    functionSelectors7[0] = 0x4e3e6e9c;
    functionSelectors7[1] = 0x54f6127f;
    functionSelectors7[2] = 0xdedff9c6;
    functionSelectors7[3] = 0x14a6e293;
    functionSelectors7[4] = 0x7f23690c;
    functionSelectors7[5] = 0x97902421;
    bytes20 id7 = hex"855554cf03306ac4bb3bec75b1809dae78b2c759";
    facetLookup[id7] = FacetCutInfo({id: id7, functionSelectors: functionSelectors7});
    facetNameLookup["ERC725YFacet"] = FacetCutInfo({id: id7, functionSelectors: functionSelectors7});
    bytes4[] memory functionSelectors8 = new bytes4[](6);
    functionSelectors8[0] = 0x4e3e6e9c;
    functionSelectors8[1] = 0x54f6127f;
    functionSelectors8[2] = 0xdedff9c6;
    functionSelectors8[3] = 0x14a6e293;
    functionSelectors8[4] = 0x7f23690c;
    functionSelectors8[5] = 0x97902421;
    bytes20 id8 = hex"855554cf03306ac4bb3bec75b1809dae78b2c759";
    facetLookup[id8] = FacetCutInfo({id: id8, functionSelectors: functionSelectors8});
    facetNameLookup["ERC725YFacet"] = FacetCutInfo({id: id8, functionSelectors: functionSelectors8});
    bytes4[] memory functionSelectors9 = new bytes4[](10);
    functionSelectors9[0] = 0x47980aa3;
    functionSelectors9[1] = 0x65aeaa95;
    functionSelectors9[2] = 0x70a08231;
    functionSelectors9[3] = 0xfe9d9303;
    functionSelectors9[4] = 0x313ce567;
    functionSelectors9[5] = 0x7580d920;
    functionSelectors9[6] = 0xfad8b32a;
    functionSelectors9[7] = 0x18160ddd;
    functionSelectors9[8] = 0x760d9bba;
    functionSelectors9[9] = 0x2d7667c9;
    bytes20 id9 = hex"c93695b15f2ff765aa3d13c81bc76ee38d96daae";
    facetLookup[id9] = FacetCutInfo({id: id9, functionSelectors: functionSelectors9});
    facetNameLookup["LSP7DigitalAssetFacet"] = FacetCutInfo({id: id9, functionSelectors: functionSelectors9});
    bytes4[] memory functionSelectors10 = new bytes4[](10);
    functionSelectors10[0] = 0x47980aa3;
    functionSelectors10[1] = 0x65aeaa95;
    functionSelectors10[2] = 0x70a08231;
    functionSelectors10[3] = 0xfe9d9303;
    functionSelectors10[4] = 0x313ce567;
    functionSelectors10[5] = 0x7580d920;
    functionSelectors10[6] = 0xfad8b32a;
    functionSelectors10[7] = 0x18160ddd;
    functionSelectors10[8] = 0x760d9bba;
    functionSelectors10[9] = 0x2d7667c9;
    bytes20 id10 = hex"c93695b15f2ff765aa3d13c81bc76ee38d96daae";
    facetLookup[id10] = FacetCutInfo({id: id10, functionSelectors: functionSelectors10});
    facetNameLookup["LSP7DigitalAssetFacet"] = FacetCutInfo({id: id10, functionSelectors: functionSelectors10});
    bytes4[] memory functionSelectors11 = new bytes4[](20);
    functionSelectors11[0] = 0xed6fe28d;
    functionSelectors11[1] = 0xdd62ed3e;
    functionSelectors11[2] = 0x095ea7b3;
    functionSelectors11[3] = 0x47980aa3;
    functionSelectors11[4] = 0x65aeaa95;
    functionSelectors11[5] = 0x70a08231;
    functionSelectors11[6] = 0xfe9d9303;
    functionSelectors11[7] = 0x313ce567;
    functionSelectors11[8] = 0xd646f3fc;
    functionSelectors11[9] = 0x8f9c14e7;
    functionSelectors11[10] = 0x40c10f19;
    functionSelectors11[11] = 0x7580d920;
    functionSelectors11[12] = 0xfad8b32a;
    functionSelectors11[13] = 0x04e7e0b9;
    functionSelectors11[14] = 0x18160ddd;
    functionSelectors11[15] = 0x760d9bba;
    functionSelectors11[16] = 0xa9059cbb;
    functionSelectors11[17] = 0x2d7667c9;
    functionSelectors11[18] = 0x23b872dd;
    functionSelectors11[19] = 0xab42d066;
    bytes20 id11 = hex"0e095396ca2286ee1426a4ad9a153481aa4e86c9";
    facetLookup[id11] = FacetCutInfo({id: id11, functionSelectors: functionSelectors11});
    facetNameLookup["XPLSP7TokenFacet"] = FacetCutInfo({id: id11, functionSelectors: functionSelectors11});
    bytes4[] memory functionSelectors12 = new bytes4[](20);
    functionSelectors12[0] = 0xed6fe28d;
    functionSelectors12[1] = 0xdd62ed3e;
    functionSelectors12[2] = 0x095ea7b3;
    functionSelectors12[3] = 0x47980aa3;
    functionSelectors12[4] = 0x65aeaa95;
    functionSelectors12[5] = 0x70a08231;
    functionSelectors12[6] = 0xfe9d9303;
    functionSelectors12[7] = 0x313ce567;
    functionSelectors12[8] = 0xd646f3fc;
    functionSelectors12[9] = 0x8f9c14e7;
    functionSelectors12[10] = 0x40c10f19;
    functionSelectors12[11] = 0x7580d920;
    functionSelectors12[12] = 0xfad8b32a;
    functionSelectors12[13] = 0x04e7e0b9;
    functionSelectors12[14] = 0x18160ddd;
    functionSelectors12[15] = 0x760d9bba;
    functionSelectors12[16] = 0xa9059cbb;
    functionSelectors12[17] = 0x2d7667c9;
    functionSelectors12[18] = 0x23b872dd;
    functionSelectors12[19] = 0xab42d066;
    bytes20 id12 = hex"0e095396ca2286ee1426a4ad9a153481aa4e86c9";
    facetLookup[id12] = FacetCutInfo({id: id12, functionSelectors: functionSelectors12});
    facetNameLookup["XPLSP7TokenFacet"] = FacetCutInfo({id: id12, functionSelectors: functionSelectors12});
    bytes4[] memory functionSelectors13 = new bytes4[](10);
    functionSelectors13[0] = 0x47980aa3;
    functionSelectors13[1] = 0x65aeaa95;
    functionSelectors13[2] = 0x70a08231;
    functionSelectors13[3] = 0xfe9d9303;
    functionSelectors13[4] = 0x313ce567;
    functionSelectors13[5] = 0x7580d920;
    functionSelectors13[6] = 0xfad8b32a;
    functionSelectors13[7] = 0x18160ddd;
    functionSelectors13[8] = 0x760d9bba;
    functionSelectors13[9] = 0x2d7667c9;
    bytes20 id13 = hex"42d8da2d90f55eb4d337b63a5601ba13e8a4a62e";
    facetLookup[id13] = FacetCutInfo({id: id13, functionSelectors: functionSelectors13});
    facetNameLookup["LXPFacet"] = FacetCutInfo({id: id13, functionSelectors: functionSelectors13});
    bytes4[] memory functionSelectors14 = new bytes4[](10);
    functionSelectors14[0] = 0x47980aa3;
    functionSelectors14[1] = 0x65aeaa95;
    functionSelectors14[2] = 0x70a08231;
    functionSelectors14[3] = 0xfe9d9303;
    functionSelectors14[4] = 0x313ce567;
    functionSelectors14[5] = 0x7580d920;
    functionSelectors14[6] = 0xfad8b32a;
    functionSelectors14[7] = 0x18160ddd;
    functionSelectors14[8] = 0x760d9bba;
    functionSelectors14[9] = 0x2d7667c9;
    bytes20 id14 = hex"42d8da2d90f55eb4d337b63a5601ba13e8a4a62e";
    facetLookup[id14] = FacetCutInfo({id: id14, functionSelectors: functionSelectors14});
    facetNameLookup["LXPFacet"] = FacetCutInfo({id: id14, functionSelectors: functionSelectors14});
    bytes4[] memory functionSelectors15 = new bytes4[](7);
    functionSelectors15[0] = 0x3ba0b9a9;
    functionSelectors15[1] = 0x741d852e;
    functionSelectors15[2] = 0xd6b7494f;
    functionSelectors15[3] = 0xdb068e0e;
    functionSelectors15[4] = 0xa1bab447;
    functionSelectors15[5] = 0x0cd8dd0b;
    functionSelectors15[6] = 0x87b5f114;
    bytes20 id15 = hex"a9fdbff4dfa55d664de916feb8065672fd98bb1d";
    facetLookup[id15] = FacetCutInfo({id: id15, functionSelectors: functionSelectors15});
    facetNameLookup["SoulboundDecayStakingFacet"] = FacetCutInfo({id: id15, functionSelectors: functionSelectors15});
    bytes4[] memory functionSelectors16 = new bytes4[](7);
    functionSelectors16[0] = 0x3ba0b9a9;
    functionSelectors16[1] = 0x741d852e;
    functionSelectors16[2] = 0xd6b7494f;
    functionSelectors16[3] = 0xdb068e0e;
    functionSelectors16[4] = 0xa1bab447;
    functionSelectors16[5] = 0x0cd8dd0b;
    functionSelectors16[6] = 0x87b5f114;
    bytes20 id16 = hex"a9fdbff4dfa55d664de916feb8065672fd98bb1d";
    facetLookup[id16] = FacetCutInfo({id: id16, functionSelectors: functionSelectors16});
    facetNameLookup["SoulboundDecayStakingFacet"] = FacetCutInfo({id: id16, functionSelectors: functionSelectors16});
  }

  function makeCut(address facetAddress, FacetCutInfo memory fci) public returns (IDiamondCut.FacetCut memory) {
      IDiamondCut.FacetCut memory fc;
      fc.action = IDiamondCut.FacetCutAction.Add;
      fc.facetAddress = facetAddress;
      fc.functionSelectors = fci.functionSelectors;
      return fc;
  }

  function makeCuts(string[] memory facetNames, address[] memory facetAddress) internal returns (IDiamondCut.FacetCut[] memory cuts) {
    cuts = new IDiamondCut.FacetCut[](facetNames.length);
    for (uint256 i = 0; i < facetNames.length; i++) {
      FacetCutInfo memory fci = facetNameLookup[facetNames[i]];
      cuts[i] = makeCut(facetAddress[i], fci);
    }
  }

  function makeCuts(bytes20[] memory facetIds, address[] memory facetAddress) internal returns (IDiamondCut.FacetCut[] memory cuts) {
    cuts = new IDiamondCut.FacetCut[](facetIds.length);
    for (uint256 i = 0; i < facetIds.length; i++) {
      FacetCutInfo memory fci = facetLookup[facetIds[i]];
      cuts[i] = makeCut(facetAddress[i], fci);
    }
  }
}
