// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "lib/foundry-devops/src/FoundryZkSyncChecker.sol";

//   https://github.com/Cyfrin/foundry-devops
//  FoundryZkSync  onlyFoundryZkSync onlyVanillaFoundry  is_foundry_zksync
//  ZkSyncChainChecker   skipZkSync onlyZkSync    isZkSyncChain  isOnZkSyncPrecompiles  isOnZkSyncChainId
contract ZkSyncDevOps is Test, ZkSyncChainChecker, FoundryZkSyncChecker {
    // 以下代码仅在foundry上运行成功 zksync上运行失败 需要加skipZkSync modifier
    // Remove the `skipZkSync`, then run `forge test --mt testZkSyncChainFails --zksync` and this will fail!
    function testZkSyncChainFails() public skipZkSync {
        address ripemd = address(uint160(3));

        bool success;
        // Don't worry about what this "assembly" thing is for now
        assembly {
            success := call(gas(), ripemd, 0, 0, 0, 0, 0)
        }
        assert(success);
    }

    // 仅在foundry上运行成功 zksync上运行失败 需要加onlyVanillaFoundry modifier
    // You'll need `ffi=true` in your foundry.toml to run this test
    // Remove the `onlyVanillaFoundry`, then run `foundryup-zksync` and then
    // `forge test --mt testZkSyncFoundryFails --zksync`
    // and this will fail!
    // function testZkSyncFoundryFails() public onlyVanillaFoundry {
    //     bool exists = vm.keyExistsJson('{"hi": "true"}', ".hi");
    //     assert(exists);
    // }
}
