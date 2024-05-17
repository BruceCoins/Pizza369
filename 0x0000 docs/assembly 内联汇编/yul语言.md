Yul语法
==========

语法规则
----------
Yul可以指定由代码、数据、子对象组成“对象”，对象的代码部分总是由一个大括号包裹的块组成，一个**代码块**内，可以使用以下元素：

**没有分号** 每行代码后不需要分号
**注释** 使用``//``和``/* */``来表示。  
**字母** 例如：``0x123``，``22``或``abc``(32各字符以内的字符串)。  
**内置函数调用** 例如：``add(1,mload(2))``  
**变量声明** 例如：``let x = 7``,``let x:= add(y,2)``或``let x``(初始值为0)  
**标识符(变量)** 例如：``add(2,8)``  
**赋值** 例如：``x := add(y,2)``  
**局部变量的作用域所在的代码块** 一个块的范围使用一对大括号标识，局部变量只能在该代码块范围内有效。作用范围的唯一例外是函数和 for 循环，例如：
```
    {
        let x:= 3 
        {
            let y := add(x,2)
        }
    }
```
> 注意：汇编代码块之间不能通信，即一个汇编代码块中定义的变量，在另一个汇编代码块中不能使用。

**if语句** 例如：
```
    if lt(a,b){ 
        sstore(0, 1) 
    }    
```
**switch语句** 例如:
```
    switch mload(0)
        case 0 { revert() }
        default { mstore(0, 1) }
```
**for循环** 例如：
```
    //相当于 for(i=0; i<10; i++)
    for {let i := 0} lt{i, 10} {i := add(i,1) }
        {
            mstore(i, 7)
        }
```
**函数定义** 例如：
```
    function f(a, b) -> c{
        c := add(a, b)
    }
```

字面量
----------

作为字面量，可以使用。

- 字符串最多32个字符
- 以十进制或十六进制符号表示的整数常数
- ASCII字符串（例如``"abc"``），可能包含十六进制转义``\xNN``和Unicode转义``\uNNN``，其中``N``是十六进制数字。
- 十六进制字符串（例如：``hex"7889"``）。

变量声明
----------

使用``let``关键字来声明变量，变量只能在所定义的``{...}``块内可见。
当编译到EVM时，会创建一个新的堆栈槽，为该变量保留，并在到达块的末端时自动移除。
可以为该变量提供一个初始值，若不提供，默认为零。

变量存储在堆栈中，不直接影响内存或存储。
但可以在内置函数``mstore``,``mload``,``sstore``和``sload``中作为内存或存储位置的指针使用。

当一个变量被引用时，其当前值被复制。
```
    {
        let zero := 0
        let v := calldataload(zero)
        {
            let y := add(sload(v), 1)
            v := y
        } //y在这里被“删除”了
        sstore(v, zreo)
        //v和zero在这里被“删除”
    }
```

如果声明的变量 实际类型 与 默认类型不同时，可使用冒号表示。
接收函数返回的多个值时，也可以在一条语句中声明多个变量。
```
    // 以下代码不会被编译，u32和u256类型尚未实现
    {
        let zero:u32 := 0:u32     //实际需要的是u32类型 
        let v:u256, t:u32 := f()  //接收函数f()返回的不同类型
        let x,y := g()            //接收函数g()返回默认类型
    }
```
根据优化器的设置，编译器可以在变量被最后一次使用后释放堆栈槽，即使它仍然在范围内

赋值
-----------
使用 ``:=``操作符进行赋值，数值数量、类型必须匹配
```
    let v := 0;             // 对变量进行赋值
    v := 2                  // 重新赋值
    let  t := add(v, 2)     // 接收内置函数返回值
    function f() -> a,b{}   // 定义函数f(),返回 a,b
    v,t := f()              // 接收函数f()的多个返回值
    let w:u256, x:u32 := g()// 接收函数g()的多个非默认类型返回值
```

If
-----------
- if 条件句必须有 大括号
- 没有“else” 部分
- 需要多种选择条件时，可考虑使用“switch”来代替
```
    if lt(calldatasize(), 4){
        revert(0,0)
    }
```

