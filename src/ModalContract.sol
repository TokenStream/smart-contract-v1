// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20Token.sol";
import "./Interfaces/IRewardToken.sol";

error ONLY_THE_OWNER_CAN_PERFORM_THIS_ACTION();
error INSUFFICIENT_BALANCE();
error YOU_DO_NOT_HAVE_REWARDS();

contract ModalContract {
    IERC20 public OPToken;
    IRewardToken public TriverToken;
    address public owner;
    address nextOwner;
    uint256 public constant REWARD_RATE = 5;

    event DepositSuccessiful(address indexed user, uint256 _amount);
    event WithdrawalSuccessiful(address indexed user, uint256 _amount);

    constructor(address _TriverToken, address _OPToken) {
        OPToken = IERC20(_OPToken);
        //Initialize token and owner
        TriverToken = IRewardToken(_TriverToken);
        owner = msg.sender;
    }

    // user balance in the contract
    mapping(address => uint256) public balances;

    function onlyOwner() private view {
        if (msg.sender != owner) {
            revert ONLY_THE_OWNER_CAN_PERFORM_THIS_ACTION();
        }
    }

    function deposit(uint256 _amount) external {
        require(
            OPToken.balanceOf(msg.sender) >= _amount,
            "Insufficient balance"
        );
        OPToken.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender] += _amount;
        emit DepositSuccessiful(msg.sender, _amount);
    }

    // Function to withdraw from the contract
    function withdraw(uint256 _amount) external {
        if (balances[msg.sender] < _amount) {
            revert INSUFFICIENT_BALANCE();
        }
        balances[msg.sender] - _amount;
        OPToken.transfer(msg.sender, _amount);
        emit WithdrawalSuccessiful(msg.sender, _amount);
    }

    function platformRewards(address _user) external {
        uint256 userBalance = balances[_user];

        if (userBalance <= 0) {
            revert YOU_DO_NOT_HAVE_REWARDS();
        }

        uint256 rewardAmount = (userBalance * REWARD_RATE) / 10000;

        // Transfer the rewards to the user
        TriverToken.transfer(_user, rewardAmount);
    }

    //change ownership
    function transferOwnership(address _newOwner) external {
        onlyOwner();
        nextOwner = _newOwner;
    }

    function claimOwnership() external {
        require(msg.sender == nextOwner, "not next owner");

        owner = msg.sender;

        nextOwner = address(0);
    }

    function getBalances(address _address) external view returns (uint256) {
        return balances[_address];
    }

    function subtractFromBalance(
        address _userAddress,
        uint256 _amount
    ) external {
        balances[_userAddress] = balances[_userAddress] - _amount;
    }

    function transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external {
        if (balances[_sender] <= _amount) {
            revert INSUFFICIENT_BALANCE();
        }

        balances[_sender] = balances[_sender] - _amount;

        OPToken.transfer(_recipient, _amount);
    }
}
