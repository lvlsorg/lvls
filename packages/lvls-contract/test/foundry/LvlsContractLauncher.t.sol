// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {DiamondLauncherFacet} from "../../contracts/facets/DiamondLauncherFacet.sol";
import {BlankDiamond} from "./BlankDiamond.t.sol";
import {Diamond} from "../../contracts/Diamond.sol";
import {IDiamondCut} from "../../contracts/interfaces/IDiamondCut.sol";
import {DiamondLoupeFacet} from "../../contracts/facets/DiamondLoupeFacet.sol";
import {DiamondCutFacet} from "../../contracts/facets/DiamondCutFacet.sol";
import {IDiamondLoupe} from "../../contracts/interfaces/IDiamondLoupe.sol";
import {IERC165} from "../../contracts/interfaces/IERC165.sol";
import {ILvlsContractLauncher} from "../../contracts/interfaces/ILvlsContractLauncher.sol";
import {OwnershipFacet} from "../../contracts/facets/OwnershipFacet.sol";
import {LXPFacet} from "../../contracts/facets/LXPFacet.sol";
import {XPLSP7TokenFacet} from "../../contracts/facets/XPLSP7TokenFacet.sol";
import {ERC725YFacet} from "../../contracts/facets/ERC725YFacet.sol";
import {SoulboundDecayStakingFacet} from "../../contracts/facets/SoulboundDecayStakingFacet.sol";
import {TestFacetLookup} from "./TestFacetLookup.t.sol";
import {LvlsLauncherFacet} from "../../contracts/facets/LvlsLauncherFacet.sol";

contract LvlsLauncherFacetTest is Test, TestFacetLookup {
    Diamond launcher;
    OwnershipFacet ownershipFacet;
    LXPFacet lxpFacet;
    XPLSP7TokenFacet xplsp7Facet;
    ERC725YFacet erc725yFacet;
    SoulboundDecayStakingFacet soulboundDecayStakingFacet;

    function setUp() public {
        address alice = makeAddr("aliceOwner");
        BlankDiamond blank = new BlankDiamond();
        LvlsLauncherFacet lvlsLauncherFacet = new LvlsLauncherFacet();
        DiamondLauncherFacet diamondLauncherFacet = new DiamondLauncherFacet();
        DiamondLoupeFacet DiamondLoupeFacet = new DiamondLoupeFacet();
        DiamondCutFacet DiamondCutFacet = new DiamondCutFacet();

        lxpFacet = new LXPFacet();
        ownershipFacet = new OwnershipFacet();
        xplsp7Facet = new XPLSP7TokenFacet();
        erc725yFacet = new ERC725YFacet();
        soulboundDecayStakingFacet = new SoulboundDecayStakingFacet();
        launcher = blank.makeBlankDiamondWithLoupe(alice);
        vm.startPrank(alice);

        string[] memory launcherFacetNames = new string[](4);
        launcherFacetNames[0] = "ERC725YFacet";
        launcherFacetNames[1] = "OwnershipFacet";
        launcherFacetNames[2] = "LvlsLauncherFacet";
        launcherFacetNames[3] = "DiamondLauncherFacet";

        address[] memory launcherFacetAddresses = new address[](4);
        launcherFacetAddresses[0] = address(erc725yFacet);
        launcherFacetAddresses[1] = address(ownershipFacet);
        launcherFacetAddresses[2] = address(lvlsLauncherFacet);
        launcherFacetAddresses[3] = address(diamondLauncherFacet);

        IDiamondCut.FacetCut[] memory launcherCuts = makeCuts(launcherFacetNames, launcherFacetAddresses);

        IDiamondCut(address(launcher)).diamondCut(launcherCuts, address(0), new bytes(0));

        ILvlsContractLauncher(address(launcher)).setDiamondAddresses(address(DiamondCutFacet), address(DiamondLoupeFacet), address(0));

        string[] memory facetNames = new string[](3);
        facetNames[0] = "ERC725YFacet";
        facetNames[1] = "OwnershipFacet";
        facetNames[2] = "LXPFacet";

        address[] memory facetAddresses = new address[](3);
        facetAddresses[0] = address(erc725yFacet);
        facetAddresses[1] = address(ownershipFacet);
        facetAddresses[2] = address(lxpFacet);

        IDiamondCut.FacetCut[] memory lxpCuts = makeCuts(facetNames, facetAddresses);

        facetNames[2] = "XPLSP7TokenFacet";
        facetAddresses[2] = address(xplsp7Facet);
        IDiamondCut.FacetCut[] memory xpCuts = makeCuts(facetNames, facetAddresses);

        facetNames[2] = "SoulboundDecayStakingFacet";
        IDiamondCut.FacetCut[] memory lvlsCuts = makeCuts(facetNames, facetAddresses);

        ILvlsContractLauncher(address(launcher)).setXPFacetCuts(xpCuts);
        ILvlsContractLauncher(address(launcher)).setLXPFacetCuts(lxpCuts);
        ILvlsContractLauncher(address(launcher)).setLvlsFacetCuts(lvlsCuts);
        vm.stopPrank();
    }

    function testLaunchDiamond() public {
        address alice = makeAddr("aliceOwner");
        (address lvls, address xp, address lxp) = ILvlsContractLauncher(address(launcher)).launch(alice);
        uint256 supply = ILSP7XP(xp).totalSupply();
        assertEq(supply, 0, "XP supply should be 0");
        ISoulboundDecayStaking(lxp).setExchangeRate(500);
        assertNotEq(lvls, address(0), "Lvls address should not be 0");
    }
}
