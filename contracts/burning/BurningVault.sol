// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract BurningVault {
    address public admin;
    IERC20 public token;

    mapping(address => uint256) public deposits;

    event Deposited(address indexed user, uint256 amount);
    event WithdrawForBurning(uint256 amount);

    constructor(address _tokenAddress) {
        admin = msg.sender;
        token = IERC20(_tokenAddress);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    function depositTokensToBurn(uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed.");

        deposits[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function withdrawForBurning() external onlyAdmin {
        uint256 contractBalance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, contractBalance), "Transfer to burn address failed.");
        emit WithdrawForBurning(contractBalance);
    }
}