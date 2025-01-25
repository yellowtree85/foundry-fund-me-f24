// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

//forge test --fork-url $SEPOLIA_ALCHEMY_RPC_URL
// 集成测试脚本 与合约交互  需要广播修改链上数据 vm.startBroadcast();  vm.stopBroadcast();
// 单元测试脚本 与合约交互  只做模拟 不需要广播 不修改链上数据 也不消耗gas
contract InteractionsTest is Test {
    FundMe public fundMe;
    // generate a fake address
    address immutable USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe, ) = deployFundMe.run();
        vm.deal(USER, START_BALANCE); // Set the balance of USER to 10 ETH

        console.log("InteractionsTest address is %s", address(this));
        // InteractionsTest address is 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        //  msg.sender is              0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
    }

    function testUserCanFundInteractions() public {
        // console.log("InteractionsTest address is %s", address(this));
        FundFundMe fundFundMe = new FundFundMe();
        // fundMe.fund{value: SEND_VALUE}();
        fundFundMe.fundFundMe(address(fundMe));
        assertEq(address(fundMe).balance, 0.1 ether);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assertEq(address(fundMe).balance, 0);
    }
}
