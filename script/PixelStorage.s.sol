// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PixelStorageFactory} from "../src/PixelStorage.sol";

contract PixelStorageScript is Script {
    PixelStorageFactory public pixelStorageFactory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        pixelStorageFactory = new PixelStorageFactory();

        vm.stopBroadcast();
    }
}
