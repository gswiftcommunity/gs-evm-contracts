// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FixedStaking is Ownable, ReentrancyGuard {
    struct UserInfo {
        uint256 lastStakeTime;
        uint256 amount;
        uint256 waitingRewards;
        UnbondInfo[] unbondings;
    }

    struct UnbondInfo {
        uint256 amount;
        uint256 release;
    }

    struct RewardPeriod {
        uint256 start;
        uint256 rate;
    }

    uint256 public constant RATE_DIVIDER = 100_000;
    uint256 public constant YEAR_DIVIDER = 31556952;

    IERC20 immutable public token;
    RewardPeriod[] public rewardPeriods;
    mapping(address => UserInfo) public userInfo;
    uint256 public totalStaked;
    uint256 public unbondLimit = 5;
    uint256 public unbondTime = 7 days;
    uint256 private ethFee;

    event StakeStarted(address indexed user, uint256 amount);
    event UnstakeStarted(address indexed user, uint256 amount);
    event UnstakeFinished(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event Restaked(address indexed user, uint256 amount);
    event UnbondTimeUpdated(uint256 daysNumber);
    event Withdraw(address user, uint256 amount);
    event WithdrawEth(address user, uint256 amount);
    event UpdateFee(uint256 newFee, uint256 oldFee);

    error TransferFailed();
    error WithdrawFailed();

    modifier checkEthFeeAndRefundDust(uint256 value) {
        require(value >= ethFee, "Insufficient fee: the required fee must be covered");
        uint256 dust = unsafeSub(value, ethFee);
        if (dust != 0) {
            (bool sent,) = address(msg.sender).call{value : dust}("");
            require(sent, "Failed to return overpayment");
        }
        _;
    }

    constructor(IERC20 _token, uint256 _start, uint256 _rate, uint256 _ethFee) {
        token = _token;
        ethFee = _ethFee;
        rewardPeriods.push(RewardPeriod(_start, _rate));
    }

    function stake(uint256 _amount) external nonReentrant {
        require(token.transferFrom(msg.sender, address(this), _amount), "Stake transfer failed.");
        require(block.timestamp >= rewardPeriods[0].start, "Staking not stared.");

        totalStaked += _amount;
        UserInfo storage user = userInfo[msg.sender];
        if (user.amount != 0) {
            uint256 pending = calculateReward(msg.sender);
            if (pending != 0) {
                user.waitingRewards += pending;
            }
        }
        user.amount += _amount;
        user.lastStakeTime = block.timestamp;
        emit StakeStarted(msg.sender, _amount);
    }

    function pendingReward(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];

        uint256 pending = calculateReward(_user);
        return pending + user.waitingRewards;
    }


    function startUnstaking(uint256 _amount) external payable nonReentrant checkEthFeeAndRefundDust(msg.value) {
        UserInfo storage user = userInfo[msg.sender];
        require(_amount != 0, "Zero amount");
        require(user.unbondings.length < unbondLimit, "startUnstaking: limit reached");
        require(user.amount >= _amount, "startUnstaking: not enough staked amount");
        totalStaked -= _amount;
        uint256 pending = calculateReward(msg.sender);
        if (pending != 0) {
            user.waitingRewards += pending;
            user.lastStakeTime = block.timestamp;
        }
        user.amount = unsafeSub(user.amount, _amount);

        UnbondInfo memory newUnbond = UnbondInfo({
        amount : _amount,
        release : block.timestamp + unbondTime
        });

        user.unbondings.push(newUnbond);
        emit UnstakeStarted(msg.sender, _amount);
    }

    function finishUnstaking() external payable nonReentrant checkEthFeeAndRefundDust(msg.value) {
        UserInfo storage user = userInfo[msg.sender];
        uint256 releasedAmount;

        uint256 i;
        while (i < user.unbondings.length) {
            UnbondInfo storage unbonding = user.unbondings[i];
            if (unbonding.release <= block.timestamp) {
                releasedAmount += unbonding.amount;
                if (i != user.unbondings.length - 1) {
                    user.unbondings[i] = user.unbondings[user.unbondings.length - 1];
                }
                user.unbondings.pop();
            } else {
                i = unsafeInc(i);
            }
        }

        require(releasedAmount != 0, "Nothing to release");
        require(token.transfer(msg.sender, releasedAmount), "Finish unstaking transfer failed.");
        emit UnstakeFinished(msg.sender, releasedAmount);
    }

    function claim() external payable nonReentrant checkEthFeeAndRefundDust(msg.value) {
        UserInfo storage user = userInfo[msg.sender];
        uint256 pending = calculateReward(msg.sender) + user.waitingRewards;
        require(pending != 0, "claim: nothing to claim");
        user.waitingRewards = 0;
        user.lastStakeTime = block.timestamp;
        require(token.transfer(msg.sender, pending), "Claim transfer failed.");
        emit RewardClaimed(msg.sender, pending);
    }

    function restake() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 pending = calculateReward(msg.sender) + user.waitingRewards;
        require(pending != 0, "restake: nothing to restake");
        user.waitingRewards = 0;
        user.amount += pending;
        totalStaked += pending;
        user.lastStakeTime = block.timestamp;
        emit Restaked(msg.sender, pending);
    }

    function calculateReward(address _user) public view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        if (user.lastStakeTime == 0) {
            return 0;
        }
        uint256 reward;
        uint256 startIndex = 0;
        for (uint256 i = 0; i < rewardPeriods.length; i = unsafeInc(i)) {
            if (rewardPeriods[i].start < user.lastStakeTime) {
                startIndex = i;
            }
        }

        for (uint256 i = startIndex; i < rewardPeriods.length; i = unsafeInc(i)) {
            uint256 timeDelta;
            uint256 tempStart = rewardPeriods[i].start < user.lastStakeTime ? user.lastStakeTime : rewardPeriods[i].start;
            if (i < rewardPeriods.length - 1) {
                timeDelta = rewardPeriods[i + 1].start - tempStart;
                reward += user.amount * rewardPeriods[i].rate * timeDelta / YEAR_DIVIDER / RATE_DIVIDER;
            } else {
                timeDelta = block.timestamp - tempStart;
                reward += user.amount * rewardPeriods[i].rate * timeDelta / YEAR_DIVIDER / RATE_DIVIDER;
            }
        }
        return reward;
    }

    function getUserInfo(address _user) external view returns (uint256, uint256) {
        uint256 pending = pendingReward(_user);
        return (userInfo[_user].amount, pending);
    }

    function getUserUnbondings(address _user) external view returns (uint256[] memory, uint256[] memory) {
        UnbondInfo[] memory unbondings = userInfo[_user].unbondings;
        uint256[] memory amounts = new uint256[](unbondings.length);
        uint256[] memory releases = new uint256[](unbondings.length);

        for (uint i; i < unbondings.length; i = unsafeInc(i)) {
            amounts[i] = unbondings[i].amount;
            releases[i] = unbondings[i].release;
        }

        return (amounts, releases);
    }

    function setUnbondTimeInDays(uint256 _days) external onlyOwner {
        require(_days < 100, "setUnbondTimeInDays: over 100 days");
        unbondTime = _days * 1 days;
        emit UnbondTimeUpdated(_days);
    }

    function setRate(uint256 _rate) external onlyOwner {
        rewardPeriods.push(RewardPeriod(block.timestamp, _rate));
    }

    function withdrawToken(IERC20 _token, uint256 amount) external onlyOwner {

        if (
            !_token.transfer(msg.sender, amount)
        ) {
            revert TransferFailed();
        }

        emit Withdraw(msg.sender, amount);
    }

    function withdrawEth(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success,) = payable(msg.sender).call{value : amount}("");
        if (!success) {
            revert WithdrawFailed();
        }
        emit WithdrawEth(msg.sender, amount);
    }

    function updateEthFee(uint256 _newFee) external onlyOwner {
        uint256 oldFee = ethFee;
        ethFee = _newFee;
        emit UpdateFee(_newFee, oldFee);
    }

    function unsafeInc(uint x) private pure returns (uint) {
    unchecked {return x + 1;}
    }

    function unsafeSub(uint x, uint y) private pure returns (uint) {
    unchecked {return x - y;}
    }
}