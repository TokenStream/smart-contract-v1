// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SubscriptionService {
    IERC20 public token;
    address public owner;
    address nextOwner;

    struct SubscriptionPlan {
        string name;
        uint256 fee;
        uint256 interval;
        address paymentAddress;
        bool active; // Add active status to the plan
    }

    struct Subscriber {
        bool active;
        uint256 lastPaymentTime;
        uint256[] subscriptionIds;
    }

    SubscriptionPlan[] plans;
    mapping(address => Subscriber) subscribers;
    mapping(address => uint256) public balances; // user balance in the contract
    mapping(address => mapping(uint256 => bool)) public activeSubscriptions; // active subscriptions
    mapping(address => mapping(uint256 => bool)) public stoppedSubscriptions; // Track stopped subscriptions

    event SubscriptionStarted(address indexed subscriber, uint256 planId);
    event SubscriptionPaused(address indexed subscriber, uint256 planId);
    event SubscriptionResumed(address indexed subscriber, uint256 planId);
    event SubscriptionStopped(address indexed subscriber, uint256 planId);
    event SubscriptionRenewed(address indexed subscriber, uint256 planId);
    event SubscriptionPlanDeactivated(uint256 planId); // New event for plan deactivation

    constructor(address _token) {
        token = IERC20(_token); //Initialize token and owner
        owner = msg.sender;
    }

    //Check for the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // user deposits into the contract
    function deposit(uint256 _amount) external {
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        token.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender] += _amount;
    }

    //create a subscription plan
    function addSubscriptionPlan(
        string memory _name,
        uint256 _fee,
        uint256 _interval,
        address _paymentAddress
    ) external onlyOwner {
        plans.push(
            SubscriptionPlan(_name, _fee, _interval, _paymentAddress, true)
        );
    }

    //change an existing plan
    function updateSubscriptionPlan(
        uint256 planId,
        string memory _name,
        uint256 _fee,
        uint256 _interval,
        address _paymentAddress
    ) external onlyOwner {
        require(planId < plans.length, "Invalid plan ID");
        plans[planId] = SubscriptionPlan(
            _name,
            _fee,
            _interval,
            _paymentAddress,
            true
        );
    }

    //subscribe to an existing plan
    function startSubscription(uint256 planId) public {
        require(planId < plans.length, "Invalid plan ID");
        require(plans[planId].active, "Plan is not active"); // Check if the plan is active
        require(
            !activeSubscriptions[msg.sender][planId],
            "Already subscribed to this plan"
        );
        require(
            balances[msg.sender] >= plans[planId].fee,
            "Insufficient funds"
        );

        SubscriptionPlan memory plan = plans[planId];
        address _paymentAddress = plan.paymentAddress;

        balances[msg.sender] -= plan.fee;
        token.transfer(_paymentAddress, plan.fee);

        subscribers[msg.sender].subscriptionIds.push(planId);
        activeSubscriptions[msg.sender][planId] = true;

        emit SubscriptionStarted(msg.sender, planId);
    }

    //pause a subscription
    function pauseSubscription(uint256 planId) external {
        require(activeSubscriptions[msg.sender][planId], "Not active");
        activeSubscriptions[msg.sender][planId] = false;
        emit SubscriptionPaused(msg.sender, planId);
    }

    //resume a subscription
    function resumeSubscription(uint256 planId) external {
        require(!activeSubscriptions[msg.sender][planId], "Already active");
        require(
            !stoppedSubscriptions[msg.sender][planId],
            "Subscription has been stopped"
        );
        activeSubscriptions[msg.sender][planId] = true;
        emit SubscriptionResumed(msg.sender, planId);
    }

    // stop a subscription
    function stopSubscription(uint256 planId) external {
        require(activeSubscriptions[msg.sender][planId], "Not subscribed");
        activeSubscriptions[msg.sender][planId] = false;
        stoppedSubscriptions[msg.sender][planId] = true; // Mark the subscription as stopped
        emit SubscriptionStopped(msg.sender, planId);
    }

    function deactivateSubscriptionPlan(uint256 planId) external onlyOwner {
        require(planId < plans.length, "Invalid plan ID");
        plans[planId].active = false; // Set the plan's active status to false
        emit SubscriptionPlanDeactivated(planId); // Emit an event for plan deactivation
    }

    //users customize their subscription
    function createCustomSubscription(
        string memory _name,
        uint256 _fee,
        uint256 _interval,
        address _paymentAddress
    ) external {
        // Add the custom subscription plan
        uint256 planId = plans.length;
        plans.push(
            SubscriptionPlan(_name, _fee, _interval, _paymentAddress, true)
        );

        // Start the subscription for the user
        startSubscription(planId);
    }

    //all subcriptions for a specific user
    function getUserSubscriptions(address user)
        external
        view
        returns (uint256[] memory)
    {
        return subscribers[user].subscriptionIds;
    }

    //all available subscriptions
    function getAllSubscriptionPlans()
        external
        view
        returns (SubscriptionPlan[] memory)
    {
        return plans;
    }

    //change ownership
    function transferOwnership(address _newOwner) external onlyOwner {
        nextOwner = _newOwner;
    }

    function claimOwnership() external {
        require(msg.sender == nextOwner, "not next owner");

        owner = msg.sender;

        nextOwner = address(0);
    }
}
