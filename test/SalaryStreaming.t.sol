// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SalaryStreaming.sol";

contract SalaryStreamingTest is Test {
    SalaryStreaming salaryStreaming;
    address admin;

    function setUp() public {
        admin = address(this);
        salaryStreaming = new SalaryStreaming();
    }

    function testCreateStream() public {
        SalaryStreaming.StreamDetails[] memory streamDetails = new SalaryStreaming.StreamDetails[](1);
        streamDetails[0] = SalaryStreaming.StreamDetails({recipient: address(0xc), amount: 100, interval: 10});

        salaryStreaming.createStream(streamDetails);
        emit SalaryStreaming.StreamCreated(0, address(0xc));
    }

    // function testPauseStream() public {
    //     // Setup a stream
    //     // Pause the stream
    //     // Assertions to verify the stream was paused
    // }

    // function testResumeStream() public {
    //     // Setup a stream and pause it
    //     // Resume the stream
    //     // Assertions to verify the stream was resumed
    // }

    // function testStopStream() public {
    //     // Setup a stream
    //     // Stop the stream
    //     // Assertions to verify the stream was stopped
    // }
}
