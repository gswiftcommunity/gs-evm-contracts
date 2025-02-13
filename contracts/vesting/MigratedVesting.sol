// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MigratedVesting is Ownable {
    using SafeERC20 for IERC20;

    error TransferFailed();
    error InsufficientAmount();
    error InvalidTimeRanges();
    error NothingToRelease();
    error ArraysLengthMismatch();

    event UpdateFee(uint256 newFee, uint256 oldFee);
    event TokensReleased(uint256 amount, address user);
    event WalletFrozen(address wallet, bool frozen);
    event WalletRegistered(
        address wallet,
        uint256 initialAmount,
        uint256 vestedAmount
    );

    IERC20 public immutable token;

    uint256 public ethFee;
    uint256 public startDate;
    uint256 public endDate;

    mapping(address => uint256) internal _initialDistribution;
    mapping(address => uint256) internal _totalReleased;
    mapping(address => uint256) internal _userTotal;
    mapping(address => bool) internal _frozenWallets;

    modifier takeFee() {
        uint256 value = msg.value;
        if (ethFee > value) {
            revert InsufficientAmount();
        }
        uint256 rest = value - ethFee;

        if (rest != 0) {
            _transferNative(msg.sender, rest);
        }
        _;
    }

    constructor(
        IERC20 token_,
        uint256 ethFee_,
        uint256 startDate_,
        uint256 endDate_
    ) Ownable() {
        ethFee = ethFee_;
        startDate = startDate_;
        if (startDate_ > endDate_) {
            revert InvalidTimeRanges();
        }
        endDate = endDate_;
        token = token_;
    }

    function updateEthFee(uint256 _newFee) external onlyOwner {
        uint256 oldFee = ethFee;
        ethFee = _newFee;
        emit UpdateFee(_newFee, oldFee);
    }

    function userTotal(address userAddress) public view returns (uint256) {
        return _userTotal[userAddress];
    }

    function initialDistribution(address wallet) public view returns (uint256) {
        return _initialDistribution[wallet];
    }

    function release() external payable takeFee {
        uint256 unreleased = releasableAmount(msg.sender);

        if (unreleased == 0) {
            revert NothingToRelease();
        }

        _totalReleased[msg.sender] = _totalReleased[msg.sender] + unreleased;

        token.safeTransfer(msg.sender, unreleased);

        emit TokensReleased(unreleased, msg.sender);
    }

    function setWalletFrozen(
        address[] calldata wallets,
        bool[] calldata frozen
    ) external onlyOwner {
        uint256 length = wallets.length;

        if (length != frozen.length) {
            revert ArraysLengthMismatch();
        }

        for (uint256 i = 0; i < length; i++) {
            address wallet = wallets[i];
            bool value = frozen[i];

            _frozenWallets[wallet] = value;

            emit WalletFrozen(wallet, value);
        }
    }

    function withdrawToken(
        IERC20 token_,
        address to,
        uint256 amount
    ) external onlyOwner {
        token_.safeTransfer(to, amount);
    }

    function withdrawNative(address to, uint256 amount) external onlyOwner {
        if (address(this).balance < amount) {
            revert InsufficientAmount();
        }
        _transferNative(to, amount);
    }

    function setUserAllocation(
        address[] calldata wallets,
        uint256[] calldata initialAmounts,
        uint256[] calldata totalVestedAmounts
    ) external onlyOwner {
        uint256 length = wallets.length;

        if (
            length != initialAmounts.length ||
            length != totalVestedAmounts.length
        ) {
            revert ArraysLengthMismatch();
        }

        for (uint256 i = 0; i < length; i++) {
            address wallet = wallets[i];
            uint256 initialAmount = initialAmounts[i];
            uint256 totalVestedAmount = totalVestedAmounts[i];

            _initialDistribution[wallet] = initialAmount;
            _userTotal[wallet] = totalVestedAmount;

            emit WalletRegistered(wallet, initialAmount, totalVestedAmount);
        }
    }

    function isWalletFrozen(address wallet) public view returns (bool) {
        return _frozenWallets[wallet];
    }

    function releasableAmount(address wallet) public view returns (uint256) {
        if (block.timestamp < startDate) {
            return 0;
        }
        if (isWalletFrozen(wallet)) {
            return 0;
        }

        return
            vestedAmount(wallet) +
            initialDistribution(wallet) -
            tokensReleased(wallet);
    }

    function tokensReleased(address wallet) public view returns (uint256) {
        return _totalReleased[wallet];
    }

    function vestedAmount(address wallet) public view returns (uint256) {
        if (block.timestamp < startDate) {
            return 0;
        }

        if (isWalletFrozen(wallet)) {
            return 0;
        }

        uint256 totalTokens = userTotal(wallet);
        uint256 vestedTo = block.timestamp > endDate
            ? endDate
            : block.timestamp;

        uint256 elapsedTime = vestedTo - startDate;
        uint256 totalVestingTime = endDate - startDate;

        return (totalTokens * elapsedTime) / totalVestingTime;
    }

    function _transferNative(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }
}
