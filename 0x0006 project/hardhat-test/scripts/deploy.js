const { ethers } = require("hardhat");

// 定义一个异步函数 main，用于部署智能合约
async function main() {
    // 获取部署者 的 以太坊账户信息
    const [deployer] = await ethers.getSigners();
    // 打印部署者的以太坊地址
    console.log(`Deploying contract address: ${deployer.address}`);

    // 获取智能合约工厂
    const Calculator = await ethers.getContractFactory("Calculator");
    // 部署智能合约
    // await Calculator.deploy();
     const calculator = await Calculator.deploy();
    // 打印合约地址
    console.log(`Calculator deployed to : ${calculator.address}`);

    }

main().then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
