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
- 安装 Mocha 测试框架  
```cmd
$ npm install mocha --save-dev
```
也可以全局安装，但是不推荐  
```cmd
$ npm install -g mocha
```
- 安装 Chai 断言库
```cmd
$ npm install chai --save-dev
```


## 参考文献  
[mocha入门教程](https://matmanjs.github.io/test-automation-training/unit-testing-with-mocha/mocha.html)
[mocha测试框架-truffle ](https://www.cnblogs.com/wanghui-garcia/p/9503810.html)
