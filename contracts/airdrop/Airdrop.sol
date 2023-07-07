// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Lockdrop.sol";
import "./IUniswapV2Pair.sol";

contract Airdrop is Ownable {
    IERC20 public token;
    LockdropPhase1 public lockdropPhase1;
    address public pairAddress;
    bytes32 public merkleRoot;
    mapping(address => uint256) public claimedAmounts;
    mapping(address => uint256) private totalEntitlements;

    uint256 public firstAirdropDate;
    uint256 public secondAirdropDate;
    uint256 public thirdAirdropDate;
    uint256 public finalAirdropDate;

    event NewMerkleRoot(address user, bytes32 merkleRoot);
    event NewLockdrop(address user, address lockdropAddress);
    event NewPairAddress(address user, address pairAddress);

    constructor(address _token, bytes32 _merkleRoot, uint256 _firstAirdropDate, uint256 _secondAirdropDate, uint256 _thirdAirdropDate, uint256 _finalAirdropDate) {
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        firstAirdropDate = _firstAirdropDate;
        secondAirdropDate = _secondAirdropDate;
        thirdAirdropDate = _thirdAirdropDate;
        finalAirdropDate = _finalAirdropDate;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
        emit NewMerkleRoot(msg.sender, _merkleRoot);
    }

    function setLockdropAddress(address _lockdropAddress) external onlyOwner {
        lockdropPhase1 = LockdropPhase1(_lockdropAddress);
        emit NewLockdrop(msg.sender, _lockdropAddress);
    }

    function setPairAddress(address _pairAddress) external onlyOwner {
        pairAddress = _pairAddress;
        emit NewPairAddress(msg.sender, _pairAddress);
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

        totalEntitlements[msg.sender] = airdropAmount;
        uint256 claimableAmount = getClaimableAmount(msg.sender);

        require(claimableAmount > 0, "No claimable amount.");
        claimedAmounts[msg.sender] += claimableAmount;
        require(token.transfer(msg.sender, claimableAmount), "Airdrop transfer failed.");
    }

    function getClaimableAmount(address _address) public view returns (uint256) {
        uint256 totalEntitled = totalEntitlements[_address];
        uint256 alreadyClaimed = claimedAmounts[_address];
        uint256 lockdropBonus = getGSTokenLocked(_address);

        uint256 claimable = 0;
        if (block.timestamp < firstAirdropDate) {
            return claimable;
        } else if (block.timestamp < secondAirdropDate) {
            claimable = totalEntitled * 50 / 100;
        } else if (block.timestamp < thirdAirdropDate) {
            claimable = totalEntitled * 665 / 1000;
        } else if (block.timestamp < finalAirdropDate) {
            claimable = totalEntitled * 83 / 100;
        } else {
            claimable = totalEntitled;
        }

        claimable += lockdropBonus;

        if (claimable > totalEntitled) {
            claimable = totalEntitled;
        }

        return claimable > alreadyClaimed ? claimable - alreadyClaimed : 0;
    }

    function isGsTokenReserve0(address _pairAddress) internal view returns (bool) {
        IUniswapV2Pair pair = IUniswapV2Pair(_pairAddress);
        return pair.token0() == address(token);
    }

    function getTokenNumberFromLp(address _pairAddress, uint lpAmount) internal view returns (uint tokenAmount) {
        IUniswapV2Pair pair = IUniswapV2Pair(_pairAddress);
        uint totalLpTokens = pair.totalSupply();
        (uint reserve0, uint reserve1,) = pair.getReserves();

        if (isGsTokenReserve0(_pairAddress)) {
            return lpAmount * reserve0 * 2 / totalLpTokens;
        }
        return lpAmount * reserve1 * 2 / totalLpTokens;
    }

    function getLock(address checkedAddress) internal view returns (uint tokenAmount) {
        uint256 allocationsCount = lockdropPhase1.userAllocationsCount(checkedAddress);
        uint256 lockedTokens;
        for (uint i = 1; i <= allocationsCount; i++) {
            (bool taken,IUniswapV2Pair pairToken,,uint256 value,,) = lockdropPhase1.userAllocations(checkedAddress, i);

            if (address(pairToken) == pairAddress && !taken) {
                lockedTokens += value;
            }
        }
        return lockedTokens;
    }

    function getGSTokenLocked(address checkedAddress) public view returns (uint tokenAmount){
        if (address(lockdropPhase1) == address(0) || pairAddress == address(0)) {
            return 0;
        }
        uint256 lockedLp = getLock(checkedAddress);
        return getTokenNumberFromLp(pairAddress, lockedLp);
    }
}