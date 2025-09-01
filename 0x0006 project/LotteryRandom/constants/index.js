const {ethers, BigNumber} = require("hardhat");

const LINK_TOKEN = "0x779877A7B0D9E8603169DdbD7836e478b4624789";
const VRF_COORDINATOR = "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625";
const KEY_HASH = "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c";
const FEE = ethers.utils.parseEther("0.0001");
module.exports = {LINK_TOKEN, VRF_COORDINATOR, KEY_HASH ,FEE};