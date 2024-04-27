// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

// import "./IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SalaryStreaming {
    using SafeERC20 for IERC20;
    struct Stream {
        uint256 Id;
        address recipient;
        uint256 totalAmount;
        uint256 lastPayment;
        uint256 startTime;
        uint256 interval; // New: Interval between payments
        bool active;
    }

    //An array of all streams
    Stream[] public allStreams;

    mapping(address => Stream) public streams;
    IERC20 public token;
    uint256 public streamCount;
    address public admin;

    event StreamStarted(
        address indexed recipient,
        uint256 startTime,
        uint256 totalAmount
    );

    event StreamPaused(address indexed recipient);
    event StreamResumed(address indexed recipient);
    event StreamStopped(address indexed recipient);
    event PaymentReceived(address indexed recipient, uint256 amount);

    constructor(address _token, address _admin) {
        token = IERC20(_token);
        admin = _admin;
    }

    function onlyAdmin() private view {
        require(msg.sender == admin, "Only Owner can call this function");
    }

    function startStream(
        address _recipient,
        uint256 _amount,
        uint256 _interval
    ) external {
        msg.sender == admin;
        onlyAdmin();
        require(_recipient != address(0));
        require(
            block.timestamp >= streams[_recipient].lastPayment + _interval,
            "Payment interval not met"
        );
        require(!streams[_recipient].active, "Stream already active");
        require(_amount > 0, "Total amount must be greater than 0");

        uint256 sId = streamCount + 1;
        token.safeTransferFrom(msg.sender, _recipient, _amount);
        // Set the start time once
        uint256 startTime = block.timestamp;
        streams[_recipient] = Stream(
            sId,
            _recipient,
            _amount,
            startTime,
            block.timestamp,
            _interval,
            true
        );

        streamCount = streamCount + 1;

        allStreams.push(streams[_recipient]);

        emit StreamStarted(_recipient, block.timestamp, _amount);
    }

    function pauseStream(address _recipient) external {
        onlyAdmin();
        require(streams[_recipient].active, "Stream not active");
        streams[_recipient].active = false;
        emit StreamPaused(_recipient);
    }

    function resumeStream(address _recipient) external {
        onlyAdmin();
        require(!streams[_recipient].active, "Stream already active");
        streams[_recipient].active = true;
        emit StreamResumed(_recipient);
    }

    function stopStream(uint256 index) public {
        onlyAdmin();
        require(index < allStreams.length, "Index out of bounds");
        require(allStreams[index].active, "Stream not active");

        emit StreamStopped(allStreams[index].recipient); // Emit event before removing

        for (uint256 i = index; i < allStreams.length - 1; i++) {
            allStreams[i] = allStreams[i + 1];
        }
        allStreams.pop();
        streamCount = streamCount - 1;
    }

    function getStream(
        address _recipient
    )
        external
        view
        returns (
            uint256 startTime,
            uint256 totalAmount,
            uint256 interval,
            bool active
        )
    {
        Stream memory stream = streams[_recipient];
        return (
            stream.startTime,
            stream.totalAmount,
            stream.interval,
            stream.active
        );
    }

    function getAllStreams() external view returns (Stream[] memory) {
        return allStreams;
    }

    function stopAllStreams() external {
        onlyAdmin();
        // Mark all streams as inactive first and emit the necessary events
        for (uint256 i = 0; i < allStreams.length; i++) {
            if (allStreams[i].active) {
                allStreams[i].active = false;
                emit StreamStopped(allStreams[i].recipient);
            }
        }

        // Clean up the allStreams array after marking as inactive
        delete allStreams;
        streamCount = 0;
    }
}
