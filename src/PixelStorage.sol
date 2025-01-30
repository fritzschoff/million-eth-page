// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PixelStorageFactory {
    PixelStorageSegment[] public segments;
    uint8 public constant SEGMENT_SIZE = 100; // 100x100 pixels per segment

    constructor() {
        // Create 100 segments to cover 1000x1000 grid (10x10 segments)
        for (uint8 i = 0; i < 100; i++) {
            segments.push(new PixelStorageSegment());
        }
    }

    /// @notice Sets a rectangle of pixels to the specified color
    /// @param startX The x coordinate of the top-left corner of the rectangle (0-999)
    /// @param startY The y coordinate of the top-left corner of the rectangle (0-999)
    /// @param width The width of the rectangle in pixels
    /// @param height The height of the rectangle in pixels
    /// @param color The RGB color to set the pixels to (as bytes3)
    /// @dev Requires payment of 1 gwei per pixel in the rectangle
    /// @dev Reverts if any pixel in the rectangle is already set
    /// @dev Reverts if the rectangle would extend beyond the 1000x1000 grid
    function setPixelRectangle(
        uint16 startX,
        uint16 startY,
        uint16 width,
        uint16 height,
        bytes3 color
    ) external payable {
        require(
            startX + width <= 1000 && startY + height <= 1000,
            "Rectangle exceeds bounds"
        );
        require(
            msg.value == uint256(width) * uint256(height) * 1 gwei,
            "Must pay 1 gwei per pixel"
        );

        for (uint16 y = startY; y < startY + height; y++) {
            for (uint16 x = startX; x < startX + width; x++) {
                // Calculate segment coordinates
                uint8 segmentX = uint8(x / SEGMENT_SIZE);
                uint8 segmentY = uint8(y / SEGMENT_SIZE);
                uint8 segmentIndex = segmentY * 10 + segmentX;

                // Calculate local coordinates
                uint8 localX = uint8(x % SEGMENT_SIZE);
                uint8 localY = uint8(y % SEGMENT_SIZE);

                // Check if pixel is already set
                bytes3 existingColor = segments[segmentIndex].getPixel(
                    localX,
                    localY
                );
                require(existingColor == 0, "One or more pixels already set");

                segments[segmentIndex].setPixel(
                    localX,
                    localY,
                    color,
                    msg.sender
                );
            }
        }
    }

    /// @notice Sets a single pixel to the specified color
    /// @param x The x coordinate of the pixel (0-999)
    /// @param y The y coordinate of the pixel (0-999)
    /// @param color The RGB color to set the pixel to (as bytes3)
    /// @dev Requires payment of 1 gwei
    /// @dev Reverts if the pixel is already set
    /// @dev Reverts if the coordinates are outside the 1000x1000 grid
    function setPixel(uint16 x, uint16 y, bytes3 color) external payable {
        require(x < 1000 && y < 1000, "Coordinates out of bounds");
        require(msg.value == 1 gwei, "Must pay exactly 1 gwei");

        // Calculate which segment the pixel belongs to
        uint8 segmentX = uint8(x / SEGMENT_SIZE);
        uint8 segmentY = uint8(y / SEGMENT_SIZE);
        uint8 segmentIndex = segmentY * 10 + segmentX;

        // Calculate local coordinates within segment
        uint8 localX = uint8(x % SEGMENT_SIZE);
        uint8 localY = uint8(y % SEGMENT_SIZE);

        // Check if pixel is already set
        bytes3 existingColor = segments[segmentIndex].getPixel(localX, localY);
        require(existingColor == 0, "Pixel already set");

        segments[segmentIndex].setPixel(localX, localY, color, msg.sender);
    }

    /// @notice Gets a segment of pixels from the grid
    /// @param start The starting index (0-999999)
    /// @param end The ending index (1-1000000)
    /// @return An array of pixel colors for the requested range
    /// @dev This function allows retrieving pixels in segments to avoid hitting block gas limits
    /// @dev The grid is indexed row by row, so index = y * 1000 + x
    /// @dev Due to Ethereum block gas limits (~30M), retrieving all 1M pixels at once would fail
    /// @dev Recommended to retrieve pixels in segments of 10k or less
    function getPixelSegment(
        uint32 start,
        uint32 end
    ) public view returns (bytes3[] memory) {
        require(start < end && end <= 1000000, "Invalid range");
        bytes3[] memory pixels = new bytes3[](end - start);
        for (uint32 i = start; i < end; i++) {
            pixels[i - start] = this.getPixel(
                uint16(i % 1000),
                uint16(i / 1000)
            );
        }
        return pixels;
    }

    function getPixel(uint16 x, uint16 y) external view returns (bytes3) {
        require(x < 1000 && y < 1000, "Coordinates out of bounds");

        uint8 segmentX = uint8(x / SEGMENT_SIZE);
        uint8 segmentY = uint8(y / SEGMENT_SIZE);
        uint8 segmentIndex = segmentY * 10 + segmentX;

        uint8 localX = uint8(x % SEGMENT_SIZE);
        uint8 localY = uint8(y % SEGMENT_SIZE);

        return segments[segmentIndex].getPixel(localX, localY);
    }

    function getPixelOwner(uint16 x, uint16 y) external view returns (address) {
        require(x < 1000 && y < 1000, "Coordinates out of bounds");

        uint8 segmentX = uint8(x / SEGMENT_SIZE);
        uint8 segmentY = uint8(y / SEGMENT_SIZE);
        uint8 segmentIndex = segmentY * 10 + segmentX;

        uint8 localX = uint8(x % SEGMENT_SIZE);
        uint8 localY = uint8(y % SEGMENT_SIZE);

        return segments[segmentIndex].getPixelOwner(localX, localY);
    }
}

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
