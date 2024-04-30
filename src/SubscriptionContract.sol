// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "smart-contract-v1/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "smart-contract-v1/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SubscriptionContract {
    address public owner;
    address private Admis;

    struct Subscription {
        uint256 amount;
        uint256 start;
        bool active;
        uint256 num;
        address[] services;
    }

    struct User {
        Subscription[] subscriptions;
        mapping(address => bool) hasService;
    }

    mapping(address => User) users;
    mapping(address => uint256) balanceof;

    uint256 public subscriptionDuration;

    event SubscriptionStarted(address indexed user, uint256 amount, address indexed token);
    event SubscriptionStopped(address indexed user, uint256 index);
    event SubscriptionDeleted(address indexed user, uint256 index);
    event Payout(address indexed user, uint256 amount);

    IERC20 public token;

    constructor(IERC20 _token) {
        owner = msg.sender;
        Admis = msg.sender;
        token = _token;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    modifier onlyAdmi() {
        require(msg.sender == Admis, "only contract Admi can call this function");
        _;
    }

    function deposit() external payable returns (uint256) {
        require(msg.sender != address(0), "ADDRESS ZERO NOT VALID");
        require(msg.value > 0, "YOU HAVE RNN OUT OF FUNLDS");

        balanceof[msg.sender] += msg.value;
        return balanceof[msg.sender];
    }

    function createUser() external {
        require(users[msg.sender].subscriptions.length == 0, "User already exists");

        User storage newUser = users[msg.sender];
        newUser.subscriptions.push();
    }

    function addService(address _service, uint256 _amount, uint256 _duration) external {
        // Add subscription service to user
        require(!users[msg.sender].hasService[_service], "Service already added");
        require(_amount > 0, "YOU HAVE RUN OUT OF FOUNDS");
        require(block.timestamp >= _duration, "NOT YET TIME TO PAY");

        subscriptionDuration = _duration;
        balanceof[msg.sender] += _amount;
        users[msg.sender].hasService[_service] = true;
        users[msg.sender].subscriptions[0].services.push(_service);
    }

    function startSubscription(address _user) external returns (bool) {
        // Start subscription
        require(users[msg.sender].hasService[_user] == false, "YOU HAVE TO START THE SERVICE");

        bool success = users[msg.sender].hasService[_user] = true;

        return success;
    }

    function stopSubscription(address _user) external returns (bool) {
        // Stop subscription
        require(users[msg.sender].hasService[_user] == true, "USER HAS NO SUBSCRIPTION");

        bool success = users[msg.sender].hasService[_user] = false;

        return success;
    }

    function checkSubscriptionPayout(address _user, uint256 _duration) external returns (bool) {
        require(users[_user].subscriptions.length > 0, "User has no subscriptions");

        for (uint256 i = 0; i < users[_user].subscriptions.length; i++) {
            if (
                block.timestamp >= users[_user].subscriptions[i].start + subscriptionDuration
                    && users[_user].subscriptions[i].active
            ) {
                subscriptionDuration = _duration;
                uint256 amount = users[_user].subscriptions[i].amount;
                users[msg.sender].hasService[_user] = true;

                // Perform payout here, you can emit an event for tracking purposes
                emit Payout(_user, amount);
            }
        }
        return true;
    }

    function deleteSubscription(address _user, uint256 _num) external returns (bool) {
        // Delete subscription
        require(users[msg.sender].hasService[_user] == true, "YOU DON'T HAVE SERVICE");

        if (users[msg.sender].subscriptions.length < 0) {
            for (uint256 i = 0; i < users[msg.sender].subscriptions.length; i++) {
                if (users[msg.sender].subscriptions[i].num == _num) {
                    users[msg.sender].subscriptions.pop();
                }
            }
        }
        return true;
    }

    function deleteUser() external onlyAdmi {
        require(msg.sender == Admis, "ONLY THE ADMI CAN CALL THIS FUNCTION");

        delete users[msg.sender];
        emit SubscriptionDeleted(msg.sender, 0);
    }

    function withdraw(address _user, uint256 _amount, address _token) external returns (bool) {
        // Withdraw
        require(msg.sender != address(0), "ADDRESS ZERO IS NOT VAILD");
        require(users[msg.sender].hasService[_user] == true, "YOU DON;T HAVE AN ACCOUNT WITH US");
        require(msg.sender == _user, "Only the user can withdraw their funds");
        require(balanceof[msg.sender] >= _amount, "INSUFFICIENT_BALANCE");

        uint256 balance = token.balanceOf(address(this));
        if (_token != address(0)) {
            // Withdraw ethers
            require(address(this).balance >= _amount, "Insufficient contract ethers balance");
            payable(msg.sender).transfer(_amount);
        } else {
            // Withdraw tokens
            require(IERC20(_token).balanceOf(address(this)) >= _amount, "Insufficient contract token balance");
            IERC20(_token).transfer(msg.sender, _amount);
        }
        bool success = token.transfer(_user, balance);

        return success;
    }

    // Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint256 _amount) public returns (bool) {
        // Note that "to" is declared as payable
        require(_to != address(0), "ADDRESS ZERO NOT VAILD");
        require(_amount > 0, "YOUR AMOUNT MOST BR MORE THAN ZERO");
        require(balanceof[msg.sender] >= _amount, "YOUR ACCUNT BALANCEN MOST BE MORE THAN ZERO");

        (bool success,) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");

        return success;
    }

    function setSubscriptionDuration(address _user, uint256 _duration) external onlyOwner {
        require(users[msg.sender].hasService[_user] == true, "YOU DON'T HAVE AN SERVICE");
        require(block.timestamp >= _duration, "IT NOT YET THE TIME FORE NEXT SUBCRITION");

        subscriptionDuration = _duration;

        require(block.timestamp >= subscriptionDuration, "NOT YET THE TIME TO PAY");
    }

    // Other administrative functions can be added as needed
}
