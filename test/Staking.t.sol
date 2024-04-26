// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StakingPool} from "../src/StakingContract.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {StakingToken} from "../src/StakingToken.sol";

contract StakingPoolTest is Test {
    StakingPool stakingPool;
    RewardToken rewardToken;
    StakingToken stakingToken;
    address owner = address(0xc);

    function setUp() public {
        owner = address(this);
        rewardToken = new RewardToken(address(this));
        stakingToken = new StakingToken(address(rewardToken));
        stakingPool = new StakingPool(
            address(stakingToken),
            address(rewardToken)
        );
    }

    function testCreatePool() public {
        uint256 initialRewardRate = 100;
        uint256 initialRewardReserve = 100E18;
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
}
