// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/ModalContract.sol";

error INSUFFICIENT_FUNDS();
error INVALID_ID_PLAN();
error SUBSCRIPTION_HAS_BEEN_STOPPED();
error SUBSCRIPTION_ACTIVE();
error YOU_ARE_NOT_SUBSCRIBED();
error SUBSCRIPTION_NOT_ACTIVE();
error ALREADY_SUBSCRIBED_TO_THIS_PLAN();
error PLAN_IS_NOT_ACTIVE();
error INVALID_PLAN_ID();
error ONLY_THE_ONLY_OWNER_CAN_CALL_THIS_FUNCTION();

contract SubscriptionService {
    ModalContract public modalContract;

    address public owner;

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

    uint256 public fees = 3e18;


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

    function onlyOwner() private view {
        if (msg.sender != owner) {
            revert ONLY_THE_ONLY_OWNER_CAN_CALL_THIS_FUNCTION();
        }
    }

    constructor(address _modal) {
        modalContract = ModalContract(_modal);
        owner = msg.sender;
    }

    //create a subscription plan
    function addSubscriptionPlan(
        string memory _name,
        uint256 _fee,
        uint256 _interval,
        address _paymentAddress
    ) external {
        onlyOwner();

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
    ) external {
        onlyOwner();
        if (planId >= plans.length) {
            revert INVALID_PLAN_ID();
        }

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
    if (planId >= plans.length) {
        revert INVALID_PLAN_ID();
    }

    if (!plans[planId].active) {
        revert PLAN_IS_NOT_ACTIVE();
    }

    if (activeSubscriptions[msg.sender][planId]) {
        revert ALREADY_SUBSCRIBED_TO_THIS_PLAN();
    }

    if (modalContract.getBalances(msg.sender) <= plans[planId].fee) {
        revert INSUFFICIENT_FUNDS();
    }

    SubscriptionPlan memory plan = plans[planId];
    address _paymentAddress = plan.paymentAddress;

    // Deduct the fee from the user's balance
    modalContract.subtractFromBalance(msg.sender, fees);
    modalContract.balancePlus(address(modalContract), fees);


    subscribers[msg.sender].subscriptionIds.push(planId);
    activeSubscriptions[msg.sender][planId] = true;

    emit SubscriptionStarted(msg.sender, planId);
}

    //pause a subscription
    function pauseSubscription(uint256 planId) external {
        if (!activeSubscriptions[msg.sender][planId]) {
            revert SUBSCRIPTION_NOT_ACTIVE();
        }
        activeSubscriptions[msg.sender][planId] = false;
        emit SubscriptionPaused(msg.sender, planId);
    }

    //resume a subscription
    function resumeSubscription(uint256 planId) external {
        if (activeSubscriptions[msg.sender][planId]) {
            revert SUBSCRIPTION_ACTIVE();
        }

        if (stoppedSubscriptions[msg.sender][planId]) {
            revert SUBSCRIPTION_HAS_BEEN_STOPPED();
        }

        activeSubscriptions[msg.sender][planId] = true;
        emit SubscriptionResumed(msg.sender, planId);
    }

    // stop a subscription
    function stopSubscription(uint256 planId) external {
        if (!activeSubscriptions[msg.sender][planId]) {
            revert YOU_ARE_NOT_SUBSCRIBED();
        }
        activeSubscriptions[msg.sender][planId] = false;
        stoppedSubscriptions[msg.sender][planId] = true; // Mark the subscription as stopped
        emit SubscriptionStopped(msg.sender, planId);
    }

    function deactivateSubscriptionPlan(uint256 planId) external {
        onlyOwner();
        // require(planId < plans.length, "Invalid plan ID");
        if (planId >= plans.length) {
            revert INVALID_ID_PLAN();
        }
        plans[planId].active = false; // Set the plan's active status to false
        emit SubscriptionPlanDeactivated(planId); // Emit an event for plan deactivation
    }


    function processSubscriptionPayments() external {
        // Iterate over all active subscriptions for the user
        for (
            uint256 i = 0;
            i < subscribers[msg.sender].subscriptionIds.length;
            i++
        ) {
            uint256 planId = subscribers[msg.sender].subscriptionIds[i];
            SubscriptionPlan memory plan = plans[planId];

            // Check if the current block timestamp matches the user's lastPaymentTime plus the subscription's interval
            if (
                block.timestamp >=
                subscribers[msg.sender].lastPaymentTime + plan.interval
            ) {
                // Ensure the user has enough balance to pay the fee

                if (modalContract.getBalances(msg.sender) <= plan.fee) {
                    revert INSUFFICIENT_FUNDS();
                }

                // Process the payment
                modalContract.subtractFromBalance(msg.sender, plan.fee);

                modalContract.transfer(
                    msg.sender,
                    plan.paymentAddress,
                    plan.fee
                );

                // Update the lastPaymentTime for this subscription
                subscribers[msg.sender].lastPaymentTime = block.timestamp;

                // Emit an event for the payment
                emit SubscriptionRenewed(msg.sender, planId);
            }
        }
    }

    //all subcriptions for a specific user
    function getUserSubscriptions(
        address user
    ) external view returns (uint256[] memory) {
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
}
