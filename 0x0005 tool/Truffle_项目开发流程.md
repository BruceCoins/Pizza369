- [1、项目部署流程](#1项目部署流程)
- [2、环境搭建](#2环境搭建)
  - [2.1\> Python 安装](#21-python-安装)
  - [2.2\> Nodejs 安装](#22-nodejs-安装)
  - [2.3\> Truffle 安装](#23-truffle-安装)
    - [【报错 1】：npm ERR! code ERR\_SOCKET\_TIMEOUT](#报错-1npm-err-code-err_socket_timeout)
      - [问题原因：](#问题原因)
      - [解决办法：](#解决办法)
    - [【报错2】：gyp ERR! configure error](#报错2gyp-err-configure-error)
      - [问题原因：](#问题原因-1)
      - [解决办法：](#解决办法-1)
  - [2.4\> Ganache-CLI 安装](#24-ganache-cli-安装)
- [3、 创建项目](#3-创建项目)
  - [3.1\> 使用 unbox 模板创建项目](#31-使用-unbox-模板创建项目)
    - [成功](#成功)
    - [【报错 1】找不到truffle-box.json文件](#报错-1找不到truffle-boxjson文件)
    - [【报错 2】connect ETIMEOUT](#报错-2connect-etimeout)
    - [【报错 3】配置完 hosts 仍然报错 connect ETIMEOUT](#报错-3配置完-hosts-仍然报错-connect-etimeout)
  - [3.2\> 使用 truffle init 创建空白项目](#32-使用-truffle-init-创建空白项目)
  - [3.3\> 编写合约](#33-编写合约)
- [4、编译部署](#4编译部署)
  - [4.1\> ganache的使用](#41-ganache的使用)
    - [4.1.1\> 方法一：使用 ganache-cli](#411-方法一使用-ganache-cli)
    - [4.1.2\> 方法二：使用 ganache 桌面端](#412-方法二使用-ganache-桌面端)
  - [4.2\> 只部署在开发环境](#42-只部署在开发环境)
    - [4.2.1\> 配置文件](#421-配置文件)
    - [4.2.2\> 编译合约](#422-编译合约)
    - [4.2.3\> 部署合约](#423-部署合约)
  - [4.3\> 部署到 测试网、主网](#43-部署到-测试网主网)
    - [4.3.1\> infura 获取API\_KEY](#431-infura-获取api_key)
    - [4.3.2\> chainlink faucets 领取测试网 ETH](#432-chainlink-faucets-领取测试网-eth)
    - [4.3.3\> 配置文件](#433-配置文件)
    - [4.3.4\> 编译合约](#434-编译合约)
    - [4.3.5\> 部署合约](#435-部署合约)
    - [【报错 1】：hit an invalid opcode while deploying](#报错-1hit-an-invalid-opcode-while-deploying)
  - [参考文献：](#参考文献)



---------------

**Truffle 官方网站** https://trufflesuite.com  
**Truffle 模板** https://trufflesuite.com/boxes/  
**学习教程** https://decert.me/tutorial/solidity/tools/truffle_ganache/    

# 1、项目部署流程  
1. 在本地的开发者网络（如：Ganache）进行部署，测试及验证代码逻辑的正确性
2. 在测试网络（如：Goerli）进行灰度发布
3. 一切 OK 后部署在主网（如： 以太坊主网）


# 2、环境搭建  
**ubantu** 环境下安装请下载查看 [以太坊安装私有链.docx](https://github.com/BruceCoins/Pizza369/blob/main/0x0000%20docs/%E4%BB%A5%E5%A4%AA%E5%9D%8A%E5%AE%89%E8%A3%85%E7%A7%81%E6%9C%89%E9%93%BE.docx)  

**windows 10** 环境下使用 Truffle，需要四个东西，分别如下:
- **Python** : 需要用到 python 环境
- **Nodejs** :是一个基于 google 浏览器 Chrome 里面的 JavaScript 引擎（V8）的一个平台，可以很容易的构建快速而具有扩展性的网络程序。

    >  
    > **npm** ：是Node.js的包管理工具，Ganache 需要用到 npm。
    >  

- **Truffle** ：以太坊开发框架
- **Ganache CLI**：是在本地使用内存模拟的一个以太坊环境，其基于 Node.js，以前叫TestRPC在开发过程中使用。  

## 2.1> Python 安装  
安装教程：https://zhuanlan.zhihu.com/p/122435116 

## 2.2> Nodejs 安装
下载地址：https://nodejs.org/en/download  
安装教程：https://www.runoob.com/nodejs/nodejs-install-setup.html  

查看 nodejs 和 npm 安装版本
```
node -v
npm -v
```

## 2.3> Truffle 安装  

```
npm install -g truffle
``` 
- 验证安装是否成功 
```cmd
truffle -v   // 查看版本
truffle      // 查看命令行
```
![truffle安装成功了](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_version.png)

### 【报错 1】：npm ERR! code ERR_SOCKET_TIMEOUT  
![npm下载源报错](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/err_truffle_socket_timeout.png)

#### 问题原因：
报错中的 ERR_S0CKET_TINEOUT 表示安装 npm 包时出现网络连接超时。这通常是由于网络连接不稳定、代理配置不正确或网络设置有问题导致的。
之所以会产生上述问题，是由于默认情况下，npm 使用官方的 npm registry 作为包的下载源。然而，有时官方源的连接可能不稳定，导致下载超时。

#### 解决办法：
将 registry [**设置为淘宝镜像源**](https://blog.csdn.net/t_y_f_/article/details/131387826)  可以提高下载速度并减少连接问题，因为淘宝镜像源在国内具有更好的稳定性和可靠性。  


### 【报错2】：gyp ERR! configure error
![python环境报错](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/err-truffle-python1.png)  
#### 问题原因：  
python 环境的问题。

#### 解决办法： 
查看 python 安装教程，自行安装 https://zhuanlan.zhihu.com/p/122435116  
也可参照此链接进行安装 https://blog.csdn.net/xuecuilan/article/details/90379919

## 2.4> Ganache-CLI 安装   
- 全局安装
```cmd
npm install -g ganache-cli
```  
![安装canache-cli](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/ganache_install.png)  
- 验证是否安装成功  

因为是通过npm进行的全局安装，可通过命令查看npm所有全局安装的模块
```cmd
npm list -g 
```  
- 启动ganache-cli
注意端口，在合约开发 `truffle-config.js` 配置环境变量时需要用到 
```cmd
ganache-cli
```  
![启动ganache-cli](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/ganache_start.png)  


[下载 ganache 桌面客户端](https://trufflesuite.com/ganache/)  

![ganache客户端来了](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/ganache_cli.png)
  
至此环境安装完成，接下来通过使用 unbox 来创建 Truffle 项目   

--------  
# 3、 创建项目   

**Truffle项目默认包含以下文件及目录：**

- **build**： 编译后才生成的文件夹，在 build/contract/ 文件夹中存放 .sol 编译后生成的的json文件，包含了智能合约的 ABI 、字节码（Bytecode）以及合约元数据等
- **contracts**： 存放智能合约文件目录  
- **migrations**： 迁移、部署智能合约文件，文件名以 **数字序号** 为前缀，描述为后缀，如 '1_counter.js'。  
- **test**： 智能合约测试用例文件夹。  
- **truffle-config.js**： 配置文件，配置truffle连接的网络及编译选项  

## 3.1> 使用 unbox 模板创建项目  

Truffle提供了很多模板，使用 `truffle unbox <box-name>` 命令来加载模板，在模板基础上创建项目：
```shell
md MetaCoin              // 创建一个新文件夹作为项目目录
cd MetaCoin              // 进入

truffle unbox metacoin   // 下载模板 MetaCoin
```
### 成功  
![unbox下载metacoin成功](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_unbox_suc.png)  

### 【报错 1】找不到truffle-box.json文件   

![找不到啊](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_unbox_err1.png)    

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
![ip地址](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_unbox1.png)

### 【报错 2】connect ETIMEOUT  
测试中，如果只添加 raw.githubusercontent 的 ip 地址依然会报如下错误，所以 github 地址最好也都加上：
![仍然报错](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_unbox_err2.png)

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
## 3.2> 使用 truffle init 创建空白项目    
使用 `truffle init` 命令可以在当前文件夹内创建一个空白项目：  
```cmd
md TruffleInit         // 创建一个新文件夹作为项目目录
cd TruffleInit         // 进入

truffle init           // 初始化空白项目
``` 
![truffle_init成功](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_init.png)  

## 3.3> 编写合约  
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

# 4、编译部署  
`truffle-config.js` 用于 Truffle 框架项目配置，在这个文件中，你可以指定编译器、网络、账户和合约的路径等各种配置。  
查看 [4.3.3> 配置文件](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/Truffle.md#433-%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6) 部分，也可参考 [Truffle配置文件中文文档](https://learnblockchain.cn/docs/truffle/reference/configuration.html)    

## 4.1> ganache的使用  
### 4.1.1> 方法一：使用 ganache-cli
直接启动 ganache-cli，然后对合约进行编译、部署即可
```
ganache-cli
``` 
### 4.1.2> 方法二：使用 ganache 桌面端
- 启动 ganache 桌面端， 点击 “new workspace” ：

![newworkspace](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/ganache_cli_newspace.png)

- 配置参数并启动：

![配置参数](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/ganache_cli_newspace2.png)  

- **注意端口号**、默认使用第一个用户账号地址：  

![注意端口](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/ganache_cli_newspace3.png)  

- 使用 `truffle migrate` 部署合约，注意 交易hash、合约地址、账号地址:  

![部署合约](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/ganache_cli_newspace4.png)  

- 与 ganache 桌面端数据进行比对，可以看到已经部署成功：  

![比较ganache桌面数据](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/ganache_cli_newspace5.png)  

## 4.2> 只部署在开发环境  
### 4.2.1> 配置文件  
只需简单配置, 使用 `solc` 配置编译器 solidity 版本信息：
```
module.exports = {
      compilers: {
      solc: {
        version: "0.8.9"
      }
    }
  }
```
### 4.2.2> 编译合约  
启动 本地环境，3 种方法，任选其一即可：    

方法 1> 直接运行 ganache 客户端启动。需另开一个 cmd 窗口运行**编译**命令。（如图）   
方法 2> 开 cmd 窗口，使用命令行 `ganache-cli` 启动区块链环境。 需另开一个 cmd 窗口运行**编译**命令。（如图）    
方法 3> 开 cmd 窗口，使用命令行 `truffle develop` 启动 truffle 自带的区块链环境。需要在 **项目根目录下** 执行此命令行，然后直接运行 **编译、部署** 命令，无需另开一个 cmd 窗口。    

```cmd
truffle compile
```
成功编译后，会在 `build/contracts/` 目录下生成 `Counter.json`文件， Counter.json 包含了智能合约的 ABI 、字节码（Bytecode）以及合约元数据等。  

![编译成功了](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_compile.png)  

### 4.2.3> 部署合约  
```cmd
truffle migrate
```
- 使用 `ganache` 时，与编译合约使用一个窗口即可（如图）
- 使用 `truffle develop` 时，不需另开一个窗口

![部署成功了](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_migrate.png) 


## 4.3> 部署到 测试网、主网  
- 需使用 truffle-hardware 提供器。
- 安装dotenv模块、hardware提供器 
```cmd
npm install dotenv --save
npm install truffle-hdwallet-provider
```

### 4.3.1> infura 获取API_KEY  
- 节点供应商 [infura](https://www.infura.io/):免费注册申请获得连接到 测试网、主网 的 API_KEY，参数配置在  `.env` 文件中的 INFURA_API_KEY

![节点api-key](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/infura_2.png)

### 4.3.2> chainlink faucets 领取测试网 ETH  
- 通过水龙头 [Chainlink Faucets](https://faucets.chain.link/) 获取测试网代币


### 4.3.3> 配置文件  
- 在项目的根目录中创建一个名为 `.env` 的新文件（dotenv需要）并添加以下内容：  
```
MNEMONIC = "<即钱包私钥或助记词>"
SEPOLIA_INFURA_API_KEY = "https://sepolia.infura.io/v3/<Your-API-Key>"
GOERLI_INFURA_API_KEY = "https://goerli.infura.io/v3/<Your-API-Key>"

```

- `truffle-config.js` 配置 本地开发网络、以太坊测试网、以太坊主网 
```javascript
require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const { MNEMONIC, SEPOLIA_INFURA_API_KEY, GOERLI_INFURA_API_KEY } = process.env;

module.exports = {
  networks: {

    // 本地开发网络二选一即可，只是端口不同而已
    // 1> 本地开发网络 truffle develop
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"  // 匹配任何网络
    },

    // 2> 本地开发网络 ganache
    ganache: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"  // 匹配任何网络
    }
    
    // 当前可使用的以太测试网：Goerli 和 Sepolia（其他测试网废弃公告 https://www.ethereum.cn/Eth2/testnet-deprecation/）
    // 1> 以太测试网 Goerli    
    goerli: {
      provider: () => new HDWalletProvider(MNEMONIC,  GOERLI_INFURA_API_KEY),
      network_id: 5       // Goerli 网络id
    },

    // 2> 以太测试网 Sepolia
    sepolia: {
        provider: () => new HDWalletProvider(MNEMONIC, SEPOLIA_INFURA_API_KEY),
        network_id: 11155111       // Sepolia 网络id
    }

    // 以太主网
    advanced: {
      provider: () => new HDWalletProvider(mnemonic, `https://mainnet.infura.io`),
      network_id: 1,       // Custom network
    // gas                  - use gas and gasPrice if creating type 0 transactions
    // gasPrice             - all gas values specified in wei
    // maxFeePerGas         - use maxFeePerGas and maxPriorityFeePerGas if creating type 2 transactions (https://eips.ethereum.org/EIPS/eip-1559)
    // maxPriorityFeePerGas 
   
    }
  }
};
```
更详细的 `truffle-config.js`配置信息，请查看[Truffle 官方网络配置文档](https://trufflesuite.com/docs/truffle/reference/configuration/#networks)  和 [登链社区的Truffle配置文档](https://learnblockchain.cn/docs/truffle/reference/configuration.html)  
对于每一个配置的网络，在未明确设置以下交易参数时，使用其默认值：  

**gas** ：部署合约的gas上限，默认值：4712388  
**gasPrice** ：部署合约时的gas价格，默认值：100000000000 wei，即100 shannon  
**from** ：执行迁移脚本时使用的账户，默认使用以太坊节点旳第一个账户  
**provider** ：默认的web3 provider，使用host和port配置选项构造：new Web3.providers.HttpProvider("http://<host>:<port>")  
**websockets** ：需要启用此选项以使用确认监听器，或者使用.on或.once监听事件。默认值为false

### 4.3.4> 编译合约  
```cmd
truffle compile
```

### 4.3.5> 部署合约    

如果是真实的网络，如上的 goerli 网络，则需要提供提交交易账号的助记词 与 节点RPC URL （节点 URL 可以在 https://chainlist.org/ 获取）。

注意要在 Goerli 上进行部署，你需要将Goerli-ETH发送到将要进行部署的地址中。  
可以从水龙头免费或一些测试币，这是Goerli的一个水龙头: [- Alchemy Goerli Faucet](https://goerlifaucet.com/)

- 【1】直接部署到指定网络
选择部署到配置文件`truffle-config.js`中设置的网络，如下部署到 ganache 中
详细的参数信息，可参考 [truffle-migrate - 部署合约](http://cw.hubwiz.com/card/c/truffle-5-manual/1/1/14/)
```javascript
// truffle migrate --network <网络名称>
truffle migrate --network ganache
```
- 【2】通过部署脚本进行部署
编写部署脚本（也称迁移文件），放在 `migrations` 目录下，添加一个文件 **1_counter.js**:
```javascript
// 选择要运行的合约 "Counter"
const Counter = artifacts.require("Counter");

module.exports = function (deployer) {

 deployer.deploy(Counter);

};
```
（部署脚本的编写可参考相关 [中文文档](https://learnblockchain.cn/docs/truffle/getting-started/running-migrations.html))

请注意，文件名以**数字序号**为前缀，后缀为描述。 编号前缀是必需的，是因为Truffle 按序号（从小到大）依次执行部署脚本，以便记录迁移是否成功运行，编号 还有记录 运行迁移文件顺序的作用。  
```javascript
// truffle migrate -f <数字序号> --network <网络名称> ,选择合约脚本（ 1_counter.js ）部署到指定网络（主网）中
truffle migrate -f 1 --network advanced  
```
在进行部署时，会发起一笔 创建合约交易， 交易完成后，会在链上生成一个合约地址， 如下图就是创建合约交易的详情：  

![合约脚本运行成功](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_migrate_script.png)

可在区块链浏览器中通过 `transaction hash` 查看具体信息：  
塞波利亚测试网浏览器：[https://sepolia.etherscan.io/](https://sepolia.etherscan.io/)  
以太坊主网浏览器：[https://etherscan.io/](https://etherscan.io/)  

根据交易hash【 0xb78e61fd2a331216af908ace5ec90cc3d41d2918466de593c3d8253e6ca19331 】，在 sepolia 浏览器中查看部署详情：  
![在sepolia中查看](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_migrate_script2.png)

### 【报错 1】：hit an invalid opcode while deploying  
执行 `truffle migrate` 命令进行部署时报错：

![hit](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_migrate_err1.png)  

通过分析查资料了解到极有可能是 solc 版本问题导致，于是在 `truffle-config.js` 中进行了设置，降低了 `solc` 版本，有人降到 `0.5.1` 起作用。  

![solc version](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_migrate_err1_sol.png)   

再次执行  `truffle migrate` 命令：  

![truffle ganache1](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_ganache_1.png)  

对照启动的 `ganache-cli` 可以看到成功了：   

![truffle ganache2](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20tool/images/truffle_ganache_2.png)


---------------  
## 参考文献： 
[Truffle中文文档](https://learnblockchain.cn/docs/truffle/getting-started/creating-a-project.html)    
[Truffle 关于解决 unbox 搭建问题](https://github.com/trufflesuite/truffle/issues/2692)  
[GoogleHosts](https://github.com/googlehosts/hosts/blob/master/hosts-files/hosts)    
[Truffle 连接超时问题](https://blog.csdn.net/Ike_Lin/article/details/108279545)  
[Truffle-box.json](https://github.com/truffle-box/metacoin-box/blob/master/truffle-box.json)  
[Truffle详细配置文件参数文档](https://trufflesuite.com/docs/truffle/reference/configuration/#networks)
[truffle部署合约到以太坊主网上](https://www.jianshu.com/p/a11bcea09809)
[truffle部署指定的合约到指定网络](https://blog.csdn.net/u013288190/article/details/123849688)
[登链社区的Truffle配置文档](https://learnblockchain.cn/docs/truffle/reference/configuration.html) 
  

