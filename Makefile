include .env


deployStakingToken:
	forge create --rpc-url ${URL} \
		--constructor-args $(initialOwner) \
		--private-key ${PRIVATE_KEY} \
		--etherscan-api-key ${ETHERSCAN_API_KEY} \
		--verify \
		src/StakingToken.sol:StakingToken

deployRewardToken:
	forge create --rpc-url ${URL} \
    --constructor-args $(initialOwner) \
    --private-key ${PRIVATE_KEY} \
    --etherscan-api-key ${ETHERSCAN_API_KEY} \
    --verify \
    src/RewardToken.sol:RewardToken

deployStakingPool:
	forge create --rpc-url ${URL} \
    --constructor-args $(_stakeTokenAddress) $(_rewardTokenAddress) \
    --private-key ${PRIVATE_KEY} \
    --etherscan-api-key ${ETHERSCAN_API_KEY} \
    --verify \
    src/StakingPool.sol:StakingPool

deploySalaryStreaming:
	forge create --rpc-url ${URL} \
    --constructor-args $() \
    --private-key ${PRIVATE_KEY} \
    --etherscan-api-key ${ETHERSCAN_API_KEY} \
    --verify \
    src/SalaryStreaming.sol:SalaryStreaming


deployModalContract:
	forge create --rpc-url ${URL} \
    --constructor-args $(_TriverToken) $(_OPToken) \
    --private-key ${PRIVATE_KEY} \
    --etherscan-api-key ${ETHERSCAN_API_KEY} \
    --verify \
    src/ModalContract.sol:ModalContract