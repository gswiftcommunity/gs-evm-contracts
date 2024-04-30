// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AirdropSH is Ownable {

    uint256 public constant LP_Multiplier_DIVIDER = 1000000000000000000;

    IERC20 public token;
    bytes32 public merkleRoot;
    mapping(address => bool) public userClaimed;
    mapping(address => uint256) public userClaimedAmount;

    uint256 public firstAirdropDate;
    uint256 public ethFee = 250000000000000;

    event NewMerkleRoot(address user, bytes32 merkleRoot);
    event Withdraw(address user, uint256 amount);
    event WithdrawEth(address user, uint256 amount);
    event Claim(address user, uint256 amount);
    event UpdateFee(uint256 newFee, uint256 oldFee);

    error WithdrawFailed();
    error TransferFailed();

    modifier checkEthFeeAndRefundDust(uint256 value) {
        require(value >= ethFee, "Insufficient fee: the required fee must be covered");
        uint256 dust = value - ethFee;
        if (dust > 0) {
            (bool sent,) = address(msg.sender).call{value : dust}("");
            require(sent, "Failed to return overpayment");
        }
        _;
    }

    constructor(address _token, bytes32 _merkleRoot, uint256 _firstAirdropDate) {
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        firstAirdropDate = _firstAirdropDate;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
        emit NewMerkleRoot(msg.sender, _merkleRoot);
    }

    function claim(uint256 airdropAmount, bytes32[] calldata merkleProof) external payable checkEthFeeAndRefundDust(msg.value) {
        require(!userClaimed[msg.sender], "Already claimed");
        bytes32 node = keccak256(
            abi.encodePacked(msg.sender, airdropAmount)
        );
        bool isValidProof = MerkleProof.verifyCalldata(
            merkleProof,
            merkleRoot,
            node
        );
        require(isValidProof, 'Invalid merkle proof.');
        require(airdropAmount > 0, "No claimable amount.");
        userClaimed[msg.sender] = true;
        userClaimedAmount[msg.sender] = airdropAmount;
        require(token.transfer(msg.sender, airdropAmount), "Airdrop transfer failed.");
        emit Claim(msg.sender, airdropAmount);
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

        (bool success,) = payable(msg.sender).call{value : amount}("");
        if (!success) {
            revert WithdrawFailed();
        }
        emit WithdrawEth(msg.sender, amount);
    }

    function updateEthClaimFee(uint256 _newFee) external onlyOwner {

        uint256 oldFee = ethFee;
        ethFee = _newFee;
        emit UpdateFee(_newFee, oldFee);
    }
}