// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SalaryStreaming} from "../src/SalaryStreaming.sol";
import {Token} from "../src/Token.sol";

contract SalaryStreamingTest is Test {
    SalaryStreaming public salaryStreaming;
    Token public erc20;

    address A = address(0xa);
    address B = address(0xb);
    address owner = address(0xc);

    function setUp() public {
        erc20 = new Token();
        erc20.mint(owner, 10000 * 10 ** 18); // Mint tokens directly to the owner

        salaryStreaming = new SalaryStreaming(address(erc20));
        vm.startPrank(owner);
        erc20.approve(address(salaryStreaming), 10000 * 10 ** 18); // Owner approves SalaryStreaming to use their tokens
        vm.stopPrank();
    }

    function test_StartStream() public {
        uint256 startAmount = 10 * 10 ** 18;
        uint256 balBefore = erc20.balanceOf(owner);
        console.log("owner balance before: ", balBefore);

        vm.prank(owner);
        salaryStreaming.startStream(A, startAmount, 1); // Use startAmount for clarity

        uint256 balAfter = erc20.balanceOf(owner);
        console.log("owner balance after: ", balAfter);
        assertEq(
            balAfter,
            balBefore - startAmount,
            "Balance should decrease by the amount of the stream"
        );

        (, , , bool active) = salaryStreaming.getStream(A);
        assertEq(active, true, "Stream should be active after start");
    }

    // function test_pauseStream(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}
