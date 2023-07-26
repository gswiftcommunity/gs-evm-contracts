// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FixedVestingCliff is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public constant VESTING_DIVIDER = 100000;
    uint256 public constant YEAR_DIVIDER = 31556952;

    struct Config {
        uint256 tgeDate;
        uint256 startDate;
        uint256 endDate;
        uint256 ethFee;
        IERC20 token;
    }

    struct RewardPeriod {
        uint256 start;
        uint256 rate;
    }

    Config public config;
    mapping(address => uint256) public tokensReleased;
    mapping(address => uint256) public userTotal;
    mapping(address => bool) public freezeUsers;
    mapping(address => uint256) public stakingRewardsReleased;
    RewardPeriod[] public rewardPeriods;

    event TokensReleased(uint256 amount, address user);
    event Withdraw(address user, uint256 amount);
    event WithdrawEth(address user, uint256 amount);
    event UpdateFee(uint256 newFee);
    event StakingRewardClaimed(address indexed user, uint256 amount);
    event FreezeAccount(address indexed user);

    error TransferFailed();
    error WithdrawFailed();

    modifier checkEthFeeAndRefundDust(uint256 value) {
        require(value >= config.ethFee, "Insufficient fee: the required fee must be covered");
        uint256 dust = value - config.ethFee;
        (bool sent,) = address(msg.sender).call{value : dust}("");
        require(sent, "Failed to return overpayment");
        _;
    }

    modifier accountNotFrozen() {
        require(!freezeUsers[msg.sender], "Account frozen");
        _;
    }

    constructor(
        uint256 _tgeDate,
        uint256 _startTime,
        uint256 _endTime,
        address _tokenAddress,
        uint256 _rewardRate,
        uint256 _ethFee
    ) {
        require(_startTime >= _tgeDate, "Start time must be greater than tge time");
        require(_endTime > _startTime, "End time must be greater than start time");
        require(_tokenAddress != address(0), "Token address cannot be zero address");

        config.startDate = _startTime;
        config.endDate = _endTime;
        config.token = IERC20(_tokenAddress);
        config.ethFee = _ethFee;
        rewardPeriods.push(RewardPeriod(_tgeDate, _rewardRate));

    }

    function release() accountNotFrozen external payable {
        uint256 unreleased = releasableAmount(msg.sender);
        require(unreleased > 0, "No tokens to release");
        require(msg.value >= config.ethFee, "Insufficient fee: the required fee must be covered");

        tokensReleased[msg.sender] = tokensReleased[msg.sender].add(unreleased);
        if (
            !config.token.transfer(msg.sender, unreleased)
        ) {
            revert TransferFailed();
        }

        uint256 dust = msg.value - config.ethFee;
        (bool sent,) = address(msg.sender).call{value : dust}("");
        require(sent, "Failed to return overpayment");

        emit TokensReleased(unreleased, msg.sender);
    }

    function releasableAmount(address userAddress) public view returns (uint256) {
        if (freezeUsers[userAddress]) {
            return 0;
        }

        if (block.timestamp < config.startDate) {
            return 0;
        }

        uint256 totalTokens = userTotal[userAddress];

        if (block.timestamp > config.endDate) {
            return totalTokens.sub(tokensReleased[userAddress]);
        }

        uint256 elapsedTime = block.timestamp.sub(config.startDate);
        uint256 totalVestingTime = config.endDate.sub(config.startDate);
        uint256 vestedAmount = totalTokens.mul(elapsedTime).div(totalVestingTime);
        return vestedAmount.sub(tokensReleased[userAddress]);
    }

    function withdrawToken(IERC20 token, uint256 amount) external onlyOwner {

        if (
            !token.transfer(owner(), amount)
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

        config.ethFee = _newFee;
        emit UpdateFee(_newFee);
    }

    function registerVestingAccounts(address[] memory _userAddresses, uint256[] memory _amounts) external onlyOwner {
        require(_amounts.length == _userAddresses.length, "Amounts and userAddresses must have the same length");

        for (uint i = 0; i < _userAddresses.length; i++) {
            userTotal[_userAddresses[i]] = _amounts[i];
        }
    }

    function freezeVestingAccount(address _userAddress, bool _freeze) external onlyOwner {
        freezeUsers[_userAddress] = _freeze;

        emit FreezeAccount(_userAddress);
    }

    function setRewardRate(uint256 _rate) external onlyOwner {
        rewardPeriods.push(RewardPeriod(block.timestamp, _rate));
    }


    function getStakingRewards(address _userAddress) public view returns (uint256){
        if (block.timestamp < rewardPeriods[0].start) {
            return 0;
        }
        uint256 userReward;

        for (uint256 i = 0; i < rewardPeriods.length; i++) {

            if (i == rewardPeriods.length - 1) {
                uint256 elapsedTime = block.timestamp < config.startDate ? block.timestamp - rewardPeriods[i].start : config.startDate - rewardPeriods[i].start;
                userReward += userTotal[_userAddress] * elapsedTime * rewardPeriods[i].rate / VESTING_DIVIDER / YEAR_DIVIDER;
            } else {
                uint256 duration = rewardPeriods[i + 1].start - rewardPeriods[i].start;
                userReward += userTotal[_userAddress] * duration * rewardPeriods[i].rate / VESTING_DIVIDER / YEAR_DIVIDER;
            }
        }

        return userReward;
    }

    function claimStakingRewards() public payable checkEthFeeAndRefundDust(msg.value) nonReentrant accountNotFrozen {
        uint256 claimableRewards = getStakingRewards(msg.sender) - stakingRewardsReleased[msg.sender];

        if (claimableRewards == 0) {
            revert();
        }

        stakingRewardsReleased[msg.sender] += claimableRewards;
        require(config.token.transfer(msg.sender, claimableRewards), "Claim transfer failed.");
        emit StakingRewardClaimed(msg.sender, claimableRewards);
    }
}