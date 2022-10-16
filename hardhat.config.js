require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

const {PRIVATE_KEY, API_KEY, NODE_URL, ETHERSCAN_API_KEY} = process.env

module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `${NODE_URL}${API_KEY}`,
      accounts: [PRIVATE_KEY]
    },
  },
  etherscan: {
    apiKey: {
      goerli: ETHERSCAN_API_KEY
    }
  },
};

