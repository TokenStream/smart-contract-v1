// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TRiverToken.sol";
import "./Interfaces/IRewardToken.sol";

error ONLY_THE_OWNER_CAN_PERFORM_THIS_ACTION();
error INSUFFICIENT_BALANCE();
error YOU_DO_NOT_HAVE_REWARDS();
error YOU_ARE_NOT_THE_NEXT_OWNER();

contract ModalContract {
    IERC20 public OPToken;
    IRewardToken public TriverToken;
    address public owner;
    address nextOwner;
    uint256 public constant DEPOSIT_FEE_PERCENTAGE = 5; // 0.05% fee

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

        uint256 fee = (_amount * DEPOSIT_FEE_PERCENTAGE) / 10000; // Calculate 0.05% fee
        uint256 totalAmount = _amount + fee;
        if (OPToken.balanceOf(msg.sender) <= totalAmount) {
            revert INSUFFICIENT_BALANCE();
        }
        OPToken.transferFrom(msg.sender, address(this), totalAmount);
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


    //change ownership
    function transferOwnership(address _newOwner) external {
        onlyOwner();
        nextOwner = _newOwner;
    }

    function claimOwnership() external {
        // require(msg.sender == nextOwner, "not next owner");
        if (msg.sender != nextOwner) {
            revert YOU_ARE_NOT_THE_NEXT_OWNER();
        }

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
