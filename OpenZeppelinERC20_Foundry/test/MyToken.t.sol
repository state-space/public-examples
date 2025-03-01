// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "src/MyToken.sol";

contract MyTokenTest is Test {
  MyToken public instance;

  function setUp() public {
    address initialOwner = vm.addr(1);
    address recipient = vm.addr(2);
    instance = new MyToken(initialOwner, recipient);
  }

  function testName() public view {
    assertEq(instance.name(), "MyToken");
  }
}
