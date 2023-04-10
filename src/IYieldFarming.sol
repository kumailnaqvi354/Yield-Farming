// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface IYieldFarming {

error InsufficientBalance();
error approvalError();
error stakingNotStarted();
error zeroValuesNotAllowed();
error NoStaking();
error InvalidUser();
 
    struct poolDetail {
        uint256 poolId;
        uint256 rewardRate; 
        uint256 totalAwardDistributed;
        uint256 maxReward;   
    }
    struct userStakeDetail {
        uint256 stakeTime;
        uint256 pool;
        uint256 amount;
    }

     function stakeTokens(uint256 _amount) external returns(bool isStaked);
     function createPool(uint256 _maxReward, uint256 _rewardRate) external;
     

}

