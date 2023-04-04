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
error NoStaking();

contract YieldFarming is ReentrancyGuard, Ownable{
    
    address public immutable tokenAddress;
    
    uint256 private immutable startTime;
    uint256 public currentPool;
    string public name = "YIELD";
    
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
    mapping (address => userStakeDetail) public userStake;
    mapping (uint256 => poolDetail) public pools;
    
    constructor(address _rewardTokenAddress, uint256 _startTime) {
        tokenAddress = _rewardTokenAddress;
        startTime = _startTime;
    }

    function stakeTokens(uint256 _amount) external returns(bool isStaked){
       
        if (IERC20(tokenAddress).balanceOf(msg.sender) <= _amount) {
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

    function calculateReward(address _user) internal view returns(uint256) {
        userStakeDetail memory cache = userStake[_user];
        poolDetail memory temp = pools[currentPool];
        if(cache.amount <= 0){
            revert NoStaking();
        }
        uint256 rewardAmount = (block.timestamp -  cache.stakeTime) * temp.rewardRate / IERC20(tokenAddress).balanceOf(address(this));
        uint256 finalAmount = rewardAmount * cache.amount;
        return finalAmount;
    }
    
}