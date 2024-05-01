// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Test.sol";
// import "../src/SalaryStreaming.sol";

// contract SalaryStreamingTest is Test {
//     SalaryStreaming public salaryStreaming;

//     address public recipient = address(1);
//     uint256 public amount = 100;
//     SalaryStreaming.IntervalType public intervalType =
//         SalaryStreaming.IntervalType.Daily;

//     function setUp() public {
//         salaryStreaming = new SalaryStreaming();
//     }

//     function testCreateStream() public {
//         salaryStreaming.createStream(
//             [SalaryStreaming.StreamDetails(recipient, amount)],
//             intervalType
//         );
//         assertEq(salaryStreaming.getAllDailyStreams().length, 1);
//         assertEq(salaryStreaming.getAllDailyStreams()[0].recipient, recipient);
//         assertEq(salaryStreaming.getAllDailyStreams()[0].amount, amount);
//     }

//     function testPauseAndResumeStream() public {
//         salaryStreaming.createStream(
//             [salaryStreaming.StreamDetails(recipient, amount)],
//             intervalType
//         );
//         salaryStreaming.stopDailyStream(recipient);
//         assertEq(salaryStreaming.getAllDailyStreams()[0].active, false);
//         salaryStreaming.resumeDailyStream(recipient);
//         assertEq(salaryStreaming.getAllDailyStreams()[0].active, true);
//     }

//     function testDisburseDaily() public {
//         salaryStreaming.createStream(
//             [salaryStreaming.StreamDetails(recipient, amount)],
//             intervalType
//         );
//         salaryStreaming.disburseDaily();
//         // assert that the disbursement was successful
//     }
// }
