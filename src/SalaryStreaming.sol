// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SalaryStreaming {
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
    }

    event StreamCreated(
        uint256 indexed streamId,
        address indexed recipient,
        IntervalType intervalType
    );

    event StreamPaused(address indexed recipient, IntervalType intervalType);
    event StreamResumed(address indexed recipient, IntervalType intervalType);
    event StreamStopped(address indexed recipient, IntervalType intervalType);

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
                        active: true
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
                        active: true
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
        emit StreamPaused(recipient, IntervalType.Daily);
    }

    function resumeMonthlyStream(address recipient) external {
        uint256 streamId = streamIdsByAddress[recipient];
        monthlyStreams[streamId].active = true;
        emit StreamPaused(recipient, IntervalType.Monthly);
    }
}
