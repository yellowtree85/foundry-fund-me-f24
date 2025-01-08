// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FunWithStorage} from "../../src/FunWithStorage.sol";
import {DeployFunWithStorage} from "../../script/DeployFunWithStorage.s.sol";

// forge test --mc FunWithStorageTest
contract FunWithStorageTest is Test {
    FunWithStorage public funWithStorage;

    function setUp() public {
        DeployFunWithStorage deployFunWithStorage = new DeployFunWithStorage();
        funWithStorage = deployFunWithStorage.run();
    }

    function testFavoriteNumberValue() public view {
        // console.log("hello");
        assertEq(funWithStorage.getFavoriteNumber(), 25);
    }

    // forge test --mc FunWithStorageTest --mt testSomeBoolValue
    function testSomeBoolValue() public view {
        // console.log("hello");
        assertEq(funWithStorage.getSomeBool(), true);
    }

    function testMyArrayValue() public view {
        // console.log("hello");
        uint256[] memory myArray = funWithStorage.getMyArray();
        assertEq(myArray[0], 222);
    }

    function testMyMapValue() public view {
        console.log("hello");
        assertEq(funWithStorage.getMyMap(0), true);
    }
}
