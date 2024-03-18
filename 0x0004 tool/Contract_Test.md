# 智能合约测试  

目前比较流行的开发模式有两种： TDD 和 BDD

**TDD （Test Driven Development 测试驱动开发）**  
- 测试来驱动开发
- 其重点偏向开发
- 测试用例是在约束开发者，使开发者的目标明确，设计出满足需求的系统

**BDD （Behaviour Driven Development 行为驱动开发）**
- 基于TDD发展，保持测试先行的理念
- 其重点偏向设计
- 在测试代码中用一种自然通用语言的方式把系统的行为描述出来
- 将系统的设计和测试用例结合起来，进而驱动开发工作

两种方式各有其特点，我们通常选择的是BDD的方式。  

## 1、Solidity 测试  


## 2、JavaScript 测试（Mocha + Chai）   
[Mocha 测试框架 中文官网](https://mocha.nodejs.cn/) | [Chai 断言库 官网](https://www.chaijs.com/)  
Mocha 是现在最流行的 JavaScript 测试框架（JavaScript test framework）之一，通常与 Chai 断言库搭配使用。  
### 2.1> 安装  
- 安装 Node  
从 Mocha v10.0.0 开始，需要 Node.js v14.0.0 或更高版本，所以首先确保电脑上已经[安装了Node](https://www.runoob.com/nodejs/nodejs-install-setup.html)

- 安装 Mocha 测试框架  
```shell
$ npm install mocha --save-dev
```
也可以全局安装 
```shell
$ npm install -g mocha
```
- 安装 Chai 断言库
```shell
$ npm install chai --save-dev
```
### 2.2> 简单示例  
这是一个针对js 文件的测试脚本，借此了解 Mocha 的几个基本概念。源码 add.js：
```javascript
module.export = function(x, y){
    return x + y
}
```
测试脚本 add.test.js：
```javascript
var add = require("./add.js")
var expext = require("chai")

describe('加法函数测试'，function(){
    it (' 1 + 1 = 2', function(){
        except(add(1,1)).ro.be.equale(2);
    });
});
```
运行测试脚本：
```shell
$ npx mocha add.test.js
```
**关于 Mocha 的几个基本概念**  

- 1> **`测试脚本`** 与所要测试的源码脚本同名，但是后缀名为.test.js（表示测试）或者.spec.js（表示规格）。比如，add.js的测试脚本名字就是add.test.js。测试脚本可以独立执行。  
- 2> **`describe`** 块称为"测试套件"（test suite），表示一组相关的测试。它是一个函数，第一个参数是测试套件的名称（"加法函数的测试"），第二个参数是一个实际执行的函数。测试脚本里面应该包括一个或多个describe块，每个describe块应该包括一个或多个it块。甚至 describe 块里面还可能包含 describe 块。  
- 3> **`it`** 块称为"测试用例"（test case），表示一个单独的测试，是测试的最小单位。它也是一个函数，第一个参数是测试用例的名称（"1 加 1 应该等于 2"），第二个参数是一个实际执行的函数。一个 it 块里面包含一个或多个 断言
- 4> **`断言`** 就是判断源码的实际执行结果与预期结果是否一致，如果不一致就抛出一个错误。测试脚本中 `except(add(1,1)).ro.be.equale(2)`即为断言，意思是调用add(1, 1)，结果应该等于2。

**Truffle使用 Mocha 和 Chai 进行测试**  

使用Truffle框架开发智能合约进行测试时，需要注意到的一个很大的不同是它使用了 **`contract()`** 测试套件替代了 **`describe()`** 测试套件，这个函数基本和 describe() 一样，只不过它可以启用clean-room 功能.  其过程如下:  
- 每次`contract()`函数运行之前，合约会被重新部署到正在运行的以太坊客户端，因此测试是在一个干净的合约环境下进行的。  
- 这个`contract()`函数提供一个由以太坊客户端生成的，可以在编写测试合约使用的账户列表。

比如：  
```javascript
contract('CryptoPunksMarket-setInitial', function (accounts) {});
```
在这里accounts就是会返回在区块链环境上的所有用户的账户来让测试使用  
   
> 如果您不需要一个清洁的测试环境，那么仍然可以使用describe()函数来运行普通的Mocha测试。  

### 2.3> Chai 断言库

## 参考文献  
[mocha入门教程](https://matmanjs.github.io/test-automation-training/unit-testing-with-mocha/mocha.html)
[mocha测试框架-truffle ](https://www.cnblogs.com/wanghui-garcia/p/9503810.html)
[测试框架 Mocha 实例教程](https://www.ruanyifeng.com/blog/2015/12/a-mocha-tutorial-of-examples.html)
