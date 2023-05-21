import {LibDecayStaking} from "../libraries/LibDecayStaking.sol";
import {LibOwnership} from "../libraries/LibOwnership.sol";
import {ILSP7DigitalAsset} from "../interfaces/ILSP7DigitalAsset.sol";
import {ILSP7XP} from "../interfaces/ILSP7XP.sol";
import "hardhat/console.sol";

contract SoulboundDecayStakingFacet {
    function setDecayStaking(
        uint256 _exchangeRate,
        uint256 _penaltyRate,
        address _xpTokenAddress,
        address _lxpTokenAddress,
        address _rewardTokenAddress
    ) public onlyOwner {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        ds._exchangeRate = _exchangeRate;
        ds._penaltyRate = _penaltyRate;
        ds._xpTokenAddress = _xpTokenAddress;
        ds._lxpTokenAddress = _lxpTokenAddress;
        ds._rewardTokenAddress = _rewardTokenAddress;
    }

    function _distributeXP(address account, uint256 amount) internal {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        ILSP7DigitalAsset token = ILSP7DigitalAsset(ds._rewardTokenAddress);
        // authorize rewards token  TODO be careful here with front running etc...
        // as well as long standing approvals
        uint256 authorizedAmount = token.authorizedAmountFor(address(this), _msgSender());
        uint256 tokenAmount = (amount * ds._exchangeRate) / 1000;
        console.log("tokenAmount", tokenAmount);
        console.log("authorizeAmount", authorizedAmount);
        console.log("who", _msgSender());
        console.log("this addr", address(this));
        if (authorizedAmount < tokenAmount) revert("Insufficient authorized amount");
        // Transfer the tokens
        token.transfer(_msgSender(), address(this), tokenAmount, true, "");
        ILSP7XP(ds._xpTokenAddress).mint(account, amount, true, "");
        ILSP7DigitalAsset(ds._lxpTokenAddress).mint(account, amount, true, "");
    }

    function burnXP(uint256 tokenAmount) public {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        uint256 authorizedAmount = ILSP7XP(ds._xpTokenAddress).authorizedAmountFor(address(this), _msgSender());
        if (authorizedAmount < tokenAmount) revert("Insufficient authorized token Amount");
        ILSP7XP token = ILSP7XP(ds._xpTokenAddress);
        // here we reduce the virtual balance of the account by the amount of tokens burned
        // to calculate the exchange rate fee or the penalty fee
        uint256 decayedTokens = token.inactiveVirtualBalanceOf(_msgSender());
        uint256 liveTokens = token.activeVirtualBalanceOf(_msgSender());
        uint256 rewardTokens = (tokenAmount * ds._exchangeRate) / 1000;
        if (tokenAmount > decayedTokens) {
            uint256 penaltyAmount = tokenAmount - decayedTokens;
            uint256 penaltyFee = (penaltyAmount * ds._penaltyRate) / 1000;
            uint256 exchangeRateFee = (penaltyAmount * ds._exchangeRate) / 1000;
            uint256 totalFee = penaltyFee + exchangeRateFee;
            token.burn(_msgSender(), tokenAmount, "");
            if (rewardTokens < totalFee) revert("Insufficient reward tokens");
            ILSP7DigitalAsset(ds._rewardTokenAddress).transfer(address(this), _msgSender(), rewardTokens - totalFee, true, "");
        } else {
            token.burn(_msgSender(), tokenAmount, "");
            ILSP7DigitalAsset(ds._rewardTokenAddress).transfer(address(this), _msgSender(), rewardTokens, true, "");
        }
    }

    function distributeXP(address account, uint256 amount) public onlyOwner {
        _distributeXP(account, amount);
    }

    function exchangeRate() public view returns (uint256) {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        return ds._exchangeRate;
    }

    function penaltyRate() public view returns (uint256) {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        return ds._penaltyRate;
    }

    function xpTokenAddress() public view returns (address) {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        return ds._xpTokenAddress;
    }

    function setExchangeRate(uint256 _exchangeRate) public {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        ds._exchangeRate = _exchangeRate;
    }

    function setPenaltyRate(uint256 _penaltyRate) public {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        ds._penaltyRate = _penaltyRate;
    }

    function setXPTokenAddress(address _xpTokenAddress) public {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        ds._xpTokenAddress = _xpTokenAddress;
    }

    function setRewardTokenAddress(address _rewardTokenAddress) public {
        LibDecayStaking.DecayStakingStorage storage ds = LibDecayStaking.decayStakingStorage();
        ds._rewardTokenAddress = _rewardTokenAddress;
    }

    modifier onlyOwner() {
        LibOwnership.OwnershipStorage storage ds = LibOwnership.diamondStorage();
        require(ds.contractOwner == _msgSender(), "only owner");
        _;
    }

    function _msgSender() internal view returns (address sender) {
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
}
