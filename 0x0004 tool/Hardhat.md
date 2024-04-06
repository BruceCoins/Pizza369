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
```shell
$ mkdir hardhat-test
$ cd harthat-test
$ npm init -y 
```
使用 `npm int -y` 初始化项目，会自动生成一个package.json 配置文件，其内容如下：
```json
{
  "name": "hardhat-test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```
准备工作完成，开始创建harthat项目  

## 2.2> 创建 hardhat 项目
在 hardhat-test 文件夹中执行以下命令：  
- 引入 hardhat 依赖  
- 安装 hardhat 插件 [hardhat-toolbox](https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-toolbox)，该插件包含了使用hardhat开发的常用软件包
```
$ npm install --save-dev hardhat
$ npm install --save-dev @nomicfoundation/hardhat-toolbox
```
> [!CAUTION]
> 使用 hardhat 命令时，以 **npx** 开头

创建示例项目：  
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
分别创建文件夹`contracts`、`scripts`、`test`分别用来存放 智能合约、部署脚本、测试脚本。  

## 2.3> 编写合约  
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
## 2.4> 编译合约  
```
$ npx hardhat compile
```
成功后返回信息：`Compiled 1 Solidity file successfully.`  

## 2.5> 测试合约  


# 参考文献
[hardhat 官网](https://hardhat.org/hardhat-runner/docs/getting-started)
