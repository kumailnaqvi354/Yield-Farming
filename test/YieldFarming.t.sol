// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/YieldFarming.sol";
import "../src/IYieldFarming.sol";
import "../src/Token.sol";

contract ContractTest is Test {

    YieldFarming t;
    Token token;
    address admin;
    address payable userA;
    address payable userB;    

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

        // console.log("here", userB);
        // console.log("here admin", t.owner());
        
        t.createPool(100000000000000000000, 5000000000000000);

        (uint256 temp1,uint256 temp2,uint256 temp3,uint256 temp4) = t.pools(t.currentPool());
        console.log("here 1", temp1);
        // t.createPool(100000000000000000000, 5000000000000000);
            IYieldFarming.poolDetail memory temp = IYieldFarming.poolDetail({
                poolId: 1,
                rewardRate:5000000000000000,
                totalAwardDistributed:0,
                maxReward:100000000000000000000
            });

    assertTrue(t.currentPool() == temp.poolId);
    assertTrue(temp2 == temp.rewardRate);
    assertTrue(temp3 == temp.totalAwardDistributed);
    assertTrue(temp4 == temp.maxReward);


    // vm.prank(address(userB));
    // t.createPool(100000000000000000000, 5000000000000000);

    }

}
