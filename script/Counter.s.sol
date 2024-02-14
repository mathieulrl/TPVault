
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {LRLBTHT} from "src/TDERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        // vm.startBroadcast(vm.envUint("anvil"));

        LRLBTHT erc20 = new LRLBTHT();
        // ERC20TD erc20 = ERC20TD(0x482749F0578D0c8b067865a4eA49B5ef220c456B);

  

        vm.stopBroadcast();
    }
}
