## 环境搭建  
**ubantu** 环境下安装请下载查看 [以太坊安装私有链.docx](https://github.com/BruceCoins/Pizza369/blob/main/0x0000%20docs/%E4%BB%A5%E5%A4%AA%E5%9D%8A%E5%AE%89%E8%A3%85%E7%A7%81%E6%9C%89%E9%93%BE.docx)  

**windows 10** 环境下使用 Truffle，需要四个东西，分别如下:
- **Python** : 需要用到 python 环境
- **Nodejs** :是一个基于 google 浏览器 Chrome 里面的 JavaScript 引擎（V8）的一个平台，可以很容易的构建快速而具有扩展性的网络程序。

    >  
    > **npm** ：是Node.js的包管理工具，Ganache 需要用到 npm。
    >  

- **Truffle** ：以太坊开发框架
- **Ganache CLI**：是在本地使用内存模拟的一个以太坊环境，其基于 Node.js，以前叫TestRPC在开发过程中使用。  

### 1、Python 安装  
安装教程：https://zhuanlan.zhihu.com/p/122435116 

### 2、Nodejs 安装
下载地址：https://nodejs.org/en/download
安装教程：https://www.runoob.com/nodejs/nodejs-install-setup.html  

查看 nodejs 和 npm 安装版本
```
node -v
npm -v
```

### 3、truffle 安装  
```
npm install -g truffle
``` 
- 验证安装是否成功 
```cmd
truffle -v   // 查看版本
truffle      // 查看命令行
```
![truffle安装成功了](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/truffle_version.png)

#### 报错1：npm ERR! code ERR_SOCKET_TIMEOUT  
![npm下载源报错](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/err_truffle_socket_timeout.png)

##### 问题原因：
报错中的ERR_S0CKET_TINEOUT表示安装npm包时出现网络连接超时。这通常是由于网络连接不稳定、代理配置不正确或网络设置有问题导致的。
之所以会产生上述问题，是由于默认情况下，npm使用官方的npm registry作为包的下载源。然而，有时官方源的连接可能不稳定，导致下载超时。

##### 解决办法：
将registry [**设置为淘宝镜像源**](https://blog.csdn.net/t_y_f_/article/details/131387826) 可以提高下载速度并减少连接问题，因为淘宝镜像源在国内具有更好的稳定性和可靠性。  


#### 报错2：gyp ERR! configure error
![python环境报错](https://github.com/BruceCoins/Pizza369/blob/main/0x0004%20tool/images/err-truffle-python1.png)  
##### 问题原因：  
python环境的问题。

##### 解决办法： 
查看python安装教程，自行安装 https://zhuanlan.zhihu.com/p/122435116  
也可参照此链接进行安装 https://blog.csdn.net/xuecuilan/article/details/90379919

### 4、安装Ganache-CLI  
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