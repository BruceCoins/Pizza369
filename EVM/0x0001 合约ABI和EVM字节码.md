# 字节码和ABI  
- EVM 字节码：智能合约代码 需要先编译成 EVM 字节码 才能运行在 EVM 虚拟机、部署到以太网络上。  
- 合约 ABI ：是 js 与 EVM 字节码交互的中间商。形如：**前端js代码 < ==== \> 合约ABI \< ===== > EVM 字节码(代码编译后)**  

下图显示了 合约 ABI、EVM字节码和外部组件(dApp 和 网络)的架构，左边是编译过程，右边是交互。
![](https://github.com/BruceCoins/Pizza369/blob/main/EVM/image/0x0001-1.png)  

## EVM字节码(ByteCode)
EVM 字节码 是一种低级编程语言，是机器可读，人不可读的，需从高级编程语言（如 solidity）编译后得到。  
EVM 虚拟机 是运行 EVM 字节码，介于操作系统和应用层之间的，来减少应用对操作系统的依赖。
```
字节码案例：
7a417c14602d575b600080fd5b60336049565b6040518082815260200191505060405180910390f35b6000600190509056fea
```

## 合约 ABI
在计算机科学中，ABI(Application Binary Interface) 是两个程序模块直接的接口，通常是操作系统和用户程序直接。  
在以太坊中：  
- 合约 ABI 作为接口，定义了如何调用合约函数、返回数据的标准方案。  
- 合约 ABI 为外部使用而设计，实现了程序（如dApp）到合约、合约到合约的交互。
合约 ABI 用如下 JSON 格式表示  
```json
[
   {
      "constant":true,
      "inputs":[
      ],
      "name":"testFunc",
      "outputs":[
         {
            "name":"",
            "type":"int256"
         }
      ],
      "payable":false,
      "stateMutability":"pure",
      "type":"function"
   }
]
```
合约ABI定义函数名称和参数数据类型，用于对EVM的合约调用进行编码并从交易中读取数据。  
对于如何编码和解码，[合约 ABI 有一个明确的规范](https://docs.soliditylang.org/en/latest/abi-spec.html)。  
### 举例描述编码
数据调用``withdraw()``函数并请求 0.01 eth 作为参数。
```solidity
function withdraw( uint withdraw_amount ) public{}
```
**首先**，``withdraw()`` 函数使用 keccak256 编码，前 4 个字节会用作[功能选择器](https://docs.soliditylang.org/zh/v0.8.16/abi-spec.html#index-1)，选择器标识调用那个函数。
```cmd
// 使用 keccak256 编码
> web3.utils.sha3("withdraw(uint256)")
0x2e1a7d4d13322e7b96f9a57413e1525c250fb7a9021cf91d1540d5b69f16a49f

// 提取前 4 个字节
0x2e1a7d4d
```
**接下来**，参数将以十六进制编码，并附加到有32字节填充到已编码的 ``withdraw()`` 函数。  
```cmd
// 将 ETH 转换为 Wei.
> withdraw_amount = web3.utils.toWei(“0.01", “ether”);
10000000000000000

// 将 Wei 数量转为十六进制.
> withdraw_amount_hex = web3.toHex(withdraw_mount);
0x2386f26fc10000

// 左填充到32位.
> withdraw_amount_padleft = web3.utils.leftPad(withdraw_amount_hex, 32);
0x0000000000000000002386f26fc10000

// 附加到选择器函数 selector(encoded function).
“0x2c1a7d4d” + withdraw_amount_padleft

// 生成最后的 ABI 编码.
0x2c1a7d4d0x0000000000000000002386f26fc10000
```

### 与合约交互，可如下操作  
- 首先 与合约 ABI 签订合约。
- 接下来 用 EVM 字节码创建一个实例。
```javascript
var sampleContract = web3.eth.contract([{"constant":true,"inputs":[],"name":"testFunc","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"pure","type":"function"}]);

var sampleCon = sampleContract.new(
    {
        from: web3.eth.account[0],
        data:
'0x6080604052348015600f57600080fd5b50607e8061001e6000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c8063037a417c14602d575b600080fd5b60336049565b6040518082815260200191505060405180910390f35b6000600190509056fea165627a7a72305820e710d7394e9965c17ead6bb53757a23caee28d75a0a02b483638015a49dac6070029',
        gas: '4700000'
    },function (e, contract){
        console.log(e, contract);
        if(typeof contract.address !== 'undefined') {
            console.log('Contract mined! address:' + contract.address + 'transtionHash' + contract.transactionHash);
        }  
    }
)
``` 
### 使用 solc 命令生成 字节码、ABI
安装
```hack
$ npm install -g solc
```
举例说明：文件名 ``SampleToken.sol``
```solidity
pragma solidty ^0.5.8;

contract SampleContrat{
    function testFunc() public pure returns (int) {
        return 1;
    }
}
```
输出 EVM 字节码
```hack
$ solc --bin SampleToken.sol
> ======= SampleContract.sol:SampleContract =======
Binary:
6080604052348015600f57600080fd5b5060878061001e6000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c8063037a417c14602d575b600080fd5b60336049565b6040518082815260200191505060405180910390f35b6000600190509056fea265627a7a7230582050d33093e20eb388eec760ca84ba30ec42dadbdeb8edf5cd8b261e89b8d4279264736f6c634300050a0032 
```
输出合约 ABI
```hack
$ solc -abi SampleToken.sol
> ======= SampleContract.sol:SampleContract =======
Contract JSON ABI 
[{"constant":true,"inputs":[],"name":"testFunc","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"pure","type":"function"}]
```
如果输出到特定目录，可以使用 ``-o`` 选项进行设置（不能设置输出文件名）。
```hack
$ mkdir build
$ solc --abi -o build SampleToken.sol
```
重新编译时，设置``--overwrite``选项。
```hack
$ solc --abi -o build -overwrite SampleToken.sol 
```

### 参考文献

***

[以太坊合约 ABI 和 EVM 字节码](https://learnblockchain.cn/article/3870)  
在文档 [以太坊安装私有链](https://github.com/BruceCoins/Pizza369/blob/main/docs/%E4%BB%A5%E5%A4%AA%E5%9D%8A%E5%AE%89%E8%A3%85%E7%A7%81%E6%9C%89%E9%93%BE.docx) 中也有实战操作
