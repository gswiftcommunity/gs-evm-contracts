// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is Ownable, ReentrancyGuard {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 waitingRewards;
        UnbondInfo[] unbondings;
    }

    struct UnbondInfo {
        uint256 amount;
        uint256 release;
    }

    struct RewardPeriod {
        uint256 from;
        uint256 to;
        uint256 rewardRate;
        uint256 lastRewardTime;
        uint256 accRewardPerShare;
    }

    IERC20 public token;
    RewardPeriod public rewardPeriod;
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
    event UpdateFee(uint256 newFee);

    error TransferFailed();
    error WithdrawFailed();

    modifier checkEthFeeAndRefundDust(uint256 value) {
        require(value >= ethFee, "Insufficient fee: the required fee must be covered");
        uint256 dust = value - ethFee;
        (bool sent,) = address(msg.sender).call{value : dust}("");
        require(sent, "Failed to return overpayment");
        _;
    }

    constructor(IERC20 _token, uint256 _from, uint256 _to, uint256 _reward, uint256 _ethFee) {
        token = _token;
        ethFee = _ethFee;
        rewardPeriod = RewardPeriod({
        from : _from,
        to : _to,
        rewardRate : _reward / (_to - _from),
        lastRewardTime : _from,
        accRewardPerShare : 0
        });
    }

    function updatePool() public {
        if (block.timestamp <= rewardPeriod.lastRewardTime) {
            return;
        }
        if (totalStaked == 0) {
            rewardPeriod.lastRewardTime = block.timestamp;
            return;
        }

        if (block.timestamp < rewardPeriod.from || block.timestamp > rewardPeriod.to) {
            return;
        }

        uint256 multiplier = getMultiplier(rewardPeriod.lastRewardTime, block.timestamp);
        uint256 tokenReward = multiplier * rewardPeriod.rewardRate;
        rewardPeriod.accRewardPerShare += tokenReward * 1e12 / totalStaked;
        rewardPeriod.lastRewardTime = block.timestamp;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= rewardPeriod.from || _from >= rewardPeriod.to) {
            return 0;
        }
        if (_from < rewardPeriod.from) {
            _from = rewardPeriod.from;
        }
        if (_to > rewardPeriod.to) {
            _to = rewardPeriod.to;
        }
        return _to - _from;
    }

    function pendingReward(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 accRewardPerShare = rewardPeriod.accRewardPerShare;
        if (block.timestamp > rewardPeriod.lastRewardTime && totalStaked != 0) {
            uint256 multiplier = getMultiplier(rewardPeriod.lastRewardTime, block.timestamp);
            uint256 tokenReward = multiplier * rewardPeriod.rewardRate;
            accRewardPerShare += tokenReward * 1e12 / totalStaked;
        }
        return user.amount * accRewardPerShare / 1e12 + user.waitingRewards - user.rewardDebt;
    }

    function stake(uint256 _amount) public payable checkEthFeeAndRefundDust(msg.value) nonReentrant {
        require(token.transferFrom(msg.sender, address(this), _amount), "Stake transfer failed.");

        updatePool();
        totalStaked += _amount;
        UserInfo storage user = userInfo[msg.sender];
        if (user.amount != 0) {
            uint256 pending = user.amount * rewardPeriod.accRewardPerShare / 1e12 - user.rewardDebt;
            if (pending > 0) {
                user.waitingRewards += pending;
            }
        }
        user.amount += _amount;
        user.rewardDebt = user.amount * rewardPeriod.accRewardPerShare / 1e12;
        emit StakeStarted(msg.sender, _amount);
    }

    function startUnstaking(uint256 _amount) public payable checkEthFeeAndRefundDust(msg.value) nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.unbondings.length < unbondLimit, "startUnstaking: limit reached");
        require(user.amount >= _amount, "startUnstaking: not enough staked amount");
        totalStaked -= _amount;
        updatePool();
        uint256 pending = user.amount * rewardPeriod.accRewardPerShare / 1e12 - user.rewardDebt;
        if (pending > 0) {
            user.waitingRewards += pending;
        }
        user.amount -= _amount;
        user.rewardDebt = user.amount * rewardPeriod.accRewardPerShare / 1e12;

        UnbondInfo memory newUnbond = UnbondInfo({
        amount : _amount,
        release : block.timestamp + unbondTime
        });

        user.unbondings.push(newUnbond);
        emit UnstakeStarted(msg.sender, _amount);
    }

    function finishUnstaking() public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 releasedAmount;

        uint256 i = 0;
        while (i < user.unbondings.length) {
            UnbondInfo storage unbonding = user.unbondings[i];
            if (unbonding.release <= block.timestamp) {
                releasedAmount += unbonding.amount;
                if (i != user.unbondings.length - 1) {
                    user.unbondings[i] = user.unbondings[user.unbondings.length - 1];
                }
                user.unbondings.pop();
            } else {
                i++;
            }
        }

        require(releasedAmount > 0, "Nothing to release");
        require(token.transfer(msg.sender, releasedAmount), "Finish unstaking transfer failed.");
        emit UnstakeFinished(msg.sender, releasedAmount);
    }

    function claim() public payable checkEthFeeAndRefundDust(msg.value) nonReentrant {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        uint256 pending = user.amount * rewardPeriod.accRewardPerShare / 1e12 - user.rewardDebt + user.waitingRewards;
        require(pending > 0, "claim: nothing to claim");
        user.waitingRewards = 0;
        user.rewardDebt = user.amount * rewardPeriod.accRewardPerShare / 1e12;
        require(token.transfer(msg.sender, pending), "Claim transfer failed.");
        emit RewardClaimed(msg.sender, pending);
    }

    function restake() public payable checkEthFeeAndRefundDust(msg.value) nonReentrant {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        uint256 pending = user.amount * rewardPeriod.accRewardPerShare / 1e12 - user.rewardDebt + user.waitingRewards;
        require(pending > 0, "restake: nothing to restake");
        user.waitingRewards = 0;
        user.amount += pending;
        totalStaked += pending;
        user.rewardDebt = user.amount * rewardPeriod.accRewardPerShare / 1e12;
        emit Restaked(msg.sender, pending);
    }

    function getUserInfo(address _user) public view returns (uint256, uint256) {
        uint256 pending = pendingReward(_user);
        return (userInfo[_user].amount, pending);
    }

    function getUserUnbondings(address _user) public view returns (uint256[] memory, uint256[] memory) {
        UnbondInfo[] memory unbondings = userInfo[_user].unbondings;
        uint256[] memory amounts = new uint256[](unbondings.length);
        uint256[] memory releases = new uint256[](unbondings.length);

        for (uint i = 0; i < unbondings.length; i++) {
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

    function withdrawToken(IERC20 _token, uint256 amount) external onlyOwner {

        if (
            !_token.transfer(owner(), amount)
        ) {
            revert TransferFailed();
        }

        emit Withdraw(owner(), amount);
    }

    function withdrawEth(uint256 amount) external onlyOwner {

        (bool success,) = payable(owner()).call{value : amount}("");
        if (!success) {
            revert WithdrawFailed();
        }
        emit WithdrawEth(owner(), amount);
    }

    function updateEthFee(uint256 _newFee) external onlyOwner {

        ethFee = _newFee;
        emit UpdateFee(_newFee);
    }
}