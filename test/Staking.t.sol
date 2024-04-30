// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StakingPool} from "../src/StakingPool.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {StakingToken} from "../src/StakingToken.sol";

contract StakingPoolTest is Test {
    StakingPool stakingPool;
    RewardToken rewardToken;
    StakingToken stakingToken;
    address owner = address(0xc);
    address staker = address(0xd);

    function setUp() public {
        owner = address(this);
        rewardToken = new RewardToken(address(this));
        stakingToken = new StakingToken(address(owner));
        stakingPool = new StakingPool(
            address(stakingToken),
            address(rewardToken)
        );
    }

    function testCreatePool() public {
        uint256 initialRewardRate = 100;
        uint256 initialRewardReserve = 100e18;
        rewardToken.mint(address(this), initialRewardReserve);
        rewardToken.approve(address(stakingPool), initialRewardReserve);

        stakingPool.createPool(initialRewardRate);

        StakingPool.PoolDataReturnedType memory pool = stakingPool.getPoolByID(
            0
        );
        assertEq(
            pool.rewardRate,
            initialRewardRate,
            "Reward rate should match"
        );
        assertEq(
            pool.rewardReserve,
            initialRewardReserve,
            "Reward reserve should be 100 tokens"
        );
    }

    function testStake() public {
        uint256 initialRewardRate = 100;
        uint256 initialRewardReserve = 100e18;
        rewardToken.mint(address(this), initialRewardReserve);
        rewardToken.approve(address(stakingPool), initialRewardReserve);

        stakingPool.createPool(initialRewardRate);

        uint256 stakeAmount = 5e18;
        vm.startPrank(address(owner));
        stakingToken.mint(staker, stakeAmount);
        vm.stopPrank();

        vm.startPrank(address(staker));
        stakingToken.approve(address(stakingPool), stakeAmount);
        stakingPool.stake(0, stakeAmount);

        uint256 stakeBal = stakingPool.getUserStakeBalance(0, address(staker));
        assertEq(stakeBal, stakeAmount, "Staking error");
    }

    function testUnstake() public {
        uint256 initialRewardRate = 100;
        uint256 initialRewardReserve = 100e18;
        rewardToken.mint(address(this), initialRewardReserve);
        rewardToken.approve(address(stakingPool), initialRewardReserve);

        stakingPool.createPool(initialRewardRate);

        uint256 stakeAmount = 5e18;
        vm.startPrank(address(owner));
        stakingToken.mint(staker, stakeAmount);
        vm.stopPrank();

        vm.startPrank(address(staker));
        stakingToken.approve(address(stakingPool), stakeAmount);
        stakingPool.stake(0, stakeAmount);
        stakingPool.unstake(0);

        uint256 stakeBal = stakingPool.getUserStakeBalance(0, address(staker));
        assertEq(stakeBal, 0, "Unstaking error");
    }

    function testGetUserPoolRewardPerSec() public {
        uint256 initialRewardRate = 100;
        uint256 initialRewardReserve = 100e18;
        rewardToken.mint(address(this), initialRewardReserve);
        rewardToken.approve(address(stakingPool), initialRewardReserve);
        stakingPool.createPool(initialRewardRate);

        uint256 stakeAmount = 5e18;
        vm.startPrank(address(owner));
        stakingToken.mint(staker, stakeAmount);
        vm.stopPrank();

        vm.startPrank(address(staker));
        stakingToken.approve(address(stakingPool), stakeAmount);
        stakingPool.stake(0, stakeAmount);

        uint256 rewardPerSecond = stakingPool.getUserPoolRewardPerSec(
            0,
            staker
        );

        uint256 expectedRewardPerSecond = (stakeAmount * initialRewardRate) /
            86400 seconds;
        assertEq(
            rewardPerSecond,
            expectedRewardPerSecond,
            "Reward per second should match the expected value"
        );
    }

    function testGetUserStakeBalance() public {
        testUnstake();

        uint256 stakeBal = stakingPool.getUserStakeBalance(0, address(staker));
        assertEq(stakeBal, 0, "Unstaking error");
    }

    function testGetUserClaimableReward() public {
        uint256 stakeAmount = 0;
        uint256 initialRewardRate = 100;

        vm.startPrank(address(owner));
        stakingToken.mint(staker, stakeAmount);
        vm.stopPrank();

        testGetUserPoolRewardPerSec();
        uint256 claimableReward = stakingPool.getUserClaimableReward(0, staker);
        vm.startPrank(address(staker));
        stakingToken.approve(address(stakingPool), stakeAmount);
        stakingPool.stake(0, stakeAmount);

        uint256 expectedClaimableReward = (stakeAmount * initialRewardRate) /
            1 seconds;
        assertEq(
            claimableReward,
            expectedClaimableReward,
            "Claimable reward should match the expected value"
        );
    }
}
