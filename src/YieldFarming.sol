// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.16;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/utils/Counters.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "./IYieldFarming.sol";
import "forge-std/console.sol";

contract YieldFarming is ReentrancyGuard, Ownable, IYieldFarming{
    
    address public immutable tokenAddress;
    
    uint256 private immutable startTime;
    uint256 public currentPool;
    string public name = "YIELD";
 
    mapping (address => userStakeDetail) public userStake;
    mapping (uint256 => poolDetail) public pools;
    
    constructor(address _rewardTokenAddress, uint256 _startTime) {
        tokenAddress = _rewardTokenAddress;
        startTime = _startTime;
    }

    function stakeTokens(uint256 _amount) external override returns(bool isStaked){
       
        if (IERC20(tokenAddress).balanceOf(msg.sender) <= _amount) {
          revert InsufficientBalance();
        }
        if (IERC20(tokenAddress).allowance(msg.sender, address(this)) <= _amount) {
            revert approvalError();
        }
        if(startTime < block.timestamp) {
            revert stakingNotStarted();
        }

        userStakeDetail memory temp = userStake[msg.sender];
        temp.amount = _amount;
        temp.pool = currentPool;
        temp.stakeTime = block.timestamp;
       userStake[msg.sender] = temp;
      isStaked = IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);


    }

    function createPool(uint256 _maxReward, uint256 _rewardRate) external override onlyOwner{
        if (_maxReward == 0 && _rewardRate == 0) {
            revert zeroValuesNotAllowed();
        }
        uint256 _poolId = currentPool + 1;
        poolDetail memory temp = pools[currentPool];
        currentPool = _poolId; 
        temp.poolId = _poolId;
        temp.rewardRate = _rewardRate;
        temp.maxReward = _maxReward;
        pools[_poolId] = temp;
    }

    function calculateReward(address _user) external view returns(uint256) {
        if(_user == address(0)){
            revert InvalidUser();
        }
        if(currentPool == 0){
            revert stakingNotStarted();
        }
        userStakeDetail memory cache = userStake[_user];
        poolDetail memory temp = pools[currentPool];
        if(cache.amount <= 0){
            revert NoStaking();
        }
        uint256 rewardAmount = (block.timestamp -  cache.stakeTime) * temp.rewardRate / IERC20(tokenAddress).balanceOf(address(this));
        uint256 finalAmount = rewardAmount * cache.amount;
        return finalAmount;
    }
    
    function unstakeTokens() external nonReentrant() returns (bool success){
        if (msg.sender == address(0)) {
            revert InvalidUser();
        }
        userStakeDetail memory cache = userStake[msg.sender];
        if(cache.amount == 0){
            revert NoStaking();
        }
        uint256 _amount = cache.amount;
        delete userStake[msg.sender];
        IERC20(tokenAddress).transfer(msg.sender, _amount);
        success;
    }

}