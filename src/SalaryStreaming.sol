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

    Stream[] public streams;
    mapping(address => uint256) public streamIdsByAddress;
    address public admin;
    uint256 private idCounter = 0;

    event StreamPaused(uint256 indexed streamId, address indexed recipient);
    event StreamResumed(uint256 indexed streamId, address indexed recipient);
    event StreamCreated(
        uint256 indexed streamId,
        address indexed recipient,
        IntervalType intervalType
    );
    event StreamStopped(uint256 indexed streamId, address indexed recipient);

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
        uint8[] calldata _intervalTypes
    ) external {
        onlyAdmin();
        require(
            _streamDetails.length == _intervalTypes.length,
            "Stream details and interval types arrays must have the same length"
        );

        for (uint256 i = 0; i < _streamDetails.length; i++) {
            uint256 _id = idCounter++;
            streams.push(
                Stream({
                    id: _id,
                    recipient: _streamDetails[i].recipient,
                    amount: _streamDetails[i].amount,
                    lastPayment: block.timestamp,
                    startTime: block.timestamp,
                    intervalType: IntervalType(_intervalTypes[i]),
                    active: true
                })
            );

            streamIdsByAddress[_streamDetails[i].recipient] = _id;
            emit StreamCreated(
                _id,
                _streamDetails[i].recipient,
                IntervalType(_intervalTypes[i])
            );
        }
    }

    function getAllDailyStreams() external view returns (Stream[] memory) {
        return dailyStreams;
    }

    function getAllMonthlyStreams() external view returns (Stream[] memory) {
        return monthlyStreams;
    }

    function pauseStream(
        address recipient,
        IntervalType intervalType
    ) external {
        if (intervalType == IntervalType.Daily) {
            for (uint256 i = 0; i < dailyStreams.length; i++) {
                if (
                    dailyStreams[i].recipient == recipient &&
                    dailyStreams[i].active
                ) {
                    dailyStreams[i].active = false;
                    emit StreamPaused(recipient, IntervalType.Daily);
                    break;
                }
            }
        } else if (intervalType == IntervalType.Monthly) {
            for (uint256 i = 0; i < monthlyStreams.length; i++) {
                if (
                    monthlyStreams[i].recipient == recipient &&
                    monthlyStreams[i].active
                ) {
                    monthlyStreams[i].active = false;
                    emit StreamPaused(recipient, IntervalType.Monthly);
                    break;
                }
            }
        }
    }

    function stopStream(address _recipient) external {
        onlyAdmin();
        uint256 streamId = streamIdsByAddress[_recipient];
        if (streamId == 0) {
            revert STREAM_NOT_FOUND_AT_THE_GIVEN_ADDRESS();
        }

        if (!streams[streamId].active) {
            revert STERAM_IS_NOT_ACTIVE();
        }

        streams[streamId].active = false;
        emit StreamStopped(streamId, _recipient);
    }

    function checkDailySubscriptions() external view returns (Stream[] memory) {
        Stream[] memory dailyStreams = new Stream[](streams.length);
        // this counts the number of daily streams
        uint256 count = 0;

        for (uint256 i = 0; i < streams.length; i++) {
            if (streams[i].intervalType == IntervalType.Daily) {
                dailyStreams[count] = streams[i];
                count++;
            }
        }

        // Create a new array with the exact size needed
        Stream[] memory result = new Stream[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = dailyStreams[i];
        }

        return result;
    }

    function checkMonthlySubscriptions()
        external
        view
        returns (Stream[] memory)
    {
        Stream[] memory monthlyStreams = new Stream[](streams.length);
        // this counts the number of daily streams

        uint256 count = 0;
        for (uint256 i = 0; i < streams.length; i++) {
            if (streams[i].intervalType == IntervalType.Monthly) {
                monthlyStreams[count] = streams[i];
                count++;
            }
        }

        // Create a new array with the exact size needed
        Stream[] memory result = new Stream[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = monthlyStreams[i];
        }

        return result;
    }
}
// [["0xb9a00a47c522f6ec6b257c545542361c00f02fcd",100],["0x742d35Cc6634C0532925a3b844Bc454e4438f44e",200]]
// [["0x27d8d15cbc94527cadf5ec14b69519ae23288b95",100],["0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C",200]]
// 0x742d35Cc6634C0532925a3b844Bc454e4438f44e
// 0x5aeda56215b167893e80b4fe645ba6d5bab767de
// 0x27d8d15cbc94527cadf5ec14b69519ae23288b95
// 0x78731d3Ca6b7e34aC0F824c42a7cC18A495cabaB
// 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
