import "./IUniswapV2Pair.sol";

contract LockdropPhase1 {
    struct UserAllocation {
        bool taken;
        IUniswapV2Pair token;
        uint32 unlockTimestampIndex;
        uint256 value;
        uint256 boost;
        uint256 points;
    }

    mapping(address => uint256) public userAllocationsCount;
    mapping(address => mapping(uint256 => UserAllocation)) public userAllocations;
    //    function userAllocations(address) external view returns (UserAllocation);
}