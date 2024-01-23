**Truffle 官方网站** https://trufflesuite.com  
**Truffle 模板** https://trufflesuite.com/boxes/  
**学习教程** https://blog.csdn.net/zhongliwen1981/article/details/90353895  

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

--------  

## 5、使用unbox创建项目  

一定要创建、进入新目录：
```shell
md MetaCoin
cd MetaCoin
```
在新目录下 下载 “unbox” MetaCoin box:
```
truffle unbox metacoin
```  
### 成功  
![unbox下载metacoin成功](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/truffle_unbox_suc.png)  

### 【报错 1】找不到truffle-box.json文件  

连接不到网络，在 https://raw.githubusercontent.com 地址下找不到 truffle-box.json文件。  

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
修改 hosts 依然不能解决问题，只能使出杀手锏了，缺啥补啥，直接[下载truffle-box.json文件](https://github.com/truffle-box/metacoin-box/blob/master/truffle-box.json) 放到项目目录下

truffle-box.json 文件内容如下，可拷贝、创建文件。
```json
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
---------------  
## 参考文献：
[Truffle中文文档](https://learnblockchain.cn/docs/truffle/getting-started/creating-a-project.html)    
[Truffle 关于解决 unbox 搭建问题](https://github.com/trufflesuite/truffle/issues/2692)  
[GoogleHosts](https://github.com/googlehosts/hosts/blob/master/hosts-files/hosts)    
[Truffle 连接超时问题](https://blog.csdn.net/Ike_Lin/article/details/108279545)  
[Truffle-box.json](https://github.com/truffle-box/metacoin-box/blob/master/truffle-box.json)  
