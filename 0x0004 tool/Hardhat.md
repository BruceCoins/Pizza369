- [1、环境搭建](#1环境搭建)
  - [1.1\> Nodejs、npm 安装](#11-nodejsnpm-安装)
  - [1.2\> VS code 安装](#12-vs-code-安装)
- [2、项目搭建](#2项目搭建)
  - [2.1\> 创建 npm 项目](#21-创建-npm-项目)
  - [2.2\> 创建 hardhat 项目](#22-创建-hardhat-项目)
  - [2.3\> 编写配置文件](#23-编写配置文件)
  - [2.4\> 编写合约](#24-编写合约)
  - [2.5\> 编译合约](#25-编译合约)
  - [2.6\> 测试合约](#26-测试合约)
  - [2.7\> 部署合约](#27-部署合约)
- [参考文献](#参考文献)

------------------

> [!TIP]
> 此文档对应项目 [hardhat-test](https://github.com/BruceCoins/Pizza369/tree/main/0x0005%20project/hardhat-test)

# 1、环境搭建   

系统：win10  

## 1.1> Nodejs、npm 安装  
需要 Nodejs >= 16.0 版本，安装nodejs的同时，npm也会被安装。   

下载地址：https://nodejs.org/en/download  
安装教程：https://www.runoob.com/nodejs/nodejs-install-setup.html  

查看 Nodejs 和 npm 安装版本
```
$ node -v
$ npm -v
```
## 1.2> VS code 安装  
开发工具选用 VS code，下载地址：https://code.visualstudio.com/download  
根据系统自行选择。 

# 2、项目搭建  
以下搭建项目的命令在 cmd 窗口执行。

## 2.1> 创建 npm 项目  
创建文件夹 `hardhat-test` 存放项目：
```shell
$ mkdir hardhat-test
$ cd harthat-test
$ npm init -y 
```
使用 `npm int -y` 初始化项目，会自动生成一个package.json 配置文件。  
准备工作完成，开始创建harthat项目  

## 2.2> 创建 hardhat 项目
在 hardhat-test 文件夹中执行以下命令：  
- 引入 hardhat 依赖。  
- 安装 [hardhat-toolbox](https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-toolbox) 插件，该插件包含了使用hardhat开发的常用软件包，根目录产生 `node_modules` 文件夹。
```
$ npm install --save-dev hardhat
$ npm install --save-dev @nomicfoundation/hardhat-toolbox
```

> [!CAUTION]
> 使用 hardhat 命令时，以 **npx** 开头

- 创建示例项目：  
```
$ npx hardhat init
```
```

888    888                      888 888               888
888    888                      888 888               888
888    888                      888 888               888
8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
888    888 .d888888 888    888  888 888  888 .d888888 888
888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888

👷 Welcome to Hardhat v2.22.2 👷‍

? What do you want to do? …
❯ Create a JavaScript project
  Create a TypeScript project
  Create a TypeScript project (with Viem)
  Create an empty hardhat.config.js
  Quit
```
通过上下键，选择要创建的项目类型，此处我选择 `Create an empty hardhat.config.js` 来创建一个空项目，之后 回车 确认。  

- 分别创建文件夹`contracts`、`scripts`、`test`分别用来存放 智能合约、部署脚本、测试脚本。   

文件目录说明：  

**`artifacts`：**  存放合约的 ABI 文件和二进制代码文件；  
**`cache`：**  存放 Hardhat 的缓存文件；
**`contracts`：**  存放合约文件；  
**`node_module`：**  node包管理工具，此项目中为hardhat相关工具；  
**`scripts`：**  存放部署脚本文件；  
**`test`：**  存放测试脚本文件；  
**`.gitignore`：**  配置不会上传到github的文件信息，[简单查看规则](https://cloud.tencent.com/developer/article/2289555)，[配置模板](https://github.com/github/gitignore)；  
**`hardhat.config.ts`：**  hardhat 配置文件，配置solidity版本信息、部署网络信息；  
**`package-lock.json`**   
**`package.json`：**   
  


## 2.3> 编写配置文件   
- 【1】安装 dotenv 配置密钥要发布到网络的 API-KEY 信息，执行以下命令，并在项目根目录下创建 `.env`文件，
```shell
$ npm install dotenv
```

- `.env` 文件内容包括 个人私钥、要发布到网络的 API-KEY，此文件应添加到 `.gitignore` 中来避免私钥泄露：
```
# your private key 私钥
PRIVATEKEY="4685**************************73ba133a8eb"

# infura节点服务器获取的 sepolia 测试网访问地址
SEPOLIA_INFURA_API_KEY = "https://sepolia.infura.io/v3/447ec****************d27a558"
```

- 【2】 将 hardhat 插件 `hardhat-toolbox` 和 `dotenv` 添加到配置文件 **hardhat.config.js** 中；
```javascript
require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config;

module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_INFURA_API_KEY,
      accounts: [process.env.PRIVATEKEY],
    }  
  }
};
```
- 只有一个accounts 时，不用使用 `[ ]`


## 2.4> 编写合约  
在 `contracts` 文件夹下编写一个简单加减法合约 Calculator.sol
```solidity
// SPDX-License-Identifier : MIT

pragma solidity ^0.8.0;

//引入console库合约，打印日志
import "hardhat/console.sol";

//简单计算器 加减法
contract Calculator{
    function add(uint256 a, uint256 b ) public pure returns(uint256){
        uint256 c = a + b;
        console.log("a=%s, b=%s, a+b=%s ", a, b, c);
        return c;
    }

    function sub(uint256 a, uint256 b) public pure returns(uint256){
        uint256 c = a - b;
        console.log("a=%s, b=%s, a+b=%s ", a, b, c);
        return a-b;
    }
}
```
## 2.5> 编译合约  
```
$ npx hardhat compile

//-----------编译成功---------------

Compiled 1 Solidity file successfully.

```

## 2.6> 测试合约   
- **编写测试脚本**

使用 Mocha 测试框架、chai 断言库，详请查看 [智能合约测试](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/Contract_Test.md) 内容。    
在 `test` 文件夹下创建测试脚本文件 Calculator.test.js :
```javascript
// 导入 Chai 断言库的 expect 函数
const { expect } = require("chai");

// 定义一个测试套件，用于测试 Calculator 合约
describe("Calculator contract", async function () {
  
  // 部署合约，并返回合约实例
  async function deployCalculator() {
    // 获取 Calculator 合约的合约工厂
    const Calculator = await ethers.getContractFactory("Calculator");
    // 部署 Calculator 合约，获得合约实例 calculator
    const calculator = await Calculator.deploy();
    // 返回合约实例
    return {calculator};
  };
 
  // 第一个测试用例：测试 add 函数是否正确相加两个数字
  it("should add two numbers correctly", async function () {
    // 部署合约，获得合约实例
    const {calculator} = await deployCalculator();
    // 调用 calculator 合约的 add 函数，传入参数 5 和 3
    const result = await calculator.add(5, 3);
    // 使用 Chai 断言库的 expect 函数检查结果是否等于 8
    expect(result).to.equal(8);
  });

  // 第二个测试用例：测试 sub 函数是否正确相减两个数字
  it("should subtract two numbers correctly", async function () {
    // 部署合约，获得合约实例
    const {calculator} = await deployCalculator();
    // 调用 calculator 合约的 sub 函数，传入参数 10 和 4
    const result = await calculator.sub(10, 4);
    // 使用 Chai 断言库的 expect 函数检查结果是否等于 6
    expect(result).to.equal(6);
  });
});
```

- **运行测试脚本**
```
$ npx hardhat test
```
---------------测试通过-----------------
```
Calculator contract
a=5, b=3, a+b=8 
    ✔ should add two numbers correctly (1240ms)
a=10, b=4, a+b=6 
    ✔ should subtract two numbers correctly (71ms)
2 passing (1s)
```

## 2.7> 部署合约   
- **编写部署脚本**  
在 script 文件夹中创建 deploy.js 自动部署脚本：  
```javascript
const { ethers } = require("hardhat");

// 定义一个异步函数 main，用于部署智能合约
async function main() {
    // 获取部署者 的 以太坊账户信息
    const [deployer] = await ethers.getSigners();
    // 打印部署者的以太坊地址
    console.log('Deploying contract address:: ${deployer.address)');

    // 获取智能合约工厂
    const Calculator = await ethers.getContractFactory("Calculator");
    // 部署智能合约，若初始化需要传参数，就写在 depoly("参数") 中
    const calculator = await Calculator.deploy();
    // 打印合约地址 address 不可用时，使用target
    console.log('Calculator deployed to : ${calculator.address}');
}

main()
   .then(() => process.exit(0))
   .catch((error) => {
       console.error(error);
       process.exit(1);
   });
```

- **运行部署脚本**

```
$ npx hardhat run script/deploy.js
```
----------------部署成功-----------------
```
Deploying contract address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Calculator deployed to : 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
```

> [!TIP]
> 若在 `hardhat.config.js` 中配置多个网络环境，可以选择指定网络进行部署。
```
$ npx hardhat run .\script\deploy.js --network <network name>
```
----------如 部署到本地 localhost -------------
```
$ npx hardhat run .\script\deploy.js --network localhost
```

- **启动 hardhat 节点**  
如有需要，可启动 Hardhat 内置的 Hardhat Network 本地以太坊网络，是一个为开发而设计的，启动该本地测试网络服务后，还会生成一系列测试用账户，默认使用第一个。
```
$ npx hardhat node
```




# 参考文献
[hardhat 官网](https://hardhat.org/hardhat-runner/docs/getting-started)  
[20分钟极速学完Hardhat全部内容](https://learnblockchain.cn/article/6187)  
[基于 Solidity、Hardhat、OpenZeppelin 迈向 Web3.0](http://www.uinio.com/Web/Solidity/)  
[ethers.js 文档](https://docs.ethers.org/v6/)  
