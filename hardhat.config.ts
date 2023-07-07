import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
import "hardhat-contract-sizer";
import { HardhatUserConfig } from "hardhat/config";

dotenv.config();

const config: HardhatUserConfig = {
    solidity: "0.8.18",
    contractSizer: {
        runOnCompile: true,
        strict: true,
    },
    networks: {
        bnbt: {
            url: process.env.BINANCE_SMART_CHAIN_TESTNET_URL || "",
            accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
        },
        maticmum: {
            url: process.env.MUMBAI_URL || "",
            accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
        },
    },
    etherscan: {
        apiKey: process.env.POLYGON_API_KEY || "",
    },
};

export default config;