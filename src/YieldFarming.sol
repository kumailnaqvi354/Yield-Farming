// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.16;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/utils/Counters.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/access/Ownable.sol";


error InsufficientBalance();
error approvalError();
error stakingNotStarted();
error zeroValuesNotAllowed();
contract YieldFarming is ReentrancyGuard, Ownable{
    
    address public immutable tokenAddress;
    
    uint256 private immutable startTime;
    uint256 public currentPool;
    
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
    mapping (address => userStakeDetail) userStake;
    mapping (uint256 => poolDetail) pools;
    
    constructor(address _rewardTokenAddress, uint256 _startTime) {
        tokenAddress = _rewardTokenAddress;
        startTime = _startTime;
    }

    function stakeTokens(uint256 _amount) external {
       
        if (IERC20(tokenAddress).balanceOf(msg.sender) <= _amount) returns(bool isStaked){
          revert InsufficientBalance();
        }
        if (IERC20(tokenAddress).allowance(msg.sender, address(this)) <= _amount) {
            revert approvalError();
        }
        if(startTime > block.timestamp) {
            revert stakingNotStarted();
        }

        userStakeDetail memory temp = userStake[msg.sender];
        temp.amount = _amount;
        temp.pool = currentPool;
        temp.stakeTime = block.timestamp;
        userStake[msg.sender] = temp;
      isStaked = IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);


    }

    function createPool(uint256 _maxReward, uint256 _rewardRate) external onlyOwner{
        if (_maxReward == 0 && _rewardRate == 0) {
            revert zeroValuesNotAllowed();
        }
        uint256 _poolId = currentPool + 1;
        poolDetail memory temp = pools[currentPool];
        temp.poolId = _poolId;
        temp.rewardRate = _rewardRate;
        temp.maxReward = _maxReward;
        pools[_poolId] = temp;
        currentPool = _poolId; 
    }
    
}