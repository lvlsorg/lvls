library LibDecayStaking {
    struct DecayStakingStorage {
        uint256 _exchangeRate;
        uint256 _penaltyRate;
        address _xpTokenAddress;
        address _lxpTokenAddress;
        address _rewardTokenAddress;
    }

    bytes32 constant DECAY_STAKING_STORAGE_POSITION = keccak256("lvls.decay_staking.storage");

    function decayStakingStorage() internal pure returns (DecayStakingStorage storage ds) {
        bytes32 position = DECAY_STAKING_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
