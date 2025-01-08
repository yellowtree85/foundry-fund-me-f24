// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 3612e8;

    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ZKSYNC_MAINNET_CHAIN_ID = 324;
    uint256 public constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 public constant LOCAL_CHAIN_ID = 31337;

    constructor() {
        if (block.chainid == ETH_MAINNET_CHAIN_ID) {
            activeNetworkConfig = getMainNetConfig();
        } else if (block.chainid == ETH_SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == ZKSYNC_MAINNET_CHAIN_ID) {
            activeNetworkConfig = getZkSyncMainNetConfig();
        } else if (block.chainid == ZKSYNC_SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getZkSyncSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH / USD
        });
    }

    function getMainNetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // ETH / USD
        });
    }

    function getZkSyncSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF // ETH / USD
        });
    }

    // ZkSync Era MainNet
    function getZkSyncMainNetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x6D41d1dc818112880b40e26BD6FD347E41008eDA // ETH / USD
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // deploy a new mock price feed
        // return the address of the mock price feed
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
