const hre = require("hardhat");
async function main(){

    // 获取合约创建人地址
    const [deployer] = await hre.ethers.getSigners();
    console.log("---------Deployed contract by:", deployer.address);

    // 部署合约
    const prizeFactory = await hre.ethers.getContractFactory("Prize");
    const prize = await prizeFactory.deploy();

    // 等待部署
    await prize.waitForDeployment();

    // 获取合约地址
    console.log("---------Contract deployed to:", prize.target);

    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit();
    });