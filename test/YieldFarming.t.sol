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
        token = new Token();
        t = new YieldFarming(t.tokenAddress.address, block.timestamp);
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
        
        // t.stakeTokens(100);
        console.log("Staking Contract Address", address(token));
      bool status = token.approve(address(this), 100000000000000000000);
      console.log("status", status);
        uint256 _allownceAmount = token.allowance(address(userA), address(this));
        console.log("_allownceAmount", _allownceAmount);
        console.log("balance of user", token.balanceOf(userA));
    }


}
