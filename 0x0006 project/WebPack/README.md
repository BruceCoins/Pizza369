# Truffle 模板 WebPack  

这个盒子是我们使用 Webpack 实现的最基本的 DAPP 正式版本。
包括合约、迁移、测试、用户界面和 Webpack 构建管道。

使用文档： https://trufflesuite.com/boxes/webpack/  
视频说明： https://www.bilibili.com/list/145137942?sid=1742861&desc=1&oid=797325588&bvid=BV1My4y1C7fB  

## MetaMask 使用  

最新版本中需要用到 MetaMask ,操作如下：  

1> 使用命令 `truffle develop` 启动测试区块链（如果使用的是 Ganache，则使用命令 `ganache-cli`）  
    会自动产生 10 个账户，包括账户地址、私钥（下一步会用到）  
    
2> 配置 MetaMask ：  
    【1】MetaMast --> "选择网络" --> "配置网络" --> "添加127.0.0.1：8545"  
    【2】MetaMask --> "选择账户" --> "添加账户" --> "导入账户" --> 添加要导入的账户的私钥 即可

------------

### 报错【1】error:0308010C  

#### 操作：  
启动 app 前端服务时，另开一个窗口，进入app目录下，执行 `npm run dev`
```cmd
cd app
npm run dev
```  

#### 问题描述：
**Error: error:0308010C:digital envelope routines::unsupported**  
![启动app前端报错](https://github.com/BruceCoins/Pizza369/blob/main/0x0005%20project/images/webpack_app_err.png)

#### 报错原因：
    主要是因为 nodeJs V17 版本发布了 OpenSSL3.0 对算法和秘钥大小增加了更为严格的限制，
    nodeJs v17 之前版本没影响，但 V17 和之后版本会出现这个错误。 我的node版本是v18+  

#### 解决方案：【我直接使用 方案3 解决】 

> **方案 1：**  

打开 IDEA 终端，直接输入 

1> Linux & Mac OS： 
export NODE_OPTIONS=--openssl-legacy-provider

2> Windows： 
set NODE_OPTIONS=--openssl-legacy-provider  

> **方案2：**  

卸载当前版本，安装合适的版本  

> **方案3（仅限 Windows ）：**  

在项目 app/package.json 文件的 `scripts` 部分添加 `SET NODE_OPTIONS=--openssl-legacy-provider`  

添加前：
```json
"scripts": {
    "build": "webpack",
    "dev": "webpack-dev-server"
  },
```  
添加后：  
```json
"scripts": {
    "build": "webpack",
    "dev": "SET NODE_OPTIONS=--openssl-legacy-provider && webpack-dev-server"
  },
```
