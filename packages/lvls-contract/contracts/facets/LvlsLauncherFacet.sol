pragma solidity ^0.8.15;

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {LibOwnership} from "../libraries/LibOwnership.sol";

import {ILvlsContractLauncher} from "../interfaces/ILvlsContractLauncher.sol";
import {ISoulboundDecayStaking} from "../interfaces/ISoulboundDecayStaking.sol";
import {IDiamondLauncher} from "../interfaces/IDiamondLauncher.sol";
import {LibLvlsContractLauncher, LibLvlsLauncherStorage} from "../libraries/LibLvlsLauncher.sol";

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {DiamondInit} from "../upgradeInitializers/DiamondInit.sol";
import {LibPagination} from "../libraries/LibPagination.sol";
import "hardhat/console.sol";

contract LvlsLauncherFacet is ILvlsContractLauncher {
    function setDiamondAddresses(address diamondCutAddress, address diamondLoupeAddress, address diamondInitAddress) public onlyOwner {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        ls.diamondCutAddress = diamondCutAddress;
        ls.diamondLoupeAddress = diamondLoupeAddress;
        ls.diamondInitAddress = diamondInitAddress;
    }

    function setLXPFacetCuts(IDiamondCut.FacetCut[] memory cuts) public onlyOwner {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        unchecked {
            uint256 limit = ls.lxpFacetCuts.length;
            for (uint16 i; i < limit; i++) {
                ls.lxpFacetCuts.pop();
            }
            limit = cuts.length;
            for (uint16 i; i < limit; i++) {
                ls.lxpFacetCuts.push(cuts[i]);
            }
        }
    }

    function setXPFacetCuts(IDiamondCut.FacetCut[] memory cuts) public onlyOwner {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        unchecked {
            uint256 limit = ls.xpFacetCuts.length;
            for (uint16 i; i < limit; i++) {
                ls.xpFacetCuts.pop();
            }
            limit = cuts.length;
            for (uint16 i; i < limit; i++) {
                ls.xpFacetCuts.push(cuts[i]);
            }
        }
    }

    function setLvlsFacetCuts(IDiamondCut.FacetCut[] memory cuts) public onlyOwner {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        unchecked {
            uint256 limit = ls.lvlsFacetCuts.length;
            for (uint16 i; i < limit; i++) {
                ls.lvlsFacetCuts.pop();
            }
            limit = cuts.length;
            for (uint16 i; i < limit; i++) {
                ls.lvlsFacetCuts.push(cuts[i]);
            }
        }
    }

    function getContractsByOwner(
        address contractOwner,
        uint256 offset,
        uint256 limit,
        bool asc
    ) public view returns (address[] memory, uint256, uint256) {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        return LibPagination.paginateData(ls.userAddressToLvlsContract[contractOwner], offset, limit, asc);
    }

    function getContracts(uint256 offset, uint256 limit, bool asc) public view returns (address[] memory, uint256, uint256) {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        return LibPagination.paginateData(ls.deployedContractAddresses, offset, limit, asc);
    }

    // This interface allows us to subscribe to
    function launch(address owner) public returns (address, address, address) {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        IDiamondLauncher diamond = IDiamondLauncher(
            IDiamondLauncher(address(this)).launch(address(this), ls.diamondCutAddress, ls.diamondLoupeAddress)
        );
        // NOTE there's no init function for the diamond, so we don't need to call it
        IDiamondCut(address(diamond)).diamondCut(ls.lvlsFacetCuts, address(ls.diamondInitAddress), new bytes(0));

        IDiamondLauncher xpDiamond = IDiamondLauncher(
            IDiamondLauncher(address(this)).launch(address(this), ls.diamondCutAddress, ls.diamondLoupeAddress)
        );

        IDiamondLauncher lxpDiamond = IDiamondLauncher(
            IDiamondLauncher(address(this)).launch(address(this), ls.diamondCutAddress, ls.diamondLoupeAddress)
        );

        IDiamondCut(address(xpDiamond)).diamondCut(ls.xpFacetCuts, address(ls.diamondInitAddress), new bytes(0));
        IDiamondCut(address(lxpDiamond)).diamondCut(ls.lxpFacetCuts, address(ls.diamondInitAddress), new bytes(0));

        IERC173(address(diamond)).transferOwnership(owner);
        // NOTE here we transfer this as the owner of the lvls frame work contract
        IERC173(address(xpDiamond)).transferOwnership(address(diamond));
        IERC173(address(lxpDiamond)).transferOwnership(address(diamond));

        ls.deployedContractAddresses.push(address(diamond));
        ls.userAddressToLvlsContract[owner].push((address(diamond)));
        emit Launch(address(diamond), owner);

        // TODO make these initialization params
        ISoulboundDecayStaking(address(diamond)).setXPTokenAddress(address(xpDiamond));
        ISoulboundDecayStaking(address(diamond)).setLXPTokenAddress(address(lxpDiamond));

        // NOTE here we return the address of the diamond, xpDiamond, and lxpDiamond
        return (address(diamond), address(xpDiamond), address(lxpDiamond));
    }

    function feePayment() public payable {}

    modifier onlyOwner() {
        LibOwnership.OwnershipStorage storage ds = LibOwnership.diamondStorage();
        require(ds.contractOwner == _msgSender(), "only owner");
        _;
    }

    function _msgSender() internal view virtual returns (address sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }

    // here we scale Fees based off of baseFee paid and a min and max fee
    function setFee(uint256 minFee, uint256 maxFee, uint256 multiplier) public override(ILvlsContractLauncher) onlyOwner {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        ls.minFee = minFee;
        ls.maxFee = maxFee;
        ls.feeMultiplier = multiplier;
    }

    function getFee() public view override(ILvlsContractLauncher) returns (uint256) {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        return (ls.minFee + ls.maxFee) / 2;
    }

    function getMaxFee() public view returns (uint256) {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        return ls.maxFee;
    }

    function getMinFee() public view returns (uint256) {
        LibLvlsLauncherStorage storage ls = LibLvlsContractLauncher.libLvlsLauncherStorage();
        return ls.minFee;
    }

    // restrict executeRemote to be called by the contractOnly
    // or can be called by ownerOnly for now we use the more
    // strict restriction of ownerOnly
    // this will prevent anyone from executing methods with contract
    // context without having proper permission context.
    function _executeRemote(address target, bytes memory callData) internal returns (bytes memory ret) {
        assembly {
            let ptr := callData
            let len := mload(ptr)
            // if any msg.value is found just shut it down to avoid any possible msg.value attacks
            if callvalue() {
                revert(0, 0)
            }
            // load free memory pointer
            let fp := mload(0x40)
            let result := call(gas(), target, 0, add(ptr, 0x20), len, 0, 0)
            // copy the size of the return data to the fp pointer
            mstore(fp, returndatasize())
            // copy the result of the data into the rest of the memory 32bytes after the fp pointer
            returndatacopy(add(fp, 0x20), 0, returndatasize())
            // update the freepointer to the end of the data
            mstore(0x40, add(add(fp, 0x20), returndatasize()))
            switch result
            case 0 {
                // return the error message
                revert(fp, returndatasize())
            }
            default {
                // return the data from the call assigning the fp pointer to the ret pointer
                ret := fp
            }
        }
    }
}
