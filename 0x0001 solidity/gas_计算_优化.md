## Gas 计算方法  
一笔交易发送到 Ethereum 所需要的 gas :  
```
Gas = Gas Limit x Gas Price
```
Gas Price 用 Gwei 作为单位，1 Gwei = 0.000000001 ETH（十亿分之一）
若 Gas Price = 40 Gwei，即为 0.00000004 ETH

### 交易中节省 gas

- 避免在高峰时段进行交易。
- 适当调低 Priority Fee。
- 切勿调低 Gas Limit。Gas Limit不足会导致无法完成交易，支付的gas也不会返回，造成浪费。而多一些也不会浪费，因为系统只会收取适量的 gas，不会多收。

### 开发中节省 Gas  
#### 尽可能避免从零到一的存储写入  
初始化存储变量是合约可以执行的最昂贵的操作之一。
- 当存储变量从零变为非零时，用户必须支付总共22,100 gas（20,000 gas 用于从零到非零的写入，2,100 gas 用于冷存储访问）。
- 这就是为什么 Openzeppelin 的重入保护使用1和2来注册函数的活动状态，而不是0和1。将存储变量从非零更改为非零只需花费5,000 gas

#### 缓存存储变量  
从存储变量读取至少需要100gas，因为 solidity 不会缓存存储读取。写入要昂贵的多。
因此，应该手动缓存变量，以便进行一次存储读取和一次存储写入。

```solidity
//SPDX0License-Identifier: MIT
pragma solidity 0.8.20;

//读取两次 计数器
contract Counter1{
    uint 256 public number;

    function increment() public{
        require(number < 10);
        number = number + 1;
    }
}

//读取一次 计数器
contract Counter2{
    uint 256 public number;
    
    function increment() public{
        uint256 _number = number;
        require(_number < 10);
        number = _number + 1;
    }
}
```
#### 打包相关变量  
将相关变量打包到同一个槽位中，可以通过最小化昂贵的存储相关操作来减少 gas 成本。
- **手动打包是最高效的**  
举例：通过唯一操作将两个 uint80 值存储在一个变量（uint160）中。
这样只是用一个槽位，在单个事务中存储或读取各个值时更便宜。
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

//总长度160，左移 80 空出卡槽，进行或预算将两个长度80的值放入一个卡槽中
contract GasSavingExample{
    uint160 public packedVariables;

    function packVariables(uint80 x, uint80 y) external{
        packedVariable = uint160(x) << 80 | uint160(y); 
    }

    function unpackVariables() external view returns(uint80, uint80){
        uint80 x = uint80(packedVariables >> 80);
        uint80 y = uint80(packedVariables);
    }
}
```
- **不打包效率最低**  
使用两个存储槽位来存储变量，存储或读取时更昂贵。
```solidity
contract NonGasSavingExample{
    uint256 public var1;
    uint256 public var2;
    function updateVars(uint256 x, uint256 y) external{
        var1 = x;
        var2 = y;
    }

    function loadVars() external view returns( uint256, uint256){
        return (var1, var2);
    }
}
```
#### 打包结构体  
像打包相关状态变量一样，打包结构体成员可以帮助节省gas。
（需要注意的是，在solidity中，结构体成员按顺序存储在合约的存储中，从它们初始化的槽位位置开始）。 

每个 槽位 都是 32 个字节（256 位），可以存放 8 个 uint32，而 uint32 常常用来表示时间戳（最大可以到 2106 年）。  

    举例：以下结构体有三个成员，它们将存储在三个单独的槽位中。若被打包，只需要两个槽位。使读取和写入结构体成员变量更便宜。
- **未打包结构体**  
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Unpacked_Struct{
    struct unpackedStruct{
        uint64 time;    // 64位（8字节）
        uint256 money;  // 256位（32字节）
        address person; // 160位（20字节）
    }

    // 从插槽 0 开始
    unpackedStruct details = unpackedStruct(53_000, 21_000, address(0xdeadbeef));

    function unpack() external view returns (unpackedStruct memory){
        return details;
    }
}
```
- **打包结构体**  
```
contract Packed_Struct{
    struct packedStruct{
        uint64 time;    //64位（8字节）
        address person; //160位（20字节） time和person都可放到 256字节（32位）中
        uint256 money;  //256位（32字节）
    }

    // 插槽从 0 开始
    packedStruct details = packedStruct(53_000, address(0xdeadbeef, 21_000));

    function packed() external view returns (packedStruct memory){
        return details;
    }
}
```
#### 保持字符串长度小于32字节  
在 Solidity 中，字符串是可变长度的动态数据类型，意味着它们的长度可以根据需要进行更改和增长。

