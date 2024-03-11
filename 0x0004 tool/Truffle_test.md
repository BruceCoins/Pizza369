# Truffle 框架智能合约测试    
## 1、Truffle测试概述
- **智能合约测试的两种方法：**  
  1> 区块链级别的 Solidity 测试。  
  2> DApp级别的 JavaScript 测试。
    
- **智能合约测试的类型主要有三种：**   
  1> 单元测试：测试合约的单个函数或功能。  
  2> 集成测试：测试合约间的交互，确保各部分代码组合起来也可以按期望的方式运行。  
  3> 系统测试：测试整个dapp（去中心化应用）或系统。

- 从测试方法上来说：  
  使用 Solidity 编写测试用例是测试智能合约的内部行为。编写单元测试调用合约方法，检测智能合约函数的返回值以及状态变量的值；编写集成测试来检查智能合约直接的交互。  
  使用 JavaScript 编写测试用例是确保合约正确的外部行为。主要使用web3.js、 Mocha 和 Chai 断言 编写测试脚本。

 简单来说，Solidity 测试用例主要用于之恩那个合约内部实现逻辑的验证，可用于单元测试、集成测试；而 JavaScript 测试用例主要用于智能合约外部行为的验证，通常用于集成测试。  

> 测试代码放到 test 文件夹下，

## 2、示例项目  
准备两个合约 `Background.sol`和`EntryPoint.sol`:   
`Background` 是一个内部合约，DApp 前端不会直接和它交互。  
`EntryPoint` 是设计为供 DApp交互的智能合约，在 `EntryPoint` 合约会引用 `Background` 合约。

`Background.sol`合约代码如下：  
```solidity
//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Background {

    uint[] private values;

    // 存数据
    function storeValue(uint value) public {
        values.push(value);
    }

    // 获取指定数据
    function getValue(uint initial) public view returns(uint) {
        return values[initial];
    }

    // 获取数据数量
    function getNumberOfValues() public view returns(uint) {
        return values.length;
    }
}
```
`EntryPoint.sol`合约代码如下：
```solidity
//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "./Background.sol";

contract EntryPoint {

    //存放合约地址的变量
    address public backgroundAddress;

    //构造函数：传入 Background.sol 合约部署的地址，赋值给 backgroundAddress
    constructor(address _background) public {
        backgroundAddress = _background;
    }

    //返回地址，此处为 Background.sol 合约的部署地址
    function getBackgroundAddress() public view reurns(address){
        return backgroundAddress;
    }

    //保存两个数据 
    function storeTwoValues(uint first, uint second) public {
        Background(backgroundAddress).storeValue(first);
        Background(backgroundAddress).sotreValue(second);
    }
    
    //获取存放数据的数量
    function getNumbersOfValues() public view return(uint) {
        return Background(backgroundAddress).getNumberOfValues();
    }
}
```
由于 stroeTwoValues(uint, uint) 函数两次调用 Background 合约中的同一个函数，因此对这个函数进行单元测试比较困难。  
getNumbersOfValues() 也同样如此，因此这两个函数更适合进行集成测试。

## 3、用 Solidity 编写测试用例  
### 3.1> 单元测试  
【1】编写测试合约 TestBackground.sol，用来测试 Background.sol 合约，确保它：    
- 在`values`数组中保存新的值
- 按索引返回`values`
- 在`values`数组中保存多个值
- 返回`values`数组的大小

具体代码如下：  
```solidity
//SPDX-Lincese-Identifier:MIT
pragma solidity >=0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployeAddress.sol";
import "../../../contracts/Background.sol"

contract TestBackground{
    Background public background;

    //在每一个函数运行前 先执行此函数
    function beforeEach() public{
        background = new Background();
    }

    //测试是否能正确存储一个值
    function testItStoresOneValue() public{
        uint value = 5;
        background.storeValue(value);
        uint result = background.getValue(0);
        Assert.equal(result, value, "It should store the correct value");
    }

    //测试是否能正确获取 存储数据的数量
    function testItGetCorrectNumberOfValues() public{
        background.storeValue(99);
        uint newSize = background.getNumberOfValues();
        Assert.equal(newSize, 1, "It should increase the size");
    }
    //测试能否正存储多个值
    function testItStoresMultipleValues() public{
        for(uint8 i = 1; i < 10; i++){
            uint value = i;
            background.storeValue(value);
            uint result = background.getValue(i);
            Assert.equal(result, value, "It should store the correct value for multiple values");
        }
    }
    
}
```
【2】编写测试合约 TestEntryPoint.sol， 用来测试合约 EntryPoint.sol，验证合约功能是否符合预取，  

具体代码如下：
```
//SPDX-License-Identifier:MIT
pragma solidity >= 0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddress.sol";
import "../../../contracts/Background.sol";
import "../../../contracts/EntryPoint.sol";

contract TestEntryPoint{
    function testItHasCorrectBackground() public{
        Background backgroundTest = new Background();
        EntryPoint entryPoint = new EntryPoint(address(backgroundTest));
        address expected = address(backgroundTest);
        address target = entryPoint.getBackgroundAddress();
        Assert.equal(target, expected, "It should set the correct background");
    }
}

```












--------------------
## 参考资料：  
[实战以太坊智能合约测试【Truffle】](https://developer.aliyun.com/article/751576)
