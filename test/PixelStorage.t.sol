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

    function test_ERC721Minting() public {
        // Set a pixel and verify NFT is minted
        pixelStorageFactory.setPixel{value: 1 gwei}(5, 5, bytes3(0xFFFFFF));
        
        // Token ID should be 1 for first mint
        assertEq(pixelStorageFactory.ownerOf(1), address(this));
        
        // Verify coordinates are stored correctly
        (uint16 x, uint16 y) = pixelStorageFactory.getTokenCoordinates(1);
        assertEq(x, 5);
        assertEq(y, 5);
    }

    function test_ERC721Transfer() public {
        // Set pixel and get token
        pixelStorageFactory.setPixel{value: 1 gwei}(5, 5, bytes3(0xFFFFFF));
        uint256 tokenId = 1;

        // Transfer to new address
        address newOwner = address(0x123);
        pixelStorageFactory.transferFrom(address(this), newOwner, tokenId);
        
        // Verify new ownership
        assertEq(pixelStorageFactory.ownerOf(tokenId), newOwner);
        
        // Original coordinates should remain unchanged
        (uint16 x, uint16 y) = pixelStorageFactory.getTokenCoordinates(tokenId);
        assertEq(x, 5);
        assertEq(y, 5);
    }

    function test_NonexistentTokenCoordinates() public {
        vm.expectRevert("Token does not exist");
        pixelStorageFactory.getTokenCoordinates(1);
    }

    function test_PixelOwnership() public {
        // Initially pixel has no owner
        assertEq(pixelStorageFactory.getPixelOwner(5, 5), address(0));

        // Set pixel and verify ownership
        pixelStorageFactory.setPixel{value: 1 gwei}(5, 5, bytes3(0xFFFFFF));
        assertEq(pixelStorageFactory.getPixelOwner(5, 5), address(this));
    }
}
