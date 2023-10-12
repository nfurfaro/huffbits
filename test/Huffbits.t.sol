// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

interface Huffbits {
    function singleBitMask(uint256) external pure returns(uint256);
}


contract HuffbitsTest is Test {
    /// @dev Address of the Huffbits contract
    Huffbits public huffbits;

    function setUp() public {
        string memory wrappers = vm.readFile("test/mocks/HuffbitsWrappers.huff");
        huffbits = Huffbits(HuffDeployer.deploy_with_code("Huffbits", wrappers));
    }

    /// @dev Ensure that a single bit can be set.
    function testBitMask() public {
        assertEq(huffbits.singleBitMask(0x0), 0x1);
    }
}

