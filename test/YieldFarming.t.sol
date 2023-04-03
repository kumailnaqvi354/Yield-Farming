// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/YieldFarming.sol";
contract ContractTest is Test {

    YieldFarming t;
    address signer;


    function setUp() public {
        signer = vm.addr(1);
    }

    

    function testExample() public {
        assertTrue(true);
    }
    function getName() public {
        string memory _name = t.name;
        console.log("here signer =============", signer);
                assertEq(_name, "YIELD");

        // assertTrue();
    }
}