Switch
-----------
- 可作为 if 语句的扩展版本。
- 出于安全考虑，控制流不会从一个条件延续到下一个条件。
- 使用``default``回退或作为默认情况。如果``case``覆盖所有可能的值，那么不允许再出现``default``条件，如：判断``bool``类型，则不允许有默认情况。
- 条件的列表没有用大括号括起来，但主题需要大括号(与其他语言不同)。
```
    {
        let x := 0
        switch calldataload(4)
        case 0 {
            x := calldataload(0x24)
        }
        default {
            x := calldataload(0x44)
        }
        sstore(0, div(x,2))
    }
```

循环
-----------
> for 循环
- 由 一个初始部分的头、一个条件、一个迭代部分、一个主体 组成。
- **条件** 必须是一个表达式，其他三个是代码块。
- 若初始化部分在顶层声明了任何变量，这些变量范围将延伸至循环的所有部分。
```
    {
        let x := 0
        for {let i := 0} lt(i, 0x100) {i := add(i, 0x200)}{
            x := add(x, mload(i))
        }
    }
```
> while循环（使用for循环代替）
- 只需将for循环的 初始化、迭代部分 为空即可。
```
    {
        let x := 0
        let i := 0
        for { } lt(i, 0x100) { }{
            x := add(x, mload(i))
            i := add(i, 0x20)
        }
    }
```
> 注意：continue或break语句只能在for循环的主题内使用
```
    for{} true {for {} true {} { break }}
    {
        // break也是合法的，因为它在for循环主体内。
    }
```

函数声明
------------
Yul允许自定义函数。这些不应该与 Solidity 中的函数混淆，因为它们从来不是一个合约的外部接口的一部分，而是独立于 Solidity 函数的命名空间的一部分。  
- 对EVM来说，Yul函数从堆栈中获取参数，结果也放到堆栈中。
- 函数可以定义在任何地方。
- **一个函数中，不能访问该函数之外声明的变量。**
- 返回多个值时，必须用 ``a,b := f(x)``或``let a, b := f(x)``接收并分配变量。
- ``leave``语句用来退出当前函数，类似其他语言中的``return``功能，**但只能在一个函数内使用，且只是退出函数，没有返回值**。
> 注意：EVM语言中有一个内置函数``return``，它可以退出整个执行环境（内部消息调用），而不仅仅是退出当前yul函数
```
    // 通过平方和乘法实现幂函数
    {
        function power(base, exponent) -> result{
            switch exponent
            case 0 { result := 1 }
            case 1 { result := base }
            default {
                result := power(mul(base, base), div(exponent, 2))
                switch mod(exponent, 2)
                    case 1{ result := mul(base, result) }
            }
        }
    }
```
```
    //分配指定长度的内存，并返回内存指针pos
    assembly{
        function allocate(length) -> pos{
            pos := mload(0x40)
            mstore(0x40, add(pos, length))
        }
        let free_memory_pointer := allocate(64)
    }
```

EVM语言及内置函数(操作码)
====================  

- Yul中唯一可用的类型是u256，即Ethereum虚拟机的256位本地类型。

- 标有 ``-`` 的操作码不返回结果，所有其他操作码正好返回一个值。
标有 ``F``， ``H``， ``B``， ``C``， ``I`` 和 ``L`` 的操作码分别
是从Frontier，Homestead，Byzantium，Constantinople，Istanbul或London版本出现的。

- 在下文中， ``mem[a...b)`` 表示从位置 ``a`` 开始到不包括位置 ``b`` 的内存字节，即[a,b)
- ``storage[p]`` 表示插槽 ``p`` 的存储内容。

- 由于Yul管理着局部变量和控制流，所以不能使用干扰这些功能的操作码。
这包括 ``dup`` 和 ``swap`` 指令，以及 ``jump`` 指令，标签和 ``push`` 指令。
     
