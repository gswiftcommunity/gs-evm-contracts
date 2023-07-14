// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUniswapV2Pair.sol";

    struct UserAllocation {
        bool taken;
        IUniswapV2Pair token;
        uint32 unlockTimestampIndex;
        uint256 lockingTimestamp;
        uint256 value;
        uint256 boost;
        uint256 points;
    }