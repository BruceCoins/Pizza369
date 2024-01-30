**Truffle 官方网站** https://trufflesuite.com  
**Truffle 模板** https://trufflesuite.com/boxes/  
**学习教程** https://decert.me/tutorial/solidity/tools/truffle_ganache/    

# 环境搭建  
**ubantu** 环境下安装请下载查看 [以太坊安装私有链.docx](https://github.com/BruceCoins/Pizza369/blob/main/0x0000%20docs/%E4%BB%A5%E5%A4%AA%E5%9D%8A%E5%AE%89%E8%A3%85%E7%A7%81%E6%9C%89%E9%93%BE.docx)  

**windows 10** 环境下使用 Truffle，需要四个东西，分别如下:
- **Python** : 需要用到 python 环境
- **Nodejs** :是一个基于 google 浏览器 Chrome 里面的 JavaScript 引擎（V8）的一个平台，可以很容易的构建快速而具有扩展性的网络程序。

    >  
    > **npm** ：是Node.js的包管理工具，Ganache 需要用到 npm。
    >  

- **Truffle** ：以太坊开发框架
- **Ganache CLI**：是在本地使用内存模拟的一个以太坊环境，其基于 Node.js，以前叫TestRPC在开发过程中使用。  

## 1、Python 安装  
安装教程：https://zhuanlan.zhihu.com/p/122435116 

## 2、Nodejs 安装
下载地址：https://nodejs.org/en/download  
安装教程：https://www.runoob.com/nodejs/nodejs-install-setup.html  

查看 nodejs 和 npm 安装版本
```
node -v
npm -v
```

## 3、Truffle 安装  

```
npm install -g truffle
``` 
- 验证安装是否成功 
```cmd
truffle -v   // 查看版本
truffle      // 查看命令行
```
![truffle安装成功了](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/truffle_version.png)

### 【报错 1】：npm ERR! code ERR_SOCKET_TIMEOUT  
![npm下载源报错](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/err_truffle_socket_timeout.png)

#### 问题原因：
报错中的 ERR_S0CKET_TINEOUT 表示安装 npm 包时出现网络连接超时。这通常是由于网络连接不稳定、代理配置不正确或网络设置有问题导致的。
之所以会产生上述问题，是由于默认情况下，npm 使用官方的 npm registry 作为包的下载源。然而，有时官方源的连接可能不稳定，导致下载超时。

#### 解决办法：
将 registry [**设置为淘宝镜像源**](https://blog.csdn.net/t_y_f_/article/details/131387826)  可以提高下载速度并减少连接问题，因为淘宝镜像源在国内具有更好的稳定性和可靠性。  


### 【报错2】：gyp ERR! configure error
![python环境报错](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/err-truffle-python1.png)  
#### 问题原因：  
python 环境的问题。

#### 解决办法： 
查看 python 安装教程，自行安装 https://zhuanlan.zhihu.com/p/122435116  
也可参照此链接进行安装 https://blog.csdn.net/xuecuilan/article/details/90379919

## 4、Ganache-CLI 安装   
- 全局安装
```cmd
npm install -g ganache-cli
```  
![安装canache-cli](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/ganache_install.png)  
- 验证是否安装成功  

因为是通过npm进行的全局安装，可通过命令查看npm所有全局安装的模块
```cmd
npm list -g 
```  
- 启动ganache-cli  
```cmd
ganache-cli
```  
![启动ganache-cli](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/ganache_start.png)  

至此环境安装完成，接下来通过使用 unbox 来创建 Truffle 项目   

[下载 ganache 桌面客户端](https://trufflesuite.com/ganache/)  
![ganache客户端来了](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/ganache_cli.png)
  
--------  

## 5、使用 truffle init 创建空白项目    
使用 `truffle init` 命令可以在当前文件夹内创建一个空白项目：  
```cmd
md TruffleInit         // 创建一个新文件夹作为项目目录
cd TruffleInit         // 进入

truffle init           // 初始化空白项目
``` 
![truffle_init成功](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/truffle_init.png)  

**Truffle项目默认包含以下文件及目录：**

- contracts：存放智能合约文件目录  
- migrations：迁移文件、用来指示如何部署智能合约  
- test：智能合约测试用例文件夹。  
- truffle-config.js：配置文件，配置truffle连接的网络及编译选项  

编写合约看 **7、编写合约** 内容

## 6、使用 box 模板创建项目  

Truffle也提供了很多模板，使用 `truffle unbox <box-name>` 命令来加载模板，在模板基础上创建项目：
```shell
md MetaCoin              // 创建一个新文件夹作为项目目录
cd MetaCoin              // 进入

truffle unbox metacoin   // 下载模板 MetaCoin
```
### 成功  
![unbox下载metacoin成功](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/truffle_unbox_suc.png)  

### 【报错 1】找不到truffle-box.json文件   

![找不到啊](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/truffle_unbox_err1.png)    

    网上查了很多资料，主要的解决方案就是 配置 hosts文件。

- 修改配置文件hosts  
1> 记事本 ---> 右键 ---> 使用管理员身份运行  
2> 文件 ---> 打开 ---> 找到hosts文件  
3> 添加以下内容：  

```cmd
# GitHub Start
192.30.255.112	gist.github.com
192.30.255.112	github.com
192.30.255.112	www.github.com
185.199.111.133	raw.githubusercontent.com
# GitHub End
```

[查看 raw.githubusercontent.com 的 ip 地址](https://sites.ipaddress.com/raw.githubusercontent.com/) ，在以下四个地址中，任选其一尝试：
![ip地址](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/truffle_unbox1.png)

### 【报错 2】connect ETIMEOUT  
测试中，如果只添加 raw.githubusercontent 的 ip 地址依然会报如下错误，所以 github 地址最好也都加上：
![仍然报错](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/truffle_unbox_err2.png)

### 【报错 3】配置完 hosts 仍然报错 connect ETIMEOUT  
修改 hosts 依然不能解决问题，只能使出杀手锏了，缺啥补啥，直接[下载truffle-box.json文件](https://github.com/truffle-box/metacoin-box/blob/master/truffle-box.json) 放到项目目录下。

也可以在项目空间手写一个 truffle-box.json 文件，内容如下，然后 再运行 `truffle unbox <box-name> `命令。
```json
truffle-box.json 文件

{
  "ignore": [
    "README.md",
    ".git",
    ".gitignore"
  ],
  "commands": {
    "Compile contracts": "truffle compile",
    "Migrate contracts": "truffle migrate",
    "Test contracts": "truffle test"
  },
  "hooks": {
    "post-unpack": ""
  }
}
```

## 7、编写合约  
继续在通过 `truffle init` 命令创建的空白项目中进行。    

在 `contracts/` 文件夹下新建一个Counter.sol 文件：
```solidity
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint counter;

    constructor() {
        counter = 0;
    }

    function add() public {
        counter = counter + 1;
    }

    function get() public view returns (uint) {
        return counter;
    }
}
```  
## 8、编译合约  
- ### 配置文件

`truffle-config.js` 用于 Truffle 框架项目配置，在这个文件中，你可以指定编译器、网络、账户和合约的路径等各种配置。  
可参考 [参数配置文档](https://learnblockchain.cn/docs/truffle/reference/configuration.html)  

此处简单配置, 使用 `solc` 配置 Solidity 版本信息：
```json
module.exports = {
      compilers: {
      solc: {
        version: "0.8.9"
      }
    }
  }
```

- ### 进行编译
启动 区块链 环境平台，3 种方法，任选其一即可：    

1> 直接运行 ganache 客户端启动。需另开一个 cmd 窗口运行**编译**命令。  
2> 开 cmd 窗口，使用命令行 `ganache-cli` 启动区块链环境。 需另开一个 cmd 窗口运行**编译**命令。  
3> 开 cmd 窗口，使用命令行 `truffle develop` 启动 truffle 自带的区块链环境。需要在 **项目根目录下** 执行此命令行，然后直接运行 **编译、部署** 命令，无需另开一个 cmd 窗口。  

```cmd
truffle compile
```
成功编译后，会在 `build/contracts/` 目录下生成 `Counter.json`文件， Counter.json 包含了智能合约的 ABI 、字节码（Bytecode）以及合约元数据等。  

![编译成功了](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/truffle_compile.png)  

## 9、部署合约  
在部署合约前，还需要确定：

- 确定部署到哪一个网络， 这可以使用 `truffle-config.js` 来进行配置  
- 确定如何部署合约，例如传递什么参数给合约，这需要我们编写部署脚本  
之后就可以运行 `truffle migrate` 执行部署。

### 配置部署到哪个网络  
部署流程：
1. 在本地的开发者网络（如：Ganache）进行部署，测试及验证代码逻辑的正确性
2. 在测试网络（如：Goerli）进行灰度发布
3. 一切 OK 后部署在主网（如： 以太坊主网）

`truffle-config.js` 中，使用 `networks`: 选项用来配置不同的网络。可以通过指定不同的网络配置，来连接不同的EVM网络， 如下配置了两个网络：  
[具体参数可参考此文档](https://learnblockchain.cn/docs/truffle/reference/configuration.html)  
```json
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      gas: 5500000           //  gas limit
      gasPrice: 10000000000,  // 10 Gwei 
    },
    
    goerli: {
      provider: () => new HDWalletProvider(MNEMONIC,  NODE_RPC_URL),
      network_id: 5,       // Goerli's chain id
      confirmations: 2,    // # of confirmations to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
  }
};
```



---------------  
## 参考文献：
[Truffle中文文档](https://learnblockchain.cn/docs/truffle/getting-started/creating-a-project.html)    
[Truffle 关于解决 unbox 搭建问题](https://github.com/trufflesuite/truffle/issues/2692)  
[GoogleHosts](https://github.com/googlehosts/hosts/blob/master/hosts-files/hosts)    
[Truffle 连接超时问题](https://blog.csdn.net/Ike_Lin/article/details/108279545)  
[Truffle-box.json](https://github.com/truffle-box/metacoin-box/blob/master/truffle-box.json)  
