// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

interface Huffbits {
    function singleBitMask(uint256) external pure returns(uint256);
    // function multiMask(uint256) external pure returns(uint256);
    function toggleBit(uint256, uint256) external pure returns(uint256);
    function queryBit(uint256, uint256) external pure returns(uint256);
}


contract HuffbitsTest is Test {
    /// @dev Address of the Huffbits contract
    Huffbits public huffbits;

    function setUp() public {
        string memory wrappers = vm.readFile("test/mocks/HuffbitsWrappers.huff");
        huffbits = Huffbits(HuffDeployer.deploy_with_code("Huffbits", wrappers));
    }

    /// @dev Ensure that a single bit can be set.
    function testSingleBitMask() public {
        assertEq(huffbits.singleBitMask(0x0), 0x1);
        assertEq(huffbits.singleBitMask(0x1), 0x2);
        assertEq(huffbits.singleBitMask(0x2), 0x4);
        assertEq(huffbits.singleBitMask(0x3), 0x8);
        assertEq(huffbits.singleBitMask(0x8), 0x100);
        assertEq(huffbits.singleBitMask(0x8), 0x100);
        assertEq(huffbits.singleBitMask(0x20), 0x100000000);
        assertEq(huffbits.singleBitMask(0x3F), 0x8000000000000000);
    }

    function testToggleBit() public {
        assertEq(huffbits.toggleBit(0x0, 0x0), 0x1);
        assertEq(huffbits.toggleBit(0x0, 0x1), 0x2);
        assertEq(huffbits.toggleBit(0x0, 42), 4398046511104);
        assertEq(huffbits.toggleBit(1, 0), 0);
        assertEq(huffbits.toggleBit(2, 0), 3);
        assertEq(huffbits.toggleBit(2, 1), 0);
        assertEq(huffbits.toggleBit(1024, 0), 1025);
    }

    function testQueryBit() public {
        uint256 max = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        assertEq(huffbits.queryBit(0, 0), 0);
        assertEq(huffbits.queryBit(0, 1), 0);
        assertEq(huffbits.queryBit(0, 64), 0);
        assertEq(huffbits.queryBit(0, 255), 0);
        assertEq(huffbits.queryBit(1, 0), 1);
        assertEq(huffbits.queryBit(1025, 0), 1);
        assertEq(huffbits.queryBit(1025, 10), 1);
        assertEq(huffbits.queryBit(1025, 11), 0);
        assertEq(huffbits.queryBit(max, 0), 1);
        assertEq(huffbits.queryBit(max, 64), 1);
        assertEq(huffbits.queryBit(max, 128), 1);
        assertEq(huffbits.queryBit(max, 255), 1);
    }

    // function testMultiMask() public {
    //     assertEq(huffbits.multiMask(1), 1);
    // }
}

