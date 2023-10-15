// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

interface Huffbits {
    function bitMask(uint256) external pure returns(uint256);
    function multiMask(uint256) external pure returns(uint256);
    function nibbleMask(uint256) external pure returns(uint256);
    function byteMask(uint256) external pure returns(uint256);
    function setBit(uint256, uint256) external pure returns(uint256);
    function clearBit(uint256, uint256) external pure returns(uint256);
    function toggleBit(uint256, uint256) external pure returns(uint256);
    function queryBit(uint256, uint256) external pure returns(uint256);
    function writeNibble(uint256, uint256, uint256) external pure returns(uint256);
    function clearNibble(uint256, uint256) external pure returns(uint256);
    function queryNibble(uint256, uint256) external pure returns(uint256);
    function clearByte(uint256, uint256) external pure returns(uint256);
    function writeByte(uint256, uint256, uint256) external pure returns(uint256);
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
    function testBitMask() public {
        assertEq(huffbits.bitMask(0x0), 0x1);
        assertEq(huffbits.bitMask(0x1), 0x2);
        assertEq(huffbits.bitMask(0x2), 0x4);
        assertEq(huffbits.bitMask(0x3), 0x8);
        assertEq(huffbits.bitMask(0x8), 0x100);
        assertEq(huffbits.bitMask(0x8), 0x100);
        assertEq(huffbits.bitMask(0x20), 0x100000000);
        assertEq(huffbits.bitMask(0x3F), 0x8000000000000000);
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

    function testNibbleMask() public { // initial gas: 11565)
        assertEq(huffbits.nibbleMask(0), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0);
        assertEq(huffbits.nibbleMask(1), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0F);
        assertEq(huffbits.nibbleMask(2), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0FF);
        assertEq(huffbits.nibbleMask(3), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0FFF);
        assertEq(huffbits.nibbleMask(17), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0FFFFFFFFFFFFFFFFF);
        assertEq(huffbits.nibbleMask(32), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        assertEq(huffbits.nibbleMask(55), 0xFFFFFFFF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        assertEq(huffbits.nibbleMask(63), 0x0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    function testClearNibble() public {
        assertEq(huffbits.clearNibble(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, 0), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0);
        assertEq(huffbits.clearNibble(1, 0), 0);

    }

    function testWriteNibble() public {
        uint256 index = 0;
        uint256 bitmap = 0x0;
        uint256 newBits = 0x1;
        assertEq(huffbits.writeNibble(index, newBits, bitmap), 0x1);

        assertEq(huffbits.writeNibble(3, 0xb, MAX), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFbFFF);
        assertEq(huffbits.writeNibble(63, 0x5, MAX), 0x5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        assertEq(huffbits.writeNibble(33, 0x1, MAX), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        assertEq(huffbits.writeNibble(17, 0xc, MAX), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFcFFFFFFFFFFFFFFFFF);
    }

    function testQueryNibble() public {
        uint256 index = 0x11;
        uint bitmap = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFcFFFFFFFFFFFFFFFFF;
        assertEq(huffbits.queryNibble(bitmap, index), 0xc);
        assertEq(huffbits.queryNibble(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, 34), 0x0);
    }

    function testByteMask() public {
        assertEq(huffbits.byteMask(0), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00);
        assertEq(huffbits.byteMask(1), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FF);
        assertEq(huffbits.byteMask(2), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFF);
        assertEq(huffbits.byteMask(3), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFF);
        assertEq(huffbits.byteMask(17), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        assertEq(huffbits.byteMask(31), 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    function testClearByte() public {
        assertEq(huffbits.clearByte(1, 0), 0);
        assertEq(huffbits.clearByte(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, 3), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFF);
        assertEq(huffbits.clearByte(0xFdFFFFFFFFFFFbFFFFFFFFaFFFFFFFF12FFFFFFFFF7FFFFFFFbFFFFFFFF3FFF0, 15), 0xFdFFFFFFFFFFFbFFFFFFFFaFFFFFFFF100FFFFFFFF7FFFFFFFbFFFFFFFF3FFF0);
    }

    function testWriteByte() public {
        uint256 index = 0;
        uint256 bitmap = 0x0;
        uint256 newBits = 0x1;
        assertEq(huffbits.writeByte(index, newBits, bitmap), 0x1);
        assertEq(huffbits.writeByte(3, 0xb7, MAX), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFb7FFFFFF);
        assertEq(huffbits.writeByte(31, 0x55, MAX), 0x55FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        assertEq(huffbits.writeByte(17, 0x77, MAX), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF77FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    // queryByte

}

