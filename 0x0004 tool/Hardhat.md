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
- 安装 [hardhat-toolbox](https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-toolbox) 插件，该插件包含了使用hardhat开发的常用软件包。
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
在上一步中引入了 hardhat 插件 `hardhat-toolbox` ，需要将它添加到配置文件 **hardhat.config.js** 中，直接在文件最顶部添加:  
```javascript
require("@nomicfoundation/hardhat-toolbox");
```

## 2.4> 编写合约  
在 `contracts` 文件夹下编写一个简单加减法合约 Calculator.sol
```solidity
// SPDX-License-Identifier : MIT

pragma solidity ^0.8.0;

//简单计算器 加减法
contract Calculator{
    function add(uint256 a, uint256 b ) public pure returns(uint256){
        return a+b;
    }

    function sub(uint256 a, uint256 b) public pure returns(uint256){
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
- 编写测试脚本

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

- 运行测试脚本
```
$ npx hardhat test

//---------------测试通过---------------------
Calculator contract
    ✔ should add two numbers correctly (1274ms)
    ✔ should subtract two numbers correctly (58ms)
2 passing (1s)
```

## 部署合约

# 参考文献
[hardhat 官网](https://hardhat.org/hardhat-runner/docs/getting-started)
