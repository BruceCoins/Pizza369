require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require("@nomicfoundation/hardhat-verify");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks:{
    localhost:{
      url:"http://127.0.0.1:8545/",
      PRIVATE_KEY:[process.env.PRIVATEKEY]
    },
    sepolia:{
      url: process.env.SEPOLIA_INFURA_API_KEY,
      accounts:[process.env.PRIVATEKEY]
    },

    ethermain:{
      url: process.env.ETHEREUM_INFURA_API_KEY,
      accounts:[process.env.PRIVATEKEY]
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  sourcify: {
    // Disabled by default
    // Doesn't need an API key
    enabled: true
  }
};