如果长度为32字节或更长，它们定义的槽位中存储的是``字符串长度 * 2 + 1``，而实际数据存储在其它位置（该槽位的 keccak 哈希值）。

然而，如果字符串长度小于32字节，``长度 * 2 ``存储在其存储槽位的最低有效字节中，并且字符串的实际数据从定义它的槽位的最高有效字节开始存储。
- **字符串示例（小于32字节）**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract StringStorage1 {
    // 长度小于 32 字节
    // 只是用一个卡槽
    string public exampleString = "hello";

    function getString() public view returns (string memory) {
        return exampleString;
    }
}
```
- **字符串示例（大于32字节）**  
```solidity
contract StringStorage2 {
    // 长度超过 32 字节。
    // 0 号槽：0x00......（长度*2+1）。
    // keccak256(0x00)：存储 "hello "的十六进制表示。
    // 由于文件大小，气体成本增加。
    string public exampleString = "This is a string that is slightly over 32 bytes!";

    function getStringLongerThan32bytes() public view returns (string memory) {
        return exampleString;
    }
}
```
#### 从不更新的变量应为不可变的或常量
在 Solidity 中，不打算更新的变量应该是常量或不可变的。

这是因为常量和不可变值直接嵌入到它们所定义的合约的字节码中，不使用存储空间。

这样可以节省大量的 gas，因为我们不进行任何昂贵的存储读取操作。
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Constants {
    uint256 constant MAX_UINT256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    function get_max_value() external pure returns (uint256) {
        return MAX_UINT256;
    }
}

// 比上面合约消耗更多gas
contract NoConstants {
    uint256 MAX_UINT256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    function get_max_value() external view returns (uint256) {
        return MAX_UINT256;
    }
}
```
#### 使用映射而不是数组以避免长度检查  
- 当存储希望按特定顺序组织，并使用固定``键/索引``检索的项目列表或组时，通常使用数组数据结构是常见的做法。
- 但通过映射，每次读取时可以节省2000多个 gas
```solidity
/// get(0) gas 花费: 4860 
contract Array {
    uint256[] a;    //使用数组

    constructor() {
        a.push() = 1;
        a.push() = 2;
        a.push() = 3;
    }

    function get(uint256 index) external view returns(uint256) {
        return a[index];
    }
}

/// get(0) gas 花费: 2758
contract Mapping {
    mapping(uint256 => uint256) a; //使用映射

    constructor() {
        a[0] = 1;
        a[1] = 2;
        a[2] = 3;
    }

    function get(uint256 index) external view returns(uint256) {
        return a[index];
    }
}
```
在底层，当读取数组的索引值时，Solidity 会添加字节码来检查你是否正在读取有效的索引（即索引严格小于数组的长度），否则会回滚并显示错误（具体为 Panic(0x32)）。这样可以防止读取未分配或更糟糕的已分配存储/内存位置。

由于映射的方式是（简单的键=>值对），不需要进行这样的检查，可以直接从存储槽中读取。重要的是要注意，当以这种方式使用映射时，代码应确保不要读取超出规范数组索引的位置。

#### 使用 unsafeAccess 在数组上避免冗余的长度检查  
使用映射来避免 Solidity 在读取数组时进行的长度检查（同时仍然使用数组）的另一种方法是使用 Openzeppelin 的 Arrays.sol 库中的 unsafeAccess 函数。这使开发人员可以直接访问数组中任意给定索引的值，同时跳过长度溢出检查。但是，仅在确保传递给函数的索引不会超过传递的数组的长度时才使用此方法。

#### 在使用大量布尔值时，使用位图而不是布尔值
一个常见的模式，特别是在空投中，是在领取空投或 NFT 时将地址标记为“已使用”。

然而，由于只需要一个位来存储这些信息，而每个存储槽是 256 位，这意味着可以使用一个存储槽存储 256 个标志/布尔值。

参考：https://www.bcskill.com/index.php/archives/1529.html 

#### 使用++i 而不是 i++

++i 是预递增操作，只需要两个步骤：

- 增加 i 的值
- 返回 i 的值

i++ 是后递增操作，需要 4 个步骤：

- 保存 i 的旧值
- 递增 i 的值，并存放到一个内存临时变量
- 返回 i 的旧值
- 将内存临时变量赋给 i

