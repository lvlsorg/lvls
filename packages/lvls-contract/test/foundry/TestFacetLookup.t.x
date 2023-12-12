// This is generated code that is used to have sane lookups for facets on
// diamond testing run hardhat/scripts/forge.ts to generate more
// it currently defaults to using the production config for facets registered
// use this via contract:local-deploy2 scripts to read consumable facet data
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {IDiamondCut} from "../../contracts/interfaces/IDiamondCut.sol";

// import all facets so we can instantiate them for testing if needed
import {DiamondCutFacet} from "../../contracts/facets/DiamondCutFacet.sol";
import {DiamondLauncherFacet} from "../../contracts/facets/DiamondLauncherFacet.sol";
import {DiamondLoupeFacet} from "../../contracts/facets/DiamondLoupeFacet.sol";
import {OwnershipFacet} from "../../contracts/facets/OwnershipFacet.sol";
import {ERC725YFacet} from "../../contracts/facets/ERC725YFacet.sol";
import {LSP7DigitalAssetFacet} from "../../contracts/facets/LSP7DigitalAssetFacet.sol";
import {XPLSP7TokenFacet} from "../../contracts/facets/XPLSP7TokenFacet.sol";
import {LXPFacet} from "../../contracts/facets/LXPFacet.sol";
import {SoulboundDecayStakingFacet} from "../../contracts/facets/SoulboundDecayStakingFacet.sol";
import {LvlsLauncherFacet} from "../../contracts/facets/LvlsLauncherFacet.sol";

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
        bytes4[] memory functionSelectors3 = new bytes4[](1);
        functionSelectors3[0] = 0x92348597;
        bytes20 id3 = hex"c06217284858020e6de7793071f03904cb7163f3";
        facetLookup[id3] = FacetCutInfo({id: id3, functionSelectors: functionSelectors3});
        facetNameLookup["DiamondLauncherFacet"] = FacetCutInfo({id: id3, functionSelectors: functionSelectors3});
        bytes4[] memory functionSelectors4 = new bytes4[](1);
        functionSelectors4[0] = 0x92348597;
        bytes20 id4 = hex"c06217284858020e6de7793071f03904cb7163f3";
        facetLookup[id4] = FacetCutInfo({id: id4, functionSelectors: functionSelectors4});
        facetNameLookup["DiamondLauncherFacet"] = FacetCutInfo({id: id4, functionSelectors: functionSelectors4});
        bytes4[] memory functionSelectors5 = new bytes4[](4);
        functionSelectors5[0] = 0xcdffacc6;
        functionSelectors5[1] = 0x52ef6b2c;
        functionSelectors5[2] = 0xadfca15e;
        functionSelectors5[3] = 0x7a0ed627;
        bytes20 id5 = hex"2229211e4ea8f43facbc59c41df0b18e465737f2";
        facetLookup[id5] = FacetCutInfo({id: id5, functionSelectors: functionSelectors5});
        facetNameLookup["DiamondLoupeFacet"] = FacetCutInfo({id: id5, functionSelectors: functionSelectors5});
        bytes4[] memory functionSelectors6 = new bytes4[](4);
        functionSelectors6[0] = 0xcdffacc6;
        functionSelectors6[1] = 0x52ef6b2c;
        functionSelectors6[2] = 0xadfca15e;
        functionSelectors6[3] = 0x7a0ed627;
        bytes20 id6 = hex"2229211e4ea8f43facbc59c41df0b18e465737f2";
        facetLookup[id6] = FacetCutInfo({id: id6, functionSelectors: functionSelectors6});
        facetNameLookup["DiamondLoupeFacet"] = FacetCutInfo({id: id6, functionSelectors: functionSelectors6});
        bytes4[] memory functionSelectors7 = new bytes4[](2);
        functionSelectors7[0] = 0x8da5cb5b;
        functionSelectors7[1] = 0xf2fde38b;
        bytes20 id7 = hex"c270ea653cbd09aaba98a6cddbb78692b0762ac4";
        facetLookup[id7] = FacetCutInfo({id: id7, functionSelectors: functionSelectors7});
        facetNameLookup["OwnershipFacet"] = FacetCutInfo({id: id7, functionSelectors: functionSelectors7});
        bytes4[] memory functionSelectors8 = new bytes4[](2);
        functionSelectors8[0] = 0x8da5cb5b;
        functionSelectors8[1] = 0xf2fde38b;
        bytes20 id8 = hex"c270ea653cbd09aaba98a6cddbb78692b0762ac4";
        facetLookup[id8] = FacetCutInfo({id: id8, functionSelectors: functionSelectors8});
        facetNameLookup["OwnershipFacet"] = FacetCutInfo({id: id8, functionSelectors: functionSelectors8});
        bytes4[] memory functionSelectors9 = new bytes4[](6);
        functionSelectors9[0] = 0x4e3e6e9c;
        functionSelectors9[1] = 0x54f6127f;
        functionSelectors9[2] = 0xdedff9c6;
        functionSelectors9[3] = 0x14a6e293;
        functionSelectors9[4] = 0x7f23690c;
        functionSelectors9[5] = 0x97902421;
        bytes20 id9 = hex"855554cf03306ac4bb3bec75b1809dae78b2c759";
        facetLookup[id9] = FacetCutInfo({id: id9, functionSelectors: functionSelectors9});
        facetNameLookup["ERC725YFacet"] = FacetCutInfo({id: id9, functionSelectors: functionSelectors9});
        bytes4[] memory functionSelectors10 = new bytes4[](6);
        functionSelectors10[0] = 0x4e3e6e9c;
        functionSelectors10[1] = 0x54f6127f;
        functionSelectors10[2] = 0xdedff9c6;
        functionSelectors10[3] = 0x14a6e293;
        functionSelectors10[4] = 0x7f23690c;
        functionSelectors10[5] = 0x97902421;
        bytes20 id10 = hex"855554cf03306ac4bb3bec75b1809dae78b2c759";
        facetLookup[id10] = FacetCutInfo({id: id10, functionSelectors: functionSelectors10});
        facetNameLookup["ERC725YFacet"] = FacetCutInfo({id: id10, functionSelectors: functionSelectors10});
        bytes4[] memory functionSelectors11 = new bytes4[](10);
        functionSelectors11[0] = 0x47980aa3;
        functionSelectors11[1] = 0x65aeaa95;
        functionSelectors11[2] = 0x70a08231;
        functionSelectors11[3] = 0x44d17187;
        functionSelectors11[4] = 0x313ce567;
        functionSelectors11[5] = 0x7580d920;
        functionSelectors11[6] = 0xfad8b32a;
        functionSelectors11[7] = 0x18160ddd;
        functionSelectors11[8] = 0x760d9bba;
        functionSelectors11[9] = 0x2d7667c9;
        bytes20 id11 = hex"c93695b15f2ff765aa3d13c81bc76ee38d96daae";
        facetLookup[id11] = FacetCutInfo({id: id11, functionSelectors: functionSelectors11});
        facetNameLookup["LSP7DigitalAssetFacet"] = FacetCutInfo({id: id11, functionSelectors: functionSelectors11});
        bytes4[] memory functionSelectors12 = new bytes4[](10);
        functionSelectors12[0] = 0x47980aa3;
        functionSelectors12[1] = 0x65aeaa95;
        functionSelectors12[2] = 0x70a08231;
        functionSelectors12[3] = 0x44d17187;
        functionSelectors12[4] = 0x313ce567;
        functionSelectors12[5] = 0x7580d920;
        functionSelectors12[6] = 0xfad8b32a;
        functionSelectors12[7] = 0x18160ddd;
        functionSelectors12[8] = 0x760d9bba;
        functionSelectors12[9] = 0x2d7667c9;
        bytes20 id12 = hex"c93695b15f2ff765aa3d13c81bc76ee38d96daae";
        facetLookup[id12] = FacetCutInfo({id: id12, functionSelectors: functionSelectors12});
        facetNameLookup["LSP7DigitalAssetFacet"] = FacetCutInfo({id: id12, functionSelectors: functionSelectors12});
        bytes4[] memory functionSelectors13 = new bytes4[](19);
        functionSelectors13[0] = 0xed6fe28d;
        functionSelectors13[1] = 0xdd62ed3e;
        functionSelectors13[2] = 0x095ea7b3;
        functionSelectors13[3] = 0x47980aa3;
        functionSelectors13[4] = 0x65aeaa95;
        functionSelectors13[5] = 0x70a08231;
        functionSelectors13[6] = 0x44d17187;
        functionSelectors13[7] = 0x313ce567;
        functionSelectors13[8] = 0xd646f3fc;
        functionSelectors13[9] = 0x8f9c14e7;
        functionSelectors13[10] = 0x7580d920;
        functionSelectors13[11] = 0xfad8b32a;
        functionSelectors13[12] = 0x04e7e0b9;
        functionSelectors13[13] = 0x18160ddd;
        functionSelectors13[14] = 0x760d9bba;
        functionSelectors13[15] = 0xa9059cbb;
        functionSelectors13[16] = 0x2d7667c9;
        functionSelectors13[17] = 0x23b872dd;
        functionSelectors13[18] = 0xab42d066;
        bytes20 id13 = hex"0e095396ca2286ee1426a4ad9a153481aa4e86c9";
        facetLookup[id13] = FacetCutInfo({id: id13, functionSelectors: functionSelectors13});
        facetNameLookup["XPLSP7TokenFacet"] = FacetCutInfo({id: id13, functionSelectors: functionSelectors13});
        bytes4[] memory functionSelectors14 = new bytes4[](19);
        functionSelectors14[0] = 0xed6fe28d;
        functionSelectors14[1] = 0xdd62ed3e;
        functionSelectors14[2] = 0x095ea7b3;
        functionSelectors14[3] = 0x47980aa3;
        functionSelectors14[4] = 0x65aeaa95;
        functionSelectors14[5] = 0x70a08231;
        functionSelectors14[6] = 0x44d17187;
        functionSelectors14[7] = 0x313ce567;
        functionSelectors14[8] = 0xd646f3fc;
        functionSelectors14[9] = 0x8f9c14e7;
        functionSelectors14[10] = 0x7580d920;
        functionSelectors14[11] = 0xfad8b32a;
        functionSelectors14[12] = 0x04e7e0b9;
        functionSelectors14[13] = 0x18160ddd;
        functionSelectors14[14] = 0x760d9bba;
        functionSelectors14[15] = 0xa9059cbb;
        functionSelectors14[16] = 0x2d7667c9;
        functionSelectors14[17] = 0x23b872dd;
        functionSelectors14[18] = 0xab42d066;
        bytes20 id14 = hex"0e095396ca2286ee1426a4ad9a153481aa4e86c9";
        facetLookup[id14] = FacetCutInfo({id: id14, functionSelectors: functionSelectors14});
        facetNameLookup["XPLSP7TokenFacet"] = FacetCutInfo({id: id14, functionSelectors: functionSelectors14});
        bytes4[] memory functionSelectors15 = new bytes4[](10);
        functionSelectors15[0] = 0x47980aa3;
        functionSelectors15[1] = 0x65aeaa95;
        functionSelectors15[2] = 0x70a08231;
        functionSelectors15[3] = 0x44d17187;
        functionSelectors15[4] = 0x313ce567;
        functionSelectors15[5] = 0x7580d920;
        functionSelectors15[6] = 0xfad8b32a;
        functionSelectors15[7] = 0x18160ddd;
        functionSelectors15[8] = 0x760d9bba;
        functionSelectors15[9] = 0x2d7667c9;
        bytes20 id15 = hex"42d8da2d90f55eb4d337b63a5601ba13e8a4a62e";
        facetLookup[id15] = FacetCutInfo({id: id15, functionSelectors: functionSelectors15});
        facetNameLookup["LXPFacet"] = FacetCutInfo({id: id15, functionSelectors: functionSelectors15});
        bytes4[] memory functionSelectors16 = new bytes4[](10);
        functionSelectors16[0] = 0x47980aa3;
        functionSelectors16[1] = 0x65aeaa95;
        functionSelectors16[2] = 0x70a08231;
        functionSelectors16[3] = 0x44d17187;
        functionSelectors16[4] = 0x313ce567;
        functionSelectors16[5] = 0x7580d920;
        functionSelectors16[6] = 0xfad8b32a;
        functionSelectors16[7] = 0x18160ddd;
        functionSelectors16[8] = 0x760d9bba;
        functionSelectors16[9] = 0x2d7667c9;
        bytes20 id16 = hex"42d8da2d90f55eb4d337b63a5601ba13e8a4a62e";
        facetLookup[id16] = FacetCutInfo({id: id16, functionSelectors: functionSelectors16});
        facetNameLookup["LXPFacet"] = FacetCutInfo({id: id16, functionSelectors: functionSelectors16});
        bytes4[] memory functionSelectors17 = new bytes4[](13);
        functionSelectors17[0] = 0x74de42e7;
        functionSelectors17[1] = 0xd3cbb7c8;
        functionSelectors17[2] = 0x3ba0b9a9;
        functionSelectors17[3] = 0xf09a4016;
        functionSelectors17[4] = 0x7bcee8d6;
        functionSelectors17[5] = 0xd6b7494f;
        functionSelectors17[6] = 0x04e7e0b9;
        functionSelectors17[7] = 0x8ffdb0de;
        functionSelectors17[8] = 0xdb068e0e;
        functionSelectors17[9] = 0xa1bab447;
        functionSelectors17[10] = 0x9a6acf20;
        functionSelectors17[11] = 0xcf761929;
        functionSelectors17[12] = 0x87b5f114;
        bytes20 id17 = hex"a9fdbff4dfa55d664de916feb8065672fd98bb1d";
        facetLookup[id17] = FacetCutInfo({id: id17, functionSelectors: functionSelectors17});
        facetNameLookup["SoulboundDecayStakingFacet"] = FacetCutInfo({id: id17, functionSelectors: functionSelectors17});
        bytes4[] memory functionSelectors18 = new bytes4[](13);
        functionSelectors18[0] = 0x74de42e7;
        functionSelectors18[1] = 0xd3cbb7c8;
        functionSelectors18[2] = 0x3ba0b9a9;
        functionSelectors18[3] = 0xf09a4016;
        functionSelectors18[4] = 0x7bcee8d6;
        functionSelectors18[5] = 0xd6b7494f;
        functionSelectors18[6] = 0x04e7e0b9;
        functionSelectors18[7] = 0x8ffdb0de;
        functionSelectors18[8] = 0xdb068e0e;
        functionSelectors18[9] = 0xa1bab447;
        functionSelectors18[10] = 0x9a6acf20;
        functionSelectors18[11] = 0xcf761929;
        functionSelectors18[12] = 0x87b5f114;
        bytes20 id18 = hex"a9fdbff4dfa55d664de916feb8065672fd98bb1d";
        facetLookup[id18] = FacetCutInfo({id: id18, functionSelectors: functionSelectors18});
        facetNameLookup["SoulboundDecayStakingFacet"] = FacetCutInfo({id: id18, functionSelectors: functionSelectors18});
        bytes4[] memory functionSelectors19 = new bytes4[](14);
        functionSelectors19[0] = 0x33c7c026;
        functionSelectors19[1] = 0xd2cf6ecb;
        functionSelectors19[2] = 0x48bc2956;
        functionSelectors19[3] = 0xced72f87;
        functionSelectors19[4] = 0x92828671;
        functionSelectors19[5] = 0x5cf34bcf;
        functionSelectors19[6] = 0x214013ca;
        functionSelectors19[7] = 0x7a715c7c;
        functionSelectors19[8] = 0x2b758b2e;
        functionSelectors19[9] = 0x5b65b9ab;
        functionSelectors19[10] = 0xaebf1037;
        functionSelectors19[11] = 0xa43eabed;
        functionSelectors19[12] = 0xf0407e3e;
        functionSelectors19[13] = 0x05c4faa1;
        bytes20 id19 = hex"4794f8caee686bf1d42148345b76999362de4070";
        facetLookup[id19] = FacetCutInfo({id: id19, functionSelectors: functionSelectors19});
        facetNameLookup["LvlsLauncherFacet"] = FacetCutInfo({id: id19, functionSelectors: functionSelectors19});
        bytes4[] memory functionSelectors20 = new bytes4[](14);
        functionSelectors20[0] = 0x33c7c026;
        functionSelectors20[1] = 0xd2cf6ecb;
        functionSelectors20[2] = 0x48bc2956;
        functionSelectors20[3] = 0xced72f87;
        functionSelectors20[4] = 0x92828671;
        functionSelectors20[5] = 0x5cf34bcf;
        functionSelectors20[6] = 0x214013ca;
        functionSelectors20[7] = 0x7a715c7c;
        functionSelectors20[8] = 0x2b758b2e;
        functionSelectors20[9] = 0x5b65b9ab;
        functionSelectors20[10] = 0xaebf1037;
        functionSelectors20[11] = 0xa43eabed;
        functionSelectors20[12] = 0xf0407e3e;
        functionSelectors20[13] = 0x05c4faa1;
        bytes20 id20 = hex"4794f8caee686bf1d42148345b76999362de4070";
        facetLookup[id20] = FacetCutInfo({id: id20, functionSelectors: functionSelectors20});
        facetNameLookup["LvlsLauncherFacet"] = FacetCutInfo({id: id20, functionSelectors: functionSelectors20});
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
