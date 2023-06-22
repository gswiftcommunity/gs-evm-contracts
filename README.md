# Gameswift - EVM Smart Contracts

This monorepository contains the source code for the Gameswift smart contracts on the Ethereum Virtual Machine (EVM).

More information about the architecture, usage, and function of the smart contracts can be found in the
official [documentation](https://docs.gameswift.io/) page.

## Contracts

| Contract                   | Description                         | 
|----------------------------|-------------------------------------|
| [`GameSwift.sol`](contracts/token/GameSwift.sol)  | Gameswift token (ERC20).                   |
| [`Airdrop.sol`](contracts/airdrop/Airdrop.sol) | Contract to perform airdrop for community. |
| [`Staking.sol`](contracts/staking/Staking.sol) | Staking contract.                          |
| [`Vesting.sol`](contracts/vesting/Vesting.sol) | Vesting contract.                          |

## Development

### Environment Setup

- Node.js 14.x
- npm 6.x
- Truffle v5.x
- Solidity v0.8.x

1. Clone the repository:

```bash
git https://github.com/GameSwift/gs-evm-contracts
```

2. Navigate to the repository folder:

```bash
cd gs-evm-contracts
```

3. Install the dependencies using npm:

```bash
npm install
```

4. Compaile contracts using 

```bash
npx hardhat compile
```

## License

Copyright 2023 Gameswift