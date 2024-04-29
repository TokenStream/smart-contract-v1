// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Interfaces/IAuthentication.sol";
import "./Interfaces/IRewardToken.sol";
import "./Interfaces/ISalaryStreaming.sol";
import "./Interfaces/IStakingPool.sol";
import "./Interfaces/ISubscriptionService.sol";

contract ModalContract {
    IAuthentication public authentication;
    IRewardToken public rewardToken;
    IStakingPool public stakingPool;
    ISubscriptionService public subscriptionService;
    ISalaryStreaming public salaryStreaming;
    IERC20 public token;
    address public owner;
    address nextOwner;
    uint256 public constant REWARD_RATE = 5;

    struct SubscriptionPlan {
        string name;
        uint256 fee;
        uint256 interval;
        address paymentAddress;
        bool active;
    }

    event DepositSuccessiful(address indexed user, uint256 _amount);
    event WithdrawalSuccessiful(address indexed user, uint256 _amount);

    constructor(
        address _authentication,
        address _rewardToken,
        address _stakingPool,
        address _subscriptionService,
        address _salaryStreaming,
        address _token
    ) {
        authentication = IAuthentication(_authentication);
        rewardToken = IRewardToken(_rewardToken);
        stakingPool = IStakingPool(_stakingPool);
        subscriptionService = ISubscriptionService(_subscriptionService);
        salaryStreaming = ISalaryStreaming(_salaryStreaming);
        token = IERC20(_token); //Initialize token and owner
        owner = msg.sender;
    }

    mapping(address => uint256) public balances; // user balance in the contract

    //Check for the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function deposit(uint256 _amount) external {
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        token.transfer(address(this), _amount);
        balances[msg.sender] += _amount;
        emit DepositSuccessiful(msg.sender, _amount);
    }

    // Function to withdraw from the contract
    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] > _amount, "Insufficient balance");
        balances[msg.sender] - _amount;
        token.transfer(msg.sender, _amount);
        emit WithdrawalSuccessiful(msg.sender, _amount);
    }

    function platformRewards(address _user) external {
        uint256 userBalance = balances[_user];

        require(userBalance > 0, "No balance to reward");

        uint256 rewardAmount = (userBalance * REWARD_RATE) / 10000;

        // Transfer the rewards to the user
        rewardToken.transfer(_user, rewardAmount);
    }

    function addSubscriptionPlan(string memory _name, uint256 _fee, uint256 _interval, address _paymentAddress)
        external
    {
        subscriptionService.addSubscriptionPlan(_name, _fee, _interval, _paymentAddress);
    }

    // Function to create an account
    function createAccount(bytes calldata _name) external {
        authentication.createAccount(_name);
    }

    // Functions to interact with the subscription service
    function startSubscription(uint256 planId) external {
        subscriptionService.startSubscription(planId);
    }

    function pauseSubscription(uint256 planId) external {
        subscriptionService.startSubscription(planId);
    }

    function resumeSubscription(uint256 planId) external {
        subscriptionService.resumeSubscription(planId);
    }

    function stopSubscription(uint256 planId) external {
        subscriptionService.stopSubscription(planId);
    }

    function deactivateSubscriptionPlan(uint256 planId) external {
        subscriptionService.startSubscription(planId);
    }

    function createCustomSubscription(string memory _name, uint256 _fee, uint256 _interval, address _paymentAddress)
        external
    {
        subscriptionService.createCustomSubscription(_name, _fee, _interval, _paymentAddress);
    }
    // Functions to interact with the staking pool

    function stake(uint256 _poolID, uint256 _amount) external {
        stakingPool.stake(_poolID, _amount);
    }

    function createPool(uint256 _rewardRate) external {
        stakingPool.createPool(_rewardRate);
    }

    // Functions to interact with the salary streaming service
    function createStream(address[] calldata recipients, uint256[] calldata amount, uint8[] calldata intervalTypes)
        external
    {
        salaryStreaming.createStream(recipients, amount, intervalTypes);
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
