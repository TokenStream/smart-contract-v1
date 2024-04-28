// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SalaryStreaming {
    struct Stream {
        uint256 id;
        address recipient;
        uint256 amount;
        uint256 lastPayment;
        uint256 startTime;
        uint256 interval;
        bool active;
    }

    // Array to store all Stream structs
    Stream[] public streams;

    // Mapping to track stream IDs by recipient address
    mapping(address => uint256) public streamIdsByAddress;
    address public admin;

    // Counter for generating unique stream IDs
    uint256 private idCounter = 0;

    event StreamPaused(uint256 indexed streamId, address indexed recipient);
    event StreamResumed(uint256 indexed streamId, address indexed recipient);
    event StreamCreated(uint256 indexed streamId, address indexed recipient);
    event StreamStopped(uint256 indexed streamId, address indexed recipient);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    // Define a struct to represent the stream details
    struct StreamDetails {
        address recipient;
        uint256 amount;
        uint256 interval;
    }

    // Modify the createStream function to accept an array of StreamDetails structs
    function createStream(StreamDetails[] calldata _streamDetails) external {
        require(msg.sender != address(0), "ADDRESS_ZERO_NOT_ALLOWED");

        for (uint256 i = 0; i < _streamDetails.length; i++) {
            // Increment the ID counter for each stream
            uint256 _id = idCounter++;
            streams.push(
                Stream({
                    id: _id,
                    recipient: _streamDetails[i].recipient,
                    amount: _streamDetails[i].amount,
                    lastPayment: block.timestamp,
                    startTime: block.timestamp,
                    interval: _streamDetails[i].interval,
                    active: true
                })
            );

            // Update the mapping with the new stream ID
            streamIdsByAddress[_streamDetails[i].recipient] = _id;

            emit StreamCreated(_id, _streamDetails[i].recipient);
        }
    }

    function pauseStreamByAddress(address _recipient) external onlyAdmin {
        uint256 streamId = streamIdsByAddress[_recipient];
        require(streamId != 0, "Stream not found for the given address");
        require(streams[streamId].active, "Stream not active");
        streams[streamId].active = false;
        emit StreamPaused(streamId, _recipient);
    }

    // Function to resume a stream by recipient address
    function resumeStreamByAddress(address _recipient) external onlyAdmin {
        uint256 streamId = streamIdsByAddress[_recipient];
        require(streamId != 0, "Stream not found for the given address");
        require(!streams[streamId].active, "Stream already active");
        streams[streamId].active = true;
        emit StreamResumed(streamId, _recipient);
    }

    function stopStreamByAddress(address _recipient) external onlyAdmin {
        uint256 streamId = streamIdsByAddress[_recipient];
        require(streamId != 0, "Stream not found for the given address");
        require(streams[streamId].active, "Stream not active");
        streams[streamId].active = false;
        emit StreamStopped(streamId, _recipient);
    }
}

// [["0xb9a00a47c522f6ec6b257c545542361c00f02fcd",100,10],["0xb9a00a47c522f6ec6b257c545542361c00f02fcd",200,10]]

// 0x742d35Cc6634C0532925a3b844Bc454e4438f44e
// 0x5aeda56215b167893e80b4fe645ba6d5bab767de
// 0x27d8d15cbc94527cadf5ec14b69519ae23288b95
// 0x78731d3Ca6b7e34aC0F824c42a7cC18A495cabaB
// 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
