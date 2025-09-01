/** @type import('hardhat/config').HardhatUserConfig */

require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config({path:".env"});

const INFURA_API_KEY_URL = process.env.INFURA_API_KEY_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
//const ETHERSCAN_KEY = process.env.ETHERSCAN_KEY;

module.exports = {
  solidity: "0.8.24",

  networks:{
    sepolia:{
      url : INFURA_API_KEY_URL,
      accounts :[PRIVATE_KEY],
    },
  }
};
