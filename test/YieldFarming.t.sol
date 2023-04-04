// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/YieldFarming.sol";
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
        token = new Token(1000000000000000000000);
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


    function testaddPool() external {
     t.createPool(100000000000000000000, 5000000000000000);
        t.currentPool();

        t.pools(t.currentPool());
     
        assertEq(t.currentPool(), 1);
    }
}
