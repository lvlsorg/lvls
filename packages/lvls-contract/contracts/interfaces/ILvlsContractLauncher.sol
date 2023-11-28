// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

interface ILvlsContractLauncher {
    function setXPFacetCuts(IDiamondCut.FacetCut[] calldata _xpFacetCuts) external;

    function setLXPFacetCuts(IDiamondCut.FacetCut[] calldata _lxpFacetCuts) external;

    function setLvlsFacetCuts(IDiamondCut.FacetCut[] calldata _lvlsFacetCuts) external;

    function setRewardFacetCuts(IDiamondCut.FacetCut[] calldata _rewardTokenFacetCuts) external;

    function setDiamondAddresses(address diamondCutAddress, address diamondLoupe, address diamondInit) external;

    function launchRewardToken(address owner) external returns (address);

    function launch(address owner) external returns (address, address, address);

    function getContracts(uint256 offset, uint256 limit, bool asc) external view returns (address[] memory, uint256, uint256);

    function getContractsByOwner(address owner, uint256 offset, uint256 limit, bool asc) external view returns (address[] memory, uint256, uint256);

    function getFee() external view returns (uint256);

    function setFee(uint256 _minFee, uint256 _maxfee, uint256 multiplier) external;

    event Launch(address indexed addr, address indexed owner);

    event LaunchReward(address indexed addr, address indexed owner);
}
