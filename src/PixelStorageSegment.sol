// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PixelStorageSegment {
    // Store colors as bytes3 (RGB) in a 100x100 array
    mapping(uint8 => mapping(uint8 => bytes3)) private pixels;
    mapping(uint8 => mapping(uint8 => address)) private pixelOwners;
    address private immutable factory;

    constructor() {
        factory = msg.sender;
    }

    function setPixel(uint8 x, uint8 y, bytes3 color, address owner) external {
        require(msg.sender == factory, "Only factory can call");
        require(x < 100 && y < 100, "Coordinates out of bounds");
        pixels[x][y] = color;
        pixelOwners[x][y] = owner;
    }

    function getPixel(uint8 x, uint8 y) external view returns (bytes3) {
        require(x < 100 && y < 100, "Coordinates out of bounds");
        return pixels[x][y];
    }

    function getPixelOwner(uint8 x, uint8 y) external view returns (address) {
        require(x < 100 && y < 100, "Coordinates out of bounds");
        return pixelOwners[x][y];
    }
}