|          指令                |     |     |                                    解释                                     |
|------------------------------|-----|-----|----------------------------------------------------------------------------|
| stop()                       | `-` | F   | 停止执行，与return(0, 0)相同                                                |
| add(x, y)                    |     | F   | x + y                                                                     |
| sub(x, y)                    |     | F   | x - y                                                                       |
| mul(x, y)                    |     | F   | x * y                                                                       |
| div(x, y)                    |     | F   | x / y 或 如果 y == 0，则为 0                                                |
| sdiv(x, y)                   |     | F   | x / y，对于有符号的二进制补数，如果 y == 0，则为 0                          |
| mod(x, y)                    |     | F   | x % y, 如果 y == 0，则为 0                                                  |
| smod(x, y)                   |     | F   | x % y, 对于有符号的二进制补数, 如果 y == 0，则为 0                          |
| exp(x, y)                    |     | F   | x的y次方                                                                    |
| not(x)                       |     | F   | x的位 "非"（x的每一个位都被否定）                                           |
| lt(x, y)                     |     | F   | 如果 x < y，则为1，否则为0                                                  |
| gt(x, y)                     |     | F   | 如果 x > y，则为1，否则为0                                                  |
| slt(x, y)                    |     | F   | 如果 x < y，则为1，否则为0，适用于有符号的二进制数                          |
| sgt(x, y)                    |     | F   | 如果 x > y，则为1，否则为0，适用于有符号的二进制补数                        |
| eq(x, y)                     |     | F   | 如果 x == y，则为1，否则为0                                                 |
| iszero(x)                    |     | F   | 如果 x == 0，则为1，否则为0                                                 |
| and(x, y)                    |     | F   | x 和 y 的按位 "与"                                                          |
| or(x, y)                     |     | F   | x 和 y 的按位 "或"                                                          |
| xor(x, y)                    |     | F   | x 和 y 的按位 "异或"                                                        |
| byte(n, x)                   |     | F   | x的第n个字节，其中最重要的字节是第0个字节                                   |
| shl(x, y)                    |     | C   | 将 y 逻辑左移 x 位                                                          |
| shr(x, y)                    |     | C   | 将 y 逻辑右移 x 位                                                          |
| sar(x, y)                    |     | C   | 将 y 算术右移 x 位                                                          |
| addmod(x, y, m)              |     | F   | (x + y) % m，采用任意精度算术，如果m == 0则为0                              |
| mulmod(x, y, m)              |     | F   | (x * y) % m，采用任意精度算术，如果m == 0则为0                              |
| signextend(i, x)             |     | F   | 从第 (i*8+7) 位开始进行符号扩展，从最低符号位开始计算                       |
| keccak256(p, n)              |     | F   | keccak(mem[p...(p+n)))   **p到p+n（不包含p+n）的内存字节，左闭右开[ )**    |
| pc()                         |     | F   | 代码中的当前位置                                                            |
| pop(x)                       | `-` | F   | 丢弃值 x                                                                    |
| mload(p)                     |     | F   | mem[p...(p+32)) **从内存p位置开始读取一个32字节(256)的值并加载到调用栈上**   |
| mstore(p, v)                 | `-` | F   | mem[p...(p+32)) := v **从内存位置 "p"开始存储一个 32 字节（256 位）的值 "v"**|
| mstore8(p, v)                | `-` | F   | mem[p] := v & 0xff (只修改了一个字节)   **在内存位置 "x"（32 字节栈值的最小有效字节）存储一个 1 字节（8 位）的值 "y"**         |
| sload(p)                     |     | F   | storage[p]        **读取插槽(存储)P的存储内容**                            |
| sstore(p, v)                 | `-` | F   | storage[p] := v   **从内存p位置开始将数据v进行保存**                       |
| msize()                      |     | F   | 内存的大小，即最大的访问内存索引                                             |
| gas()                        |     | F   | 仍可以执行的气体值                                                          |
| address()                    |     | F   | 当前合约/执行环境的地址                                                     |
| balance(a)                   |     | F   | 地址为A的余额，以wei为单位                                                  |
| selfbalance()                |     | I   | 相当于balance(address())，但更便宜                                         |
| caller()                     |     | F   | 消息调用者（不包括 ``delegatecall`` 调用）。                                |
| callvalue()                  |     | F   | 与当前调用一起发送的wei的数量                                               |
| calldataload(p)              |     | F   | 从位置p开始的调用数据（32字节）                                             |
| calldatasize()               |     | F   | 调用数据的大小，以字节为单位                                                |
| calldatacopy(t, f, s)        | `-` | F   | 从位置f的calldata复制s字节到位置t的内存中                                   |
| codesize()                   |     | F   | 当前合约/执行环境的代码大小                                                 |
| codecopy(t, f, s)            | `-` | F   | 从位置f的code中复制s字节到位置t的内存中                                     |
| extcodesize(a)               |     | F   | 地址为a的代码的大小                                                         |
| extcodecopy(a, t, f, s)      | `-` | F   | 像codecopy(t, f, s)一样，但在地址a处取代码                                  |
| returndatasize()             |     | B   | 最后返回数据的大小                                                          |
| returndatacopy(t, f, s)      | `-` | B   | 从位置f的returndata复制s字节到位置t的内存中                                 |
| extcodehash(a)               |     | C   | 地址a的代码哈希值                                                           |
| create(v, p, n)              |     | F   | 用代码mem[p...(p+n))创建新的合约，发送v数量的wei并返回新地址；错误时返回0       |
| create2(v, p, n, s)          |     | C   | 在keccak256(0xff . this . s . keccak256(mem[p...(p+n)))地址处 创建代码为mem[p...(p+n)]的新合约并发送v 数量个wei和返回新地址， 其中 ``0xff`` 是一个1字节的值，``this`` 是当前合约的地址，是一个20字节的值， ``s`` 是一个256位的大端的值;错误时返回0              |
| call(g, a, v, in, insize, out, outsize)        |     | F   | 调用地址 a 上的合约，以 mem[in..(in+insize)) 作为输入一并发送 g 数量的 gas 和 v 数量的 wei，以 mem[out..(out+outsize)) 作为输出空间。 若错误，返回 0 （比如，gas 用光）若成功，返回 1     |
| callcode(g, a, v, in, insize, out, outsize)    |     | F   | 相当于 ``call`` 但仅仅使用地址 a 上的代码，执行时留在当前合约的上下文当中  |
| delegatecall(g, a, in, insize, out, outsize)   |     | H   | 相当于 ``callcode``, 但同时保留 ``caller`` 和 ``callvalue``            |
| staticcall(g, a, in, insize, out, outsize)     |     | B   | 相当于 ``call(g, a, 0, in, insize, out, outsize)`` 但不允许状态变量的修 |
| return(p, s)                 | `-` | F   | 终止执行，返回 mem[p..(p+s)) 上的数据                                       |
| revert(p, s)                 | `-` | B   | 终止执行，恢复状态变更，返回 mem[p..(p+s)) 上的数据                         |
| selfdestruct(a)              | `-` | F   | 终止执行，销毁当前合约，并且将余额发送到地址 a                              |
| invalid()                    | `-` | F   | 以无效指令终止执行                                                          |
| log0(p, s)                   | `-` | F   | 用 mem[p..(p+s)] 上的数据产生日志，但没有 topic                             |
| log1(p, s, t1)               | `-` | F   | 用 mem[p..(p+s)] 上的数据和 topic t1 产生日志                               |
| log2(p, s, t1, t2)           | `-` | F   | 用 mem[p..(p+s)] 上的数据和 topic t1，t2 产生日志                           |
| log3(p, s, t1, t2, t3)       | `-` | F   | 用 mem[p..(p+s)] 上的数据和 topic t1，t2，t3 产生日志                       |
| log4(p, s, t1, t2, t3, t4)   | `-` | F   | 用 mem[p..(p+s)] 上的数据和 topic t1，t2，t3，t4 产生日志                   |
| chainid()                    |     | I   | 执行链的ID（EIP-1344）                                                      |
| basefee()                    |     | L   | 当前区块的基本费用（EIP-3198和EIP-1559）                                    |
| origin()                     |     | F   | 交易发送者                                                                  |
| gasprice()                   |     | F   | 交易的气体价格n                                                             |
| blockhash(b)                 |     | F   | 区块编号b的哈希值--只针对最近的256个区块，不包括当前区块。                  |
| coinbase()                   |     | F   | 目前的挖矿的受益者                                                          |
| timestamp()                  |     | F   | 自 epoch 开始的，当前块的时间戳，以秒为单位                                 |
| number()                     |     | F   | 当前区块号                                                                  |
| difficulty()                 |     | F   | 当前区块的难度                                                              |
| gaslimit()                   |     | F   | 当前区块的区块 gas 限制                                                     |

> 注意：sstore() 当把值从 0 设置为非 0 时消耗 20,000 gas，当把值改为 0 或保持为 0 不变时消耗 5000 gas

#### 扩展资料：
  - [全面解析 EVM 操作码含义](https://www.ethervm.io/)
  - [官方公布 EVM 操作码 gas 消耗情况](https://ethereum.org/zh/developers/docs/evm/opcodes/)
  - [深入理解 EVM 操作码 注意事项](https://cloud.tencent.com/developer/article/2207590)
  
