Requirements for Vesting, implemented in [FixedVestingCliff.sol](FixedVestingCliff.sol)

1. Contract should allow to set a cliff for vesting

2. Cliff if set should be treated as staking during this period and is equal to 5% APY

3. APY can be change by contract owner

4. Cliff period is followed by Vesting appropriate to the allocation

5. Staking rewards during the Cliff period last only until the end of the Cliff

6. Awards for Staking during the Cliff can be collected throughout the period from the beginning of the CLiFF

7. User is able to Claim tokens and put them into the Staking contract

8. Claim operation has a fixed fee of ~$0.5 USD 0.00025ETH, paid by user

9. Contract owner has a possibility:
- of stopping the user's vesting 
- restarting it,
- of stopping calculating rewards during the Cliff period
- zeroing the number of tokens on a given address

10. Tokens under Vesting and Cliff rewards are calculated with every block on the Arbitrum network
