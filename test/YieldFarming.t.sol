// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/YieldFarming.sol";
import "../src/IYieldFarming.sol";
import "../src/Token.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";


contract ContractTest is Test {

    YieldFarming t;
    Token token;
    address admin;
    address payable userA;
    address payable userB;    
    
uint[] public maxReward = [100000000000000000000, 5000000000000000000,200000000000000000000,5000000000000000000,100000000000000000000];
uint[] public rewardRate = [1200000000000000, 200000000000000000000,1200000000000000,3000000000000000,200000000000000000000];

    function setUp() public {
        userA = payable(vm.addr(2));
        userB = payable(vm.addr(1));
        // vm.prank(userA);
        token = new Token();
        t = new YieldFarming(address(token), 1680863492);
    }

    // function testExample() public {
    //         // console.log( token);
    //     assertTrue(true);
    // }

    
    function testName() public {
        string memory name ="YIELD";
        assertEq(t.name(), name);
    }


    function testCreatePool() external {

        t.createPool(100000000000000000000, 5000000000000000);
        (uint256 temp1,uint256 temp2,uint256 temp3,uint256 temp4) = t.pools(t.currentPool());
            IYieldFarming.poolDetail memory temp = IYieldFarming.poolDetail({
                poolId: 1,
                rewardRate:5000000000000000,
                totalAwardDistributed:0,
                maxReward:100000000000000000000
            });

    assertTrue(t.currentPool() == temp.poolId && t.currentPool() == temp1);
    assertTrue(temp2 == temp.rewardRate);
    assertTrue(temp3 == temp.totalAwardDistributed);
    assertTrue(temp4 == temp.maxReward);


    }

    function testFuzzCreatePool() external {

    for (uint i = 0; i < maxReward.length; i++) {
            t.createPool(maxReward[i], rewardRate[i]);
            // vm.prank(userB);

            // t.createPool(100000000000000000000, 5000000000000000);
            // t.createPool(maxReward[i], rewardRate[i]);

    
    }
        //      t.createPool(100000000000000000000, 5000000000000000);
        //   t.createPool(100000000000000000000, 5000000000000000);
        //    t.createPool(100000000000000000000, 5000000000000000);
        //     t.createPool(100000000000000000000, 5000000000000000);
        //     vm.prank(userB);
        //      t.createPool(100000000000000000000, 5000000000000000);
    }

    function testStakeTokens() external {
        t.createPool(100000000000000000000, 5000000000000000);
        token.transfer(userA, 100000000000000000000);
        // console.log("here instance:", t.currentPool());
        vm.prank(userA);
        // console.log("address A", userA);
        // t.stakeTokens(100);
        // console.log("Staking Contract Address", address(token));
        bool status = token.approve(address(t), 10000000000000000000);
        // console.log("status", status);
        uint256 _allownceAmount = token.allowance(address(userA), address(t));
        // console.log("_allownceAmount this", _allownceAmount);
        // console.log("address this", address(this));

        uint256 balanceBefore = token.balanceOf(address(this));
        // console.log("balanceBefore:", balanceBefore);
        vm.prank(userA);
        // console.log("address A", userA);

        bool success = t.stakeTokens(800000000000000000);
        // console.log("status:", success);
        uint256 balanceAfter = token.balanceOf(address(this));
        // console.log("balanceAfter:", balanceAfter);

        (uint256 _stakeTime, uint256 _pool, uint256 _amount) = t.userStake(userA);

        assertEq(_amount, 800000000000000000);
        assertEq(_pool, 1);
        assertEq(_stakeTime, 1);
        
    }

    function testCalculateReward() public {
        t.createPool(100000000000000000000, 5000000000000000);
        token.transfer(userA, 100000000000000000000);
         token.transfer(userB, 100000000000000000000);
        vm.prank(userA);
        bool status = token.approve(address(t), 10000000000000000000);
        vm.prank(userA);
        bool success = t.stakeTokens(800000000000000000);
        (uint256 _stakeTime,,uint256 amount) = t.userStake(userA);
        vm.warp(1641070800);
        (,uint256 rewardRate,,) = t.pools(t.currentPool());
        // console.log("here", amount);
        uint256 rewardAmount = (block.timestamp -  _stakeTime) * rewardRate / token.balanceOf(address(t));
        uint256 finalAmount = rewardAmount * amount;
        // console.log("finalAmount",finalAmount);
        uint256 _reward = t.calculateReward(userA);
        // console.log("reward here ", _reward);
        assertEq(_reward, finalAmount);


        vm.prank(userB);
        bool statusB = token.approve(address(t), 10000000000000000000);
        vm.prank(userB);
        bool successB = t.stakeTokens(900000000000000000);
        (uint256 _stakeTimeB,,uint256 amountB) = t.userStake(userB);
        vm.warp(1681121382);
        (,uint256 rewardRateB,,) = t.pools(t.currentPool());

        uint256 rewardAmountB = (block.timestamp -  _stakeTimeB) * rewardRateB / token.balanceOf(address(t));
        uint256 finalAmountB = rewardAmountB * amountB;
        // console.log("finalAmount",finalAmount);
        uint256 _rewardB = t.calculateReward(userB);
        // console.log("reward here ", _reward);
        assertEq(_rewardB, finalAmountB);


    }




}
