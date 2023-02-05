require("@nomiclabs/hardhat-etherscan")
require("hardhat-deploy")
require("@nomicfoundation/hardhat-chai-matchers")
require("@nomiclabs/hardhat-ethers")
require("dotenv").config()
require("hardhat-contract-sizer")
require("hardhat-gas-reporter")
require("prettier")
require("prettier-plugin-solidity")
require("solidity-coverage")

const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL
const MUMBAI_RPC_URL = process.env.MUMBAI_RPC_URL
const FUJI_RPC_URL = process.env.FUJI_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  namedAccounts: {
    deployer: 0,
  },
  gasReporter: {
    enabled: false,
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
    goerli: {
      chainId: 5,
      blockConfirmations: 5,
      url: GOERLI_RPC_URL,
      accounts: [PRIVATE_KEY],
    },
    mumbai: {
      chainId: 80001,
      blockConfirmations: 5,
      url: MUMBAI_RPC_URL,
      accounts: [PRIVATE_KEY],
    },
    fuji: {
      chainId: 43113,
      blockConfirmations: 5,
      url: FUJI_RPC_URL,
      accounts: [PRIVATE_KEY],
    },
  },
}
