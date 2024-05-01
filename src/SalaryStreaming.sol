// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ModalContract} from "../src/ModalContract.sol";

contract SalaryStreaming {
    ModalContract public modalContract;

    enum IntervalType {
        None,
        Daily,
        Monthly
    }

    struct Stream {
        uint256 id;
        address recipient;
        uint256 amount;
        uint256 lastPayment;
        uint256 startTime;
        IntervalType intervalType;
        bool active;
        address streamOwner;
    }

    event StreamCreated(
        uint256 indexed streamId,
        address indexed recipient,
        IntervalType intervalType
    );

    event StreamPaused(address indexed recipient, IntervalType intervalType);
    event StreamResumed(address indexed recipient, IntervalType intervalType);
    event StreamStopped(address indexed recipient, IntervalType intervalType);
    event disbursementSuccessful(
        address sender,
        address recipient,
        uint256 amount
    );

    Stream[] public dailyStreams;
    Stream[] public monthlyStreams;

    struct StreamDetails {
        address recipient;
        uint256 amount;
    }

    mapping(address => uint256) public streamIdsByAddress;
    uint256 private idDailyCounter = 0;
    uint256 private idMonthlyCounter = 0;

    function createStream(
        StreamDetails[] calldata _streamDetails,
        IntervalType intervalType
    ) external {
        if (intervalType == IntervalType.Daily) {
            for (uint256 i = 0; i < _streamDetails.length; i++) {
                uint256 _id = idDailyCounter++;
                dailyStreams.push(
                    Stream({
                        id: _id,
                        recipient: _streamDetails[i].recipient,
                        amount: _streamDetails[i].amount,
                        lastPayment: block.timestamp,
                        startTime: block.timestamp,
                        intervalType: IntervalType.Daily,
                        active: true,
                        streamOwner: msg.sender
                    })
                );

                streamIdsByAddress[_streamDetails[i].recipient] = _id;
                emit StreamCreated(
                    _id,
                    _streamDetails[i].recipient,
                    IntervalType.Daily
                );
            }
        } else if (intervalType == IntervalType.Monthly) {
            for (uint256 i = 0; i < _streamDetails.length; i++) {
                uint256 _id = idMonthlyCounter++;
                monthlyStreams.push(
                    Stream({
                        id: _id,
                        recipient: _streamDetails[i].recipient,
                        amount: _streamDetails[i].amount,
                        lastPayment: block.timestamp,
                        startTime: block.timestamp,
                        intervalType: IntervalType.Monthly,
                        active: true,
                        streamOwner: msg.sender
                    })
                );

                streamIdsByAddress[_streamDetails[i].recipient] = _id;
                emit StreamCreated(
                    _id,
                    _streamDetails[i].recipient,
                    IntervalType.Monthly
                );
            }
        }
    }

    function getAllDailyStreams() external view returns (Stream[] memory) {
        return dailyStreams;
    }

    function getAllMonthlyStreams() external view returns (Stream[] memory) {
        return monthlyStreams;
    }

    function stopDailyStream(address recipient) external {
        uint256 streamId = streamIdsByAddress[recipient];
        dailyStreams[streamId].active = false;
        emit StreamPaused(recipient, IntervalType.Daily);
    }

    function stopMonthlyStream(address recipient) external {
        uint256 streamId = streamIdsByAddress[recipient];
        monthlyStreams[streamId].active = false;
        emit StreamPaused(recipient, IntervalType.Monthly);
    }

    function resumeDailyStream(address recipient) external {
        uint256 streamId = streamIdsByAddress[recipient];
        dailyStreams[streamId].active = true;
        emit StreamResumed(recipient, IntervalType.Daily);
    }

    function resumeMonthlyStream(address recipient) external {
        uint256 streamId = streamIdsByAddress[recipient];
        monthlyStreams[streamId].active = true;
        emit StreamResumed(recipient, IntervalType.Monthly);
    }

    function disburseDaily() external {
        for (uint256 i = 0; i < dailyStreams.length; i++) {
            if (dailyStreams[i].active == true) {
                modalContract.transfer(
                    dailyStreams[i].streamOwner,
                    dailyStreams[i].recipient,
                    dailyStreams[i].amount
                );

                emit disbursementSuccessful(
                    dailyStreams[i].streamOwner,
                    dailyStreams[i].recipient,
                    dailyStreams[i].amount
                );
            }
        }
    }

    function disburseMonthly() external {
        for (uint256 i = 0; i < monthlyStreams.length; i++) {
            if (monthlyStreams[i].active == true) {
                modalContract.transfer(
                    monthlyStreams[i].streamOwner,
                    monthlyStreams[i].recipient,
                    monthlyStreams[i].amount
                );

                emit disbursementSuccessful(
                    monthlyStreams[i].streamOwner,
                    monthlyStreams[i].recipient,
                    monthlyStreams[i].amount
                );
            }
        }
    }
}
