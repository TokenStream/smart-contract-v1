// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/Authentication.sol";

contract AuthenticationTest is Test {
    Authentication public auth;

    function setUp() public {
        auth = new Authentication();
    }

    function testCreateAccount() public {
        bytes memory name1 = bytes("alice");

        vm.prank(address(0)); // Test zero address case
        vm.expectRevert(Authentication.ZERO_ADDRESS_NOT_ALLOWED.selector);
        auth.createAccount(name1);

        vm.prank(address(this));
        auth.createAccount(name1);
        assertEq(auth.getAddressFromName(name1), address(this));

        vm.expectRevert(Authentication.NAME_NOT_AVAILABLE.selector);
        auth.createAccount(name1); // Test duplicate name
    }
}
