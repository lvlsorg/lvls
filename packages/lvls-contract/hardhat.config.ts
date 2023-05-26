// eslint-disable-next-line @typescript-eslint/no-unused-vars
/* global ethers task */
// require('@nomiclabs/hardhat-waffle');
// require("@nomiclabs/hardhat-ethers");
// require('@nomiclabs/hardhat-etherscan');

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import dotenv from "dotenv";
import "hardhat-contract-sizer";

dotenv.config();

const PRIV_KEY = process.env.PRIV_KEY || "";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.15",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  defaultNetwork: "hardhat",
  typechain: {
    target: "ethers-v5",
    outDir: "src/generated/typechain"
  },
  paths: {
    artifacts: "./src/artifacts"
  },
  networks: {
    hardhat: {
      chainId: 31337,
      blockGasLimit: 9999335000000,
      gas: "auto"
    },
    localhost: {
      timeout: 9999000,
      blockGasLimit: 9999335000000,
      url: "http://127.0.0.1:8545",
      accounts: [PRIV_KEY],
      chainId: 31337
    },
    mainnet: {
      url: "https://mainnet.infura.io/v3/2f4d92a0ef5b4b05a0219323bc6b8cbd",
      gasPrice: 11000000000,
      accounts: [PRIV_KEY]
    },
    goerli: {
      url: "https://goerli.infura.io/v3/70a47534d2014f05b7de2607d7862814",
      accounts: [PRIV_KEY]
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/70a47534d2014f05b7de2607d7862814",
      accounts: [PRIV_KEY]
    },
    baobab: {
      url: "https://api.baobab.klaytn.net:8651",
      accounts: [PRIV_KEY]
    },
    mantletestnet: {
      url: "https://rpc.testnet.mantle.xyz/",
      accounts: [PRIV_KEY]
    },
    telostestnet: {
      url: "https://testnet.telos.net/evm",
      accounts: [PRIV_KEY]
    }
  }
};

export default config;
