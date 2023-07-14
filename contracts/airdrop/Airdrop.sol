// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Lockdrop.sol";
import "./IUniswapV2Pair.sol";
import "./UserAllocation.sol";

contract Airdrop is Ownable {

    uint256 public constant LP_Multiplier_DIVIDER = 1000000;

    IERC20 public token;
    LockdropPhase1 public lockdropPhase1;
    address public pairAddress;
    bytes32 public merkleRoot;
    mapping(address => uint256) public claimedAmounts;
    mapping(address => uint256) private totalUserAirdrop;

    uint256 public firstAirdropDate;
    uint256 public lockdropAirdropReleaseDate;

    uint256 public vestingStartDate;
    uint256 public vestingEndDate;
    uint256 public vestingDuration;

    uint256 public lpMultiplier;


    event NewMerkleRoot(address user, bytes32 merkleRoot);
    event NewMultiplier(address user, uint256 lpMultiplier);
    event NewLockdropAndPairAddress(address user, address lockdropAddress, address pairAddress);

    constructor(address _token, bytes32 _merkleRoot, uint256 _firstAirdropDate, uint256 _lockdropAirdropReleaseDate, uint256 _vestingStartDate, uint256 _vestingEndDate) {
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        firstAirdropDate = _firstAirdropDate;
        lockdropAirdropReleaseDate = _lockdropAirdropReleaseDate;
        vestingStartDate = _vestingStartDate;
        vestingEndDate = _vestingEndDate;
        vestingDuration = _vestingEndDate - _vestingStartDate;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
        emit NewMerkleRoot(msg.sender, _merkleRoot);
    }

    function setLpMultiplier(uint256 _lpMultiplier) external onlyOwner {
        lpMultiplier = _lpMultiplier;
        emit NewMultiplier(msg.sender, _lpMultiplier);
    }

    function setLockdropAddressAndPairAddress(address _lockdropAddress, address _pairAddress) external onlyOwner {
        lockdropPhase1 = LockdropPhase1(_lockdropAddress);
        pairAddress = _pairAddress;
        emit NewLockdropAndPairAddress(msg.sender, _lockdropAddress, _pairAddress);
    }

    function claim(uint256 airdropAmount, bytes32[] calldata merkleProof) public {
        bytes32 node = keccak256(
            abi.encodePacked(msg.sender, airdropAmount)
        );
        bool isValidProof = MerkleProof.verifyCalldata(
            merkleProof,
            merkleRoot,
            node
        );
        require(isValidProof, 'Invalid merkle proof.');

        totalUserAirdrop[msg.sender] = airdropAmount;
        uint256 claimableAmount = getClaimableAmount(msg.sender, totalUserAirdrop[msg.sender]);

        require(claimableAmount > 0, "No claimable amount.");
        claimedAmounts[msg.sender] += claimableAmount;
        require(token.transfer(msg.sender, claimableAmount), "Airdrop transfer failed.");
    }

    function getClaimableAmount(address _address, uint256 _totalAirdrop) public view returns (uint256) {
        uint256 totalEntitled = _totalAirdrop;
        uint256 alreadyClaimed = claimedAmounts[_address];
        uint256 halfOfAirdrop = totalEntitled / 2;

        uint256 claimable = 0;

        if (block.timestamp > vestingStartDate) {
            claimable += getVestedAmount(halfOfAirdrop);
        }

        if (block.timestamp > lockdropAirdropReleaseDate && lpMultiplier > 0) {
            uint256 userLpLock = getLock(_address);
            uint256 amountReq = halfOfAirdrop * lpMultiplier / LP_Multiplier_DIVIDER;

            if (userLpLock >= amountReq) {
                claimable += halfOfAirdrop;
            }
        }

        if (block.timestamp > firstAirdropDate) {
            claimable += halfOfAirdrop;
        }

        if (claimable > totalEntitled) {
            claimable = totalEntitled;
        }

        return claimable > alreadyClaimed ? claimable - alreadyClaimed : 0;
    }

    function getVestedAmount(uint256 amountToVest) internal view returns (uint256) {
        if (block.timestamp < vestingStartDate) {
            return 0;
        } else if (block.timestamp >= vestingEndDate) {
            return amountToVest;
        } else {
            uint256 elapsedTime = block.timestamp - vestingStartDate;
            return amountToVest * elapsedTime / vestingDuration;
        }
    }

    function getLock(address checkedAddress) public view returns (uint tokenAmount) {
        if (address(lockdropPhase1) == address(0) || pairAddress == address(0)) {
            return 0;
        }

        uint256 lockedTokens;
        UserAllocation[] memory allocations = lockdropPhase1.getUserAllocations(checkedAddress);

        for (uint i = 0; i < allocations.length; i++) {
            if (address(allocations[i].token) == pairAddress && !allocations[i].taken) {
                lockedTokens += allocations[i].value;
            }
        }

        return lockedTokens;
    }
}