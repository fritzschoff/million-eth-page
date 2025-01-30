// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PixelStorageFactory, PixelStorageSegment} from "../src/PixelStorage.sol";

contract PixelStorageTest is Test {
    PixelStorageFactory public pixelStorageFactory;

    function setUp() public {
        pixelStorageFactory = new PixelStorageFactory();
    }

    function test_SetPixel() public {
        pixelStorageFactory.setPixel{value: 1 gwei}(0, 0, bytes3(0xFFFFFF));
        assertEq(pixelStorageFactory.getPixel(0, 0), bytes3(0xFFFFFF));
        pixelStorageFactory.setPixel{value: 1 gwei}(1, 1, bytes3(0x000000));
        assertEq(pixelStorageFactory.getPixel(1, 1), bytes3(0x000000));
    }

    function test_CanNotOverwritePixel() public {
        pixelStorageFactory.setPixel{value: 1 gwei}(0, 0, bytes3(0xFFFFFF));
        vm.expectRevert("Pixel already set");
        pixelStorageFactory.setPixel{value: 1 gwei}(0, 0, bytes3(0x000000));
    }

    function test_CanNotSetPixelOutOfBounds() public {
        vm.expectRevert("Coordinates out of bounds");
        pixelStorageFactory.setPixel{value: 1 gwei}(1000, 1000, bytes3(0xFFFFFF));
    }

    function test_PixelStorageSegmentOnlyFactoryCanSetPixel() public {
        PixelStorageSegment segment = pixelStorageFactory.segments(0);
        vm.expectRevert("Only factory can call");
        segment.setPixel(0, 0, bytes3(0xFFFFFF), address(this));
        vm.expectRevert("Only factory can call");
        segment.setPixel(0, 0, bytes3(0xFFFFFF), address(pixelStorageFactory));
    }

    function test_PixelStorageRevertIfNotEnoughEth() public {
        vm.expectRevert("Must pay exactly 1 gwei");
        pixelStorageFactory.setPixel{value: 0.5 gwei}(0, 0, bytes3(0xFFFFFF));
    }

    function test_PixelStorageRevertIfRectangleExceedsBounds() public {
        vm.expectRevert("Rectangle exceeds bounds");
        pixelStorageFactory.setPixelRectangle(0, 0, 1001, 1001, bytes3(0xFFFFFF));
    }

    function test_PixelStorageRevertIfOneOrMorePixelsAlreadySet() public {
        pixelStorageFactory.setPixel{value: 1 gwei}(0, 0, bytes3(0xFFFFFF));
        vm.expectRevert("One or more pixels already set");
        pixelStorageFactory.setPixelRectangle{value: 1 gwei}(0, 0, 1, 1, bytes3(0xFFFFFF));
    }

    function test_GetPixelSegment() public {
        bytes3[] memory allPixels = pixelStorageFactory.getPixelSegment(0, 10000);
        assertEq(allPixels.length, 10000);
    }
}
