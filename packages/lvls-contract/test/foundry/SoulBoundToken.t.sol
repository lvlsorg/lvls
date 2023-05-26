// SPDX-License-Identifier: UNLICENSED

import "forge-std/Test.sol";

import {Helper} from "./Helper.t.sol";
import {BlankDiamond} from "./BlankDiamond.t.sol";
import {Diamond} from "../../contracts/Diamond.sol";
import {IDiamondCut} from "../../contracts/interfaces/IDiamondCut.sol";
import {TestFacetLookup} from "./TestFacetLookup.t.sol";
import {ERC725YFacet} from "../../contracts/facets/ERC725YFacet.sol";
import {LSP7DigitalAssetFacet} from "../../contracts/facets/LSP7DigitalAssetFacet.sol";
import {OwnershipFacet} from "../../contracts/facets/OwnershipFacet.sol";
import {IERC725Y} from "@erc725/smart-contracts/contracts/interfaces/IERC725Y.sol";
import {LSP0ERC725Account} from "@lukso/lsp-smart-contracts/contracts/LSP0ERC725Account/LSP0ERC725Account.sol";
import {LSP1UniversalReceiverDelegateUP} from "@lukso/lsp-smart-contracts/contracts/LSP1UniversalReceiver/LSP1UniversalReceiverDelegateUP/LSP1UniversalReceiverDelegateUP.sol";
import {UniversalProfile} from "@lukso/lsp-smart-contracts/contracts/UniversalProfile.sol";
import {XPLSP7TokenFacet} from "../../contracts/facets/XPLSP7TokenFacet.sol";

contract TestBondingCurveFacet is Test, Helper, TestFacetLookup {
    bytes32 constant _LSP1_UNIVERSAL_RECEIVER_DELEGATE_KEY = 0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47;
    Diamond diamond;
    Diamond xpToken;
    ERC725YFacet erc725yFacet;
    XPLSP7TokenFacet xpFacet;
    LSP7DigitalAssetFacet lsp7Facet;
    OwnershipFacet ownershipFacet;
    LSP1UniversalReceiverDelegateUP universalReceiverDelegate;
    address alice = makeAddr("alice");

    function setUp() public {
        BlankDiamond blank = new BlankDiamond();
        erc725yFacet = new ERC725YFacet();
        lsp7Facet = new LSP7DigitalAssetFacet();
        xpFacet = new XPLSP7TokenFacet();
        ownershipFacet = new OwnershipFacet();
        universalReceiverDelegate = new LSP1UniversalReceiverDelegateUP();

        diamond = blank.makeBlankDiamondWithLoupe(alice);
        xpToken = blank.makeBlankDiamond(alice);

        vm.startPrank(alice);
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);
        cuts[0] = makeCut(address(erc725yFacet), facetNameLookup["ERC725YFacet"]);
        cuts[1] = makeCut(address(lsp7Facet), facetNameLookup["LSP7DigitalAssetFacet"]);
        cuts[2] = makeCut(address(ownershipFacet), facetNameLookup["OwnershipFacet"]);
        // cuts[0] = makeCut(address(multicallFacet), facetNameLookup["BondingCurveFacet"]);
        IDiamondCut(address(diamond)).diamondCut(cuts, address(0), new bytes(0));

        cuts[1] = makeCut(address(xpFacet), facetNameLookup["XPLSP7TokenFacet"]);
        IDiamondCut(address(xpToken)).diamondCut(cuts, address(0), new bytes(0));

        vm.stopPrank();
    }

    function testTokenIsMintableToAccounts() public {
        address addr = address(diamond);
        // LSP7DigitalAssetFacet(addr).setName(bytes("XP"));
        // LSP7DigitalAssetFacet(addr).setSymbol(bytes("XP"));
        address bob = makeAddr("bob");
        LSP0ERC725Account account = new LSP0ERC725Account(bob);
        UniversalProfile up = new UniversalProfile(bob);
        //vm.prank(bob);
        // TODO note the universal receiver works but doens't because LSP20 will fail
        //  IERC725Y(address(account)).setData(_LSP1_UNIVERSAL_RECEIVER_DELEGATE_KEY, abi.encodePacked(universalReceiverDelegate));
        // vm.prank(bob);
        // IERC725Y(address(up)).setData(_LSP1_UNIVERSAL_RECEIVER_DELEGATE_KEY, abi.encodePacked(universalReceiverDelegate));

        vm.startPrank(alice);
        LSP7DigitalAssetFacet(addr).mint(address(up), 100, false, "a");
        LSP7DigitalAssetFacet(addr).mint(address(account), 100, false, "f");
        assertEq(200, LSP7DigitalAssetFacet(addr).totalSupply());

        // Received asset TODO note this is failing because of the LSP20 transfer issue
        /* bytes memory result = IERC725Y(address(account)).getData(0x6460ee3c0aac563ccbf76d6e1d07bada78e3a9514e6382b736ed3f478ab7b90b);
        console.logBytes(result);
        result = IERC725Y(address(up)).getData(0x6460ee3c0aac563ccbf76d6e1d07bada78e3a9514e6382b736ed3f478ab7b90b);
        console.logBytes(result);
        */
        vm.stopPrank();
    }
}