#### 避免使用 public
如果某个接口既需要被外部访问，也需要被相同合约内的其它接口访问，那么接口实现可以这样：
```solidity
// good
function f0() external {
	_f();
}
function _f() internal {}

// bad, expensive
function f0() public {}
```
访问 internal 方法只需要 JUMP 到对应的 OP 就可以，参数通过栈上的内存地址来传递。但是访问 pubic 方法需要进行参数的内存拷贝，**如果参数较大** 带来的 gas 开销就比较高。

#### 减少调用外部合约  
调用外部合约函数比调用内部函数消耗更多 gas。**除非必要，否则不建议拆分多个合约** ，可以使用多个继承来管理和组织代码。

内部函数调用的 gas 消耗：
```solidity
contract Math {
    function add(uint _x, uint _y) public pure returns (uint) {
        return _x + _y;
    }
}

// 内部调用Math
contract Test is Math {
    uint sum;

    // 消耗 41710 gas
    function calculate(uint _x, uint _y) public {
        sum = add(_x, _y); 
    }
}
```
外部函数调用 gas 消耗：
```solidity
//先部署 Math 合约，获取合约地址
contract Math {
    function add(uint _x, uint _y) public pure returns (uint) {
        return _x + _y;
    }
}

// 通过合约地址调用合约函数
contract Test {
    uint sum;
    address constant MathContractAddr = 0x9549DfbBd66b3Cc078AD834C74b9EE1808Ef3AEB;

    // 外部调用，消耗 43693 gas
    function calculate(uint _x, uint _y) public {
        sum = Math(MathContractAddr).add(_x, _y); 
    }
}
```

#### 默克尔树
使用默克尔树。在合约中保存一组数据的 merkleRoot，提供 ``verify`` 方法验证某条数据在这组数据中。相比使用一个 mapping 或数组来保存全部数据，减少了 gas 消耗。

以 ERC20 代币空投为例。参考 [ENS 空投合约](https://etherscan.io/address/0xc18360217d8f7ab5e7c516566761ea12ce7f9d72#code)。

核心代码：
```solidity
bytes32 public merkleRoot;
    
function claimTokens(uint256 amount, address delegate, bytes32[] calldata merkleProof) external {
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
    (bool valid, uint256 index) = MerkleProof.verify(merkleProof, merkleRoot, leaf);
    require(valid, "ENS: Valid proof required.");
    require(!isClaimed(index), "ENS: Tokens already claimed.");
    
    claimed.set(index);
    emit Claim(msg.sender, amount);

    _delegate(msg.sender, delegate);
    _transfer(address(this), msg.sender, amount);
}
    
function verify(
    bytes32[] memory proof,
    bytes32 root,
    bytes32 leaf
) internal pure returns (bool, uint256) {
    bytes32 computedHash = leaf;
    uint256 index = 0;

    for (uint256 i = 0; i < proof.length; i++) {
        index *= 2;
        bytes32 proofElement = proof[i];

        if (computedHash <= proofElement) {
            // Hash(current computed hash + current element of the proof)
            computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
        } else {
            // Hash(current element of the proof + current computed hash)
            computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            index += 1;
        }
    }

    // Check if the computed hash (root) is equal to the provided root
    return (computedHash == root, index);
}
```


```
Gas = txGas + dataGas + opGas
```
- txGas 是交易花费，如果交易没有创建新的合约，则txGas为 21000，否则txGas为 53000。
- dataGas 是数据花费，交易中data的每个零字节需要花费 4 个 gas，每个非零字节需要花费 16 个 gas。
- opGas 是字节码花费，指运行完所有的 op 所需要的 gas。[opcodes各指令花费](https://www.evm.codes/?fork=shanghai)

在交易 gas 的构成中，dataGas一般远小于opGas，优化的空间也比较小，优化 gas 的主要焦点在opGas上。
大部分的 OPGas 数量是固定的（比如ADD消耗 3 个 gas），少部分 OP 的 gas 消耗是可变的，也是 gas 消耗的大头（比如SLOAD一个全新的非零值需要花费至少 20000 个 gas）


-----------------
其他资料：
[Solidity Gas优化](https://decert.me/tutorial/rareskills-gas-optimization/)
[Solidity进阶之gas优化](https://zhuanlan.zhihu.com/p/549858495)
[智能合约Gas 优化的几个技术](https://learnblockchain.cn/article/4515)
[Solidity Gas优化的奇技淫巧](https://mirror.xyz/0xmobius.eth/xAomQ_AVuYsK9V7VotByi320MqfDM4d_pDiCZ4w-Eok)