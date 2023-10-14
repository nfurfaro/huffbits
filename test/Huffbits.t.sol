// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

interface Huffbits {
    function singleBitMask(uint256) external pure returns(uint256);
    function multiMask(uint256) external pure returns(uint256);
    function nibbleMask(uint256) external pure returns(uint256);
    function toggleBit(uint256, uint256) external pure returns(uint256);
    function queryBit(uint256, uint256) external pure returns(uint256);
    function setBit(uint256, uint256) external pure returns(uint256);
    function clearBit(uint256, uint256) external pure returns(uint256);
}


contract HuffbitsTest is Test {
    /// @dev Address of the Huffbits contract
    Huffbits public huffbits;
    uint constant MAX = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

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
        assertEq(huffbits.queryBit(0, 0), 0);
        assertEq(huffbits.queryBit(0, 1), 0);
        assertEq(huffbits.queryBit(0, 64), 0);
        assertEq(huffbits.queryBit(0, 255), 0);
        assertEq(huffbits.queryBit(1, 0), 1);
        assertEq(huffbits.queryBit(1025, 0), 1);
        assertEq(huffbits.queryBit(1025, 10), 1);
        assertEq(huffbits.queryBit(1025, 11), 0);
        assertEq(huffbits.queryBit(MAX, 0), 1);
        assertEq(huffbits.queryBit(MAX, 64), 1);
        assertEq(huffbits.queryBit(MAX, 128), 1);
        assertEq(huffbits.queryBit(MAX, 255), 1);
    }

    function testMultiMask() public {
        assertEq(huffbits.multiMask(0), 0);
        assertEq(huffbits.multiMask(1), 1);
        assertEq(huffbits.multiMask(2), 3);
        assertEq(huffbits.multiMask(3), 7);
        assertEq(huffbits.multiMask(4), 15);
        assertEq(huffbits.multiMask(5), 31);
        assertEq(huffbits.multiMask(6), 63);
        assertEq(huffbits.multiMask(7), 127);
        assertEq(huffbits.multiMask(8), 255);
        assertEq(huffbits.multiMask(32), 4294967295);
        assertEq(huffbits.multiMask(256), MAX);
    }

    function testSetBit() public {
        assertEq(huffbits.setBit(0, 0), 1);
        assertEq(huffbits.setBit(1, 0), 1);
        assertEq(huffbits.setBit(1, 1), 3);
        assertEq(huffbits.setBit(0, 4), 16);
        assertEq(huffbits.setBit(0, 7), 128);
        assertEq(huffbits.setBit(0, 16), 65536);
        assertEq(huffbits.setBit(65536, 16), 65536);
        assertEq(huffbits.setBit(0, 63), 9223372036854775808);
        assertEq(huffbits.setBit(0xFFFFFFFEFFFFFFFF, 32), 0xFFFFFFFFFFFFFFFF);
        assertEq(huffbits.setBit(0xFFFFFFFFFFFFFFFF, 32), 0xFFFFFFFFFFFFFFFF);
    }

    function testClearBit() public {
        assertEq(huffbits.clearBit(1, 0), 0);
        assertEq(huffbits.clearBit(3, 1), 1);
        assertEq(huffbits.clearBit(3, 0), 2);
        assertEq(huffbits.clearBit(256, 8), 0);
        assertEq(huffbits.clearBit(256, 7), 256);
        assertEq(huffbits.clearBit(0xFFFFFFFFFFFFFFFF, 63), 0x7FFFFFFFFFFFFFFF);
        assertEq(huffbits.clearBit(0xFFFFFFFFFFFFFFFF, 25), 0xFFFFFFFFFDFFFFFF);
        assertEq(huffbits.clearBit(0x37DDFDDBBDDFBF7C, 47), 0x37DD7DDBBDDFBF7C);
        assertEq(huffbits.clearBit(0x37DDFDDBBDDFBF7C, 14), 0x37DDFDDBBDDFBF7C);
    }

    function testNibbleMask() public {}
}

