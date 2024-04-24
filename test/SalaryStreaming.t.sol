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

        salaryStreaming = new SalaryStreaming(address(erc20), owner);

        vm.startPrank(owner);
        erc20.approve(address(salaryStreaming), 10000 * 10 ** 18); // Owner approves SalaryStreaming to use their tokens
        vm.stopPrank();
    }

    function test_StartStream() public {
        uint256 startAmount = 10 * 10 ** 18;
        uint256 balBefore = erc20.balanceOf(owner);

        vm.prank(owner);
        salaryStreaming.startStream(A, startAmount, 1); // Use startAmount for clarity

        uint256 balAfter = erc20.balanceOf(owner);
        assertEq(
            balAfter,
            balBefore - startAmount,
            "Balance should decrease by the amount of the stream"
        );

        (, , , bool active) = salaryStreaming.getStream(A);
        assertEq(active, true, "Stream should be active after start");
    }

    function test_StreamPayment() public {
        uint256 startAmount = 10 * 10 ** 18;
        uint256 interval = 1;
        vm.prank(owner);
        salaryStreaming.startStream(A, startAmount, interval);

        vm.warp(1 seconds);

        uint256 expectedBalance = startAmount;
        assertEq(
            erc20.balanceOf(A),
            expectedBalance,
            "Recipient should receive the start amount"
        );
    }

    // function test_pauseStream(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }

    function test_PauseStream() public {
        uint256 startAmount = 10 * 10 ** 18;
        uint256 interval = 1;

        vm.startPrank(owner);
        salaryStreaming.startStream(A, startAmount, interval);

        salaryStreaming.pauseStream(A);

        (, , , bool active) = salaryStreaming.getStream(A);
        vm.stopPrank();
        assertEq(active, false, "Stream should be paused");
    }

    function test_ResumeStream() public {
        uint256 startAmount = 10 * 10 ** 18;
        uint256 interval = 1;
        vm.startPrank(owner);

        salaryStreaming.startStream(A, startAmount, interval);
        salaryStreaming.pauseStream(A);

        salaryStreaming.resumeStream(A);

        (, , , bool active) = salaryStreaming.getStream(A);
        vm.stopPrank();

        assertEq(active, true, "Stream should be resumed");
    }

    function test_GetStream() public {
        uint256 startAmount = 10 * 10 ** 18;
        vm.prank(owner);

        uint256 interval = 1;
        salaryStreaming.startStream(A, startAmount, interval);

        (
            uint256 startTime,
            uint256 totalAmount,
            uint256 returnedInterval,
            bool active
        ) = salaryStreaming.getStream(A);

        assertEq(startTime, block.timestamp, "Start time does not match");
        assertEq(totalAmount, startAmount, "Total amount does not match");
        assertEq(returnedInterval, interval, "Interval does not match");
        assertEq(active, true, "Stream should be active");
    }

    //
    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}
