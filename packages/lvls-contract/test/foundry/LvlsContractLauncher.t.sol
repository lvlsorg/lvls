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
import {ILSP7XP} from "../../contracts/interfaces/ILSP7XP.sol";
import {ISoulboundDecayStaking} from "../../contracts/interfaces/ISoulboundDecayStaking.sol";
import {ILSP7DigitalAsset} from "../../contracts/interfaces/ILSP7DigitalAsset.sol";
import {LSP7DigitalAssetFacet} from "../../contracts/facets/LSP7DigitalAssetFacet.sol";

contract LvlsLauncherFacetTest is Test, TestFacetLookup {
    Diamond launcher;
    OwnershipFacet ownershipFacet;
    LXPFacet lxpFacet;
    XPLSP7TokenFacet xplsp7Facet;
    ERC725YFacet erc725yFacet;
    LSP7DigitalAssetFacet lsp7DigitalAssetFacet;
    SoulboundDecayStakingFacet soulboundDecayStakingFacet;

    function setUp() public {
        address alice = makeAddr("aliceOwner");
        BlankDiamond blank = new BlankDiamond();
        LvlsLauncherFacet lvlsLauncherFacet = new LvlsLauncherFacet();
        DiamondLauncherFacet diamondLauncherFacet = new DiamondLauncherFacet();
        DiamondLoupeFacet DiamondLoupeFacet = new DiamondLoupeFacet();
        DiamondCutFacet DiamondCutFacet = new DiamondCutFacet();

        lsp7DigitalAssetFacet = new LSP7DigitalAssetFacet();
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

        string[] memory facetNames = new string[](4);
        facetNames[0] = "ERC725YFacet";
        facetNames[1] = "OwnershipFacet";
        facetNames[2] = "LXPFacet";
        facetNames[3] = "DiamondLoupeFacet";

        address[] memory facetAddresses = new address[](4);
        facetAddresses[0] = address(erc725yFacet);
        facetAddresses[1] = address(ownershipFacet);
        facetAddresses[2] = address(lxpFacet);
        facetAddresses[3] = address(DiamondLoupeFacet);

        IDiamondCut.FacetCut[] memory lxpCuts = makeCuts(facetNames, facetAddresses);

        facetNames[2] = "XPLSP7TokenFacet";
        facetAddresses[2] = address(xplsp7Facet);
        IDiamondCut.FacetCut[] memory xpCuts = makeCuts(facetNames, facetAddresses);

        facetNames[2] = "SoulboundDecayStakingFacet";
        facetAddresses[2] = address(soulboundDecayStakingFacet);
        IDiamondCut.FacetCut[] memory lvlsCuts = makeCuts(facetNames, facetAddresses);

        facetNames[2] = "LSP7DigitalAssetFacet";
        facetAddresses[2] = address(lsp7DigitalAssetFacet);
        IDiamondCut.FacetCut[] memory rewardCuts = makeCuts(facetNames, facetAddresses);

        ILvlsContractLauncher(address(launcher)).setXPFacetCuts(xpCuts);
        ILvlsContractLauncher(address(launcher)).setLXPFacetCuts(lxpCuts);
        ILvlsContractLauncher(address(launcher)).setLvlsFacetCuts(lvlsCuts);
        ILvlsContractLauncher(address(launcher)).setRewardFacetCuts(rewardCuts);
        vm.stopPrank();
    }

    function testLaunchDiamond() public {
        address alice = makeAddr("aliceOwner");
        (address lvls, address xp, address lxp) = ILvlsContractLauncher(address(launcher)).launch(alice);
        address rewardAddr = ILvlsContractLauncher(address(launcher)).launchRewardToken(alice);
        ILSP7DigitalAsset rewardToken = ILSP7DigitalAsset(rewardAddr);

        vm.startPrank(alice);

        rewardToken.mint(alice, 2.0 ether, true, "test");
        ISoulboundDecayStaking(lvls).setRewardTokenAddress(rewardAddr);
        rewardToken.authorizeOperator(address(lvls), 2.0 ether);
        uint256 supply = ILSP7XP(xp).totalSupply();
        assertEq(supply, 0, "XP supply should be 0");
        // This sets the exchange rate to be 1/1
        ISoulboundDecayStaking(lvls).setExchangeRate(1000);
        ISoulboundDecayStaking(lvls).setDecayRate(0.1 ether);
        ISoulboundDecayStaking(lvls).setPenaltyRate(100);
        address bob = makeAddr("bob");
        ISoulboundDecayStaking(lvls).distributeXP(bob, 1.0 ether);
        supply = ILSP7XP(xp).totalSupply();
        assertEq(supply, 1.0 ether, "XP supply should be 1");
        vm.roll(6);
        // This should decay by 50 percent after 5 blocks
        assertEq(ILSP7XP(xp).inactiveVirtualBalanceOf(bob), 0.5 ether, "vested XP balance should be 0.5");
        assertEq(ILSP7XP(xp).activeVirtualBalanceOf(bob), 0.5 ether, "active XP balance should be 0.5");
        vm.roll(11);
        assertEq(ILSP7XP(xp).inactiveVirtualBalanceOf(bob), 1 ether, "vested XP balance should be 1 ");
        assertEq(ILSP7XP(xp).activeVirtualBalanceOf(bob), 0 ether, "active XP balance should be 0");
        vm.stopPrank();

        vm.startPrank(bob);

        ILSP7DigitalAsset(xp).authorizeOperator(address(lvls), 1.0 ether);
        ISoulboundDecayStaking(lvls).burnXP(1.0 ether);
        assertEq(ILSP7DigitalAsset(rewardAddr).balanceOf(bob), 1.0 ether, "Reward balance should be 1");
        assertEq(ILSP7XP(xp).inactiveVirtualBalanceOf(bob), 0 ether, "vested XP balance should be 0 ");
        assertEq(ILSP7XP(xp).activeVirtualBalanceOf(bob), 0 ether, "active XP balance should be 0");
        uint256 bobBalance = ILSP7DigitalAsset(rewardAddr).balanceOf(bob);

        vm.stopPrank();
        vm.startPrank(alice);
        ISoulboundDecayStaking(lvls).distributeXP(bob, 1.0 ether);
        vm.stopPrank();
        vm.startPrank(bob);
        vm.roll(block.number + 5);
        console.log("start block", block.number);
        assertEq(ILSP7XP(xp).inactiveVirtualBalanceOf(bob), 0.5 ether, "vested XP balance should be 0.5");
        assertEq(ILSP7XP(xp).activeVirtualBalanceOf(bob), 0.5 ether, "active XP balance should be 0.5");
        ILSP7DigitalAsset(xp).authorizeOperator(address(lvls), 1 ether);
        ISoulboundDecayStaking(lvls).burnXP(0.5 ether);
        console.log("end block", block.number);
        assertEq(ILSP7XP(xp).inactiveVirtualBalanceOf(bob), 0 ether, "vested XP balance should be 0 ");
        assertEq(ILSP7XP(xp).activeVirtualBalanceOf(bob), 0.5 ether, "active XP balance should be 0.5");

        assertEq(ILSP7DigitalAsset(rewardAddr).balanceOf(bob), bobBalance + 0.5 ether, "Reward balance should be starting balance + 0.5");
        // for conuversion we should incur a 0.25 * 0.1 penalty on the burn

        bobBalance = ILSP7DigitalAsset(rewardAddr).balanceOf(bob);
        ISoulboundDecayStaking(lvls).burnXP(0.25 ether);
        assertEq(ILSP7DigitalAsset(rewardAddr).balanceOf(bob), bobBalance + 0.225 ether, "Reward balance should be starting balance + 0.225");
        assertEq(ILSP7XP(xp).inactiveVirtualBalanceOf(bob), 0 ether, "vested XP balance should be 0 ");
        assertEq(ILSP7XP(xp).activeVirtualBalanceOf(bob), 0.25 ether, "active XP balance should be 0.25");

        vm.stopPrank();

        //assertNotEq(lvls, address(0), "Lvls address should not be 0");
    }
}
