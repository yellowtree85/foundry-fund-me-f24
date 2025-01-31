// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// forge script script/DeployFundMe.s.sol
contract DeployFundMe is Script {
    function run() external returns (FundMe, HelperConfig) {
        return deployFundMe();
    }

    // msg.sender ==> FundMe;
    // msg.sender is the owner of FundMe Contract
    function deployFundMe() public returns (FundMe, HelperConfig) {
        // before  startBroadcast() is the fake transaction
        HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!
        address priceFeed = helperConfig
            .getConfigByChainId(block.chainid)
            .priceFeed;
        // sepolia 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // mainet 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        // after startBroadcast() and before stopBroadcast() is the real transaction
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return (fundMe, helperConfig);
    }
}
