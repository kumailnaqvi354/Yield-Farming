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

    using SafeMath for uint256;

    uint[] public maxReward = [
        100000000000000000000,
        5000000000000000000,
        200000000000000000000,
        5000000000000000000,
        100000000000000000000
    ];
    uint[] public rewardRate = [
        1200000000000000,
        200000000000000000000,
        1200000000000000,
        3000000000000000,
        200000000000000000000
    ];

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
        string memory name = "YIELD";
        assertEq(t.name(), name);
    }

    function testCreatePool() external {
        t.createPool(100000000000000000000, 5000000000000000);
        (uint256 temp1, uint256 temp2, uint256 temp3) = t.pools(
            t.currentPool()
        );
        IYieldFarming.poolDetail memory temp = IYieldFarming.poolDetail({
            poolId: 1,
            rewardRate: 5000000000000000,
            totalAwardDistributed: 0
        });

        assertTrue(t.currentPool() == temp.poolId && t.currentPool() == temp1);
        assertTrue(temp2 == temp.rewardRate);
        assertTrue(temp3 == temp.totalAwardDistributed);
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
         token.approve(address(t), 10000000000000000000);
        // console.log("status", status);
        uint256 _allownceAmount = token.allowance(address(userA), address(t));
        // console.log("_allownceAmount this", _allownceAmount);
        // console.log("address this", address(this));

        uint256 balanceBefore = token.balanceOf(address(this));
        // console.log("balanceBefore:", balanceBefore);
        vm.prank(userA);
        // console.log("address A", userA);

       t.stakeTokens(800000000000000000);
        // console.log("status:", success);
        uint256 balanceAfter = token.balanceOf(address(this));
        // console.log("balanceAfter:", balanceAfter);

        (uint256 _stakeTime, uint256 _pool, uint256 _amount) = t.userStake(
            userA
        );

        assertEq(_amount, 800000000000000000);
        assertEq(_pool, 1);
        assertEq(_stakeTime, 1);
    }

    function testCalculateReward() public {
        t.createPool(100000000000000000000, 5000000000000000);
        token.transfer(userA, 100000000000000000000);
        token.transfer(userB, 100000000000000000000);
        vm.prank(userA);
         token.approve(address(t), 10000000000000000000);
        vm.prank(userA);
         t.stakeTokens(800000000000000000);
        (uint256 _stakeTime, , uint256 amount) = t.userStake(userA);
        vm.warp(1641070800);
        (, uint256 rewardRate, ) = t.pools(t.currentPool());
        uint256 rewardAmount = ((block.timestamp.sub(_stakeTime)).mul(rewardRate).div( token.balanceOf(address(t))));
        uint256 finalAmount = rewardAmount.mul(amount);
        uint256 _reward = t.calculateReward(userA);
        assertEq(_reward, finalAmount);

        vm.prank(userB);
        bool statusB = token.approve(address(t), 10000000000000000000);
        vm.prank(userB);
      t.stakeTokens(900000000000000000);
        (uint256 _stakeTimeB, , uint256 amountB) = t.userStake(userB);
        vm.warp(1681121382);
        (, uint256 rewardRateB, ) = t.pools(t.currentPool());
        uint256 rewardAmountB = ((block.timestamp.sub(_stakeTimeB)).mul(rewardRateB).div(token.balanceOf(address(t))));
        uint256 finalAmountB = rewardAmountB.mul(amountB);
        // console.log("finalAmount",finalAmount);
        uint256 _rewardB = t.calculateReward(userB);
        assertEq(_rewardB, finalAmountB);
    }

    function testUnstakeTokens() external {
        t.createPool(100000000000000000000, 5000000000000000);
        token.transfer(userA, 100000000000000000000);
        token.transfer(userB, 100000000000000000000);
        vm.prank(userA);
         token.approve(address(t), 10000000000000000000);
        vm.prank(userA);
         t.stakeTokens(800000000000000000);
        // (uint256 _stakeTime,,uint256 amount) = t.userStake(userA);
        vm.prank(userA);
        t.unstakeTokens();
        (uint256 _stakeTime, , uint256 amount) = t.userStake(userA);

        // vm.warp(1641070800);
        // uint256 _reward = t.calculateReward(userA);
        // console.log("amount here ", amount);
        // console.log("_stakeTime here ", _stakeTime);
        assertEq(amount, 0);
        assertEq(_stakeTime, 0);
    }

    function testClaimReward() external {
         t.createPool(100000000000000000000, 5000000000000000);
        token.transfer(userA, 100000000000000000000);
        token.transfer(userB, 100000000000000000000);
        token.transfer(address(t), 100000000000000000000000000);
        vm.prank(userA);
        token.approve(address(t), 10000000000000000000);
        vm.prank(userA);
        t.stakeTokens(800000000000000000);
        vm.warp(1641070800);

        uint256 _expectedBalance = token.balanceOf(userA).add(t.calculateReward(userA));
        console.log("_expectedBalance",_expectedBalance);
        vm.prank(userA);
        t.claimReward();
         uint256 _actualBalance = token.balanceOf(userA);
         console.log("_actualBalance", _actualBalance);

         assertEq(_expectedBalance, _actualBalance);
        vm.prank(userA);
        t.unstakeTokens();
        // vm.prank(userA);
        // t.claimReward();


    }
}
