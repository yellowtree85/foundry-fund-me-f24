// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

//forge test --fork-url $SEPOLIA_ALCHEMY_RPC_URL
contract FundMeTest is Test {
    FundMe public fundMe;

    // generate a fake address
    address immutable USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    // always run first before each single test
    // FundMeTest is the owner of FundMe Contract
    //_deployer ==> FundMeTest ==> FundMe;
    function setUp() public {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, START_BALANCE); // Set the balance of USER to 10 ETH
    }

    function testMinimumDollarIsFive() public view {
        // console.log("hello");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // forge test -vvvv
    function testOwnerIsDeployer() public view {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        // msg.sender ==> FundMeTest ==> FundMe;
        // assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.getOwner(), msg.sender); // DeployFundMe Script's msg.sender is the owner of FundMe Contract
    }

    // debug forge test  --mt testPriceFeedVersionIsAccutrate -vvv
    function testPriceFeedVersionIsAccutrate() public view {
        // console.log(fundMe.s_priceFeed());
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFundFailsWithOutEnougthEth() public {
        // vm.expectRevert(bytes("aaa")); // Use the exact error message from FundMe.sol
        // revert("aaa");
        vm.expectRevert(bytes("You need to spend more ETH!")); // Use the exact error message from FundMe.sol
        fundMe.fund(); // Call fund() with 0 ETH
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // the next transaction will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Call fund() with 5 ETH
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); // the next transaction will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Call fund() with 5 ETH
        address[] memory funders = fundMe.getFunders();
        assertEq(funders.length, 1);
        assertEq(funders[0], USER);
    }

    function testAddsFunderToArrayOfFunders2() public {
        vm.prank(USER); // the next transaction will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Call fund() with 5 ETH
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER); // the next transaction will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Call fund() with SEND_VALUE
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // vm.startPrank(USER); // 模拟以 user 身份调用
        // vm.stopPrank(); // 停止模拟

        vm.prank(USER);
        vm.expectRevert(); // Use the exact error message from OpenZeppelin
        fundMe.withdraw(); // Call withdraw() with 5 ETH
    }

    function testWithDrawWithSingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // 0
        uint256 startingFundMeBalance = address(fundMe).balance; // SEND_VALUE

        // act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); // Set the gas price to 1
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // Call withdraw() with 5 ETH
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // tx.gasprice is now 1
        console.log(gasUsed);
        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithDrawWithMultipleFunders() public funded {
        //  mock multiple funders funding the contract
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(USER); // the next transaction will be sent by USER
            // vm.deal(USER, SEND_VALUE); // Set the balance of USER to 5 ETH
            hoax(address(i), SEND_VALUE); // vm.prank(USER) + vm.deal(USER, SEND_VALUE)
            fundMe.fund{value: SEND_VALUE}(); // Call fund() with 5 ETH
        }

        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // 0
        uint256 startingFundMeBalance = address(fundMe).balance; // 1 ETH

        // act
        vm.startPrank(fundMe.getOwner()); // 模拟以 owner 身份调用
        fundMe.withdraw(); // Call withdraw() with 10 ETH
        vm.stopPrank(); // 停止模拟

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // assertEq(startingFundMeBalance, 1 ether);
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testCheaperWithDrawWithMultipleFunders() public funded {
        //  mock multiple funders funding the contract
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(USER); // the next transaction will be sent by USER
            // vm.deal(USER, SEND_VALUE); // Set the balance of USER to 5 ETH
            hoax(address(i), SEND_VALUE); // vm.prank(USER) + vm.deal(USER, SEND_VALUE)
            fundMe.fund{value: SEND_VALUE}(); // Call fund() with 5 ETH
        }

        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // 0
        uint256 startingFundMeBalance = address(fundMe).balance; // 1 ETH

        // act
        vm.startPrank(fundMe.getOwner()); // 模拟以 owner 身份调用
        fundMe.cheaperWithdraw(); // Call withdraw() with 10 ETH
        vm.stopPrank(); // 停止模拟

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // assertEq(startingFundMeBalance, 1 ether);
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }
}
