### Gas 计算方法  
一笔交易发送到 Ethereum 所需要的 gas :  
```
gas = txGas + dataGas + opGas
```
- txGas 是交易花费，如果交易没有创建新的合约，则txGas为 21000，否则txGas为 53000。
- dataGas 是数据花费，交易中data的每个零字节需要花费 4 个 gas，每个非零字节需要花费 16 个 gas。
- opGas 是字节码花费，指运行完所有的 op 所需要的 gas。[opcodes各指令花费](https://www.evm.codes/?fork=shanghai)

在交易 gas 的构成中，dataGas一般远小于opGas，优化的空间也比较小，优化 gas 的主要焦点在opGas上。
大部分的 OP 消耗的 gas 数量是固定的（比如ADD消耗 3 个 gas），少部分 OP 的 gas 消耗是可变的，也是 gas 消耗的大头（比如SLOAD一个全新的非零值需要花费至少 20000 个 gas）
