Requirements for Staking, implemented in [FixedStaking.sol](FixedStaking.sol)

1. The user has the opportunity to staking GSWIFT tokens

2. The reward for Staking is 5% per year (APY), reward is paid also in GSWIFT tokens

3. APY can be change by contract owner

4. User can submit his staked tokens for unbounding (unblocking) at any time (the unbonding period lasts 7 days)

5. Unbonding operation has a fixed fee of ~$0.5 USD 0.00025ETH, paid by user

6. Unbonding fee can be change by contract owner

7. The number of maximum simultaneous unbonding packages in the same period is 5 (7 days)

8. If a user has 5 unboudnig packages (whether to scalim or in a period of less than 7 days) he has to claim unblocked tokens to be able to start another unbonding

9. Claiming tokens from unbonding allows you to collect tokens from all unblocked unbonding packages (if the period of 7 days has passed from submitting the unbonding claim)

10. Claim operation has a fixed fee of ~$0.5 USD 0.00025ETH, paid by user

11. Rewards for staking can be put back in the stake, so called restake, without a fee

12. Staking rewards are calculated with every block on the Arbitrum network
