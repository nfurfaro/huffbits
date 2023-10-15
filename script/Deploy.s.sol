// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

interface Huffbits {
  function bitMask(uint256) external pure returns(uint256);
  function nibbleMask(uint256) external pure returns(uint256);
  function byteMask(uint256) external pure returns(uint256);
  function multiMask(uint256) external pure returns(uint256);
  function setBit(uint256, uint256) external pure returns(uint256);
  function clearBit(uint256, uint256) external pure returns(uint256);
  function toggleBit(uint256, uint256) external pure returns(uint256);
  function queryBit(uint256, uint256) external pure returns(uint256);
  function writeNibble(uint256, uint256, uint256) external pure returns(uint256);
  function clearNibble(uint256, uint256) external pure returns(uint256);
  function queryNibble(uint256, uint256) external pure returns(uint256);
  function clearByte(uint256, uint256) external pure returns(uint256);
  function writeByte(uint256, uint256, uint256) external pure returns(uint256);
  function queryByte(uint256, uint256) external pure returns(uint256);
}

contract Deploy is Script {
  function run() public returns (Huffbits huffbits) {
    string memory wrappers = vm.readFile("test/mocks/HuffbitsWrappers.huff");
    huffbits = Huffbits(HuffDeployer.deploy_with_code("Huffbits", wrappers));
  }
}
