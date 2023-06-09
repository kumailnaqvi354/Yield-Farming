// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.16;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/utils/Counters.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";
import "./IYieldFarming.sol";
import "forge-std/console.sol";

contract YieldFarming is ReentrancyGuard, Ownable, IYieldFarming {
    address public immutable tokenAddress;

    using SafeMath for uint256;
    uint256 private immutable startTime;
    uint256 public currentPool;
    string public name = "YIELD";

    mapping(address => userStakeDetail) public userStake;
    mapping(uint256 => poolDetail) public pools;

    constructor(address _rewardTokenAddress, uint256 _startTime) {
        tokenAddress = _rewardTokenAddress;
        startTime = _startTime;
    }

    function stakeTokens(uint256 _amount) external override {
        if (IERC20(tokenAddress).balanceOf(msg.sender) <= _amount) {
            revert InsufficientBalance();
        }
        if (
            IERC20(tokenAddress).allowance(msg.sender, address(this)) <= _amount
        ) {
            revert approvalError();
        }
        if (startTime < block.timestamp) {
            revert stakingNotStarted();
        }

        userStakeDetail memory temp = userStake[msg.sender];
        temp.amount = _amount;
        temp.pool = currentPool;
        temp.stakeTime = block.timestamp;
        userStake[msg.sender] = temp;
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
    }

    function createPool(uint256 _maxReward, uint256 _rewardRate)
        external
        override
        onlyOwner
    {
        if (_maxReward == 0 && _rewardRate == 0) {
            revert zeroValuesNotAllowed();
        }
        uint256 _poolId = currentPool + 1;
        poolDetail memory temp = pools[currentPool];
        currentPool = _poolId;
        temp.poolId = _poolId;
        temp.rewardRate = _rewardRate;
        pools[_poolId] = temp;
    }

    function calculateReward(address _user) public view returns (uint256) {
        if (_user == address(0)) {
            revert InvalidUser();
        }
        if (currentPool == 0) {
            revert stakingNotStarted();
        }
        userStakeDetail memory cache = userStake[_user];
        poolDetail memory temp = pools[cache.pool];
        if (cache.amount <= 0) {
            revert NoStaking();
        }
        uint256 stakeAmount = IERC20(tokenAddress).balanceOf(address(this));
        uint256 rewardAmount = (block.timestamp - cache.stakeTime) * temp.rewardRate / IERC20(tokenAddress).balanceOf(address(this));
        uint256 finalAmount = rewardAmount.mul(cache.amount);
        return finalAmount;
    }

    function unstakeTokens() external nonReentrant() {
        if (msg.sender == address(0)) {
            revert InvalidUser();
        }
        userStakeDetail memory cache = userStake[msg.sender];
        if (cache.amount == 0) {
            revert NoStaking();
        }
        uint256 _amount = cache.amount;
        delete userStake[msg.sender];
        IERC20(tokenAddress).transfer(msg.sender, _amount);
    }

    function claimReward() external nonReentrant() {
        if (msg.sender == address(0)) {
            revert InvalidUser();
        }
        userStakeDetail memory cache = userStake[msg.sender];
        poolDetail memory temp = pools[cache.pool];
        if (cache.amount == 0) {
            revert NoStaking();
        }

        uint256 rewardAmount = calculateReward(msg.sender);
        cache.stakeTime = block.timestamp;
        temp.totalAwardDistributed = temp.totalAwardDistributed.add(
            rewardAmount
        );
        userStake[msg.sender] = cache;
        pools[cache.pool] = temp;
        IERC20(tokenAddress).transfer(msg.sender, rewardAmount);
    }
}
