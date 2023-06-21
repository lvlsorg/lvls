pragma solidity ^0.8.15;

interface ISoulboundDecayStaking {
    function setDecayStaking(
        uint256 _exchangeRate,
        uint256 _penaltyRate,
        address _xpTokenAddress,
        address _lxpTokenAddress,
        address _rewardTokenAddress
    ) external;

    function _distributeXP(address account, uint256 amount) external;

    function burnXP(uint256 tokenAmount) external;

    function distributeXP(address account, uint256 amount) external;

    function exchangeRate() external view returns (uint256);

    function penaltyRate() external view returns (uint256);

    function xpTokenAddress() external view returns (address);

    function setExchangeRate(uint256 _exchangeRate) external;

    function setPenaltyRate(uint256 _penaltyRate) external;

    function setDecayRate(uint256 _decayRate) external;

    function setStakingConfig(uint256 _exchangeRate, uint256 _penaltyRate, uint256 _decayRate, address _rewardTokenAddress) external;

    function setXPTokenAddress(address _xpTokenAddress) external;

    function setLXPTokenAddress(address _lxpTokenAddress) external;

    function setRewardTokenAddress(address _rewardTokenAddress) external;
}
