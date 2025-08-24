## 一、ETH 概述
1. 缩短出块时间   
2. Proof of work（工作量证明） ---> Proof of stake（权益证明） 
3.智能合约  

## 二、ETH 账户  
基于账户的模型 ---> 重放攻击(解决：交易nonce计数器、链ID、签名包含唯一信息)  

外部账户：公钥、私钥钥对控制（包括：账户余额、nonce计数器）  
合约账户：不能发起交易，只能由外部账户发起交易。但是可以调用另外一个合约（包括：balance、nonce、代码code、相关状态storage）  

**”三棵树“：状态树、交易树、收据树**  

## 三、ETH 状态树  

(key,value)结构存储数据   

**key**： 账户地址：160位 十六进制显示40位    
**value**： 账户状态，包括账户余额、交易次数（nonce）、合约账户的代码哈希和存储根（storage root）等。这些信息会通过递归长度前缀编码（RLP）进行序列化后存储。序列化（RLP，只支持字节数组）    

### 【1】 trie（前缀树）数据结构  
```
     ( )
   /  |  \
  t   a   i
 / \       \
o    e      n
   / | \   /
  a  d  n  n 
```
上图是一棵 ``Trie`` 树，表示了关键字集合 ``{“a”, “to”, “tea”, “ted”, “ten”, “i”, “in”, “inn”} ``。  

- **Trie 树的基本特点：**
```
1. 每个节点的分支数目取决于这个 key 值里每个元素的取值范围（上例中 为26个字母+1个结束标志位 ，ETH地址是 0~f共16+1个结束标志位）  
2. Trei的查找效率取决于 Key 的长度，key 值越长，访问内存的次数越多（ETH地址长度40位十六进制）  
3. 不会出现 Hash 碰撞  
4. 只要输入不变，输入顺序不会影响 Trie 构成同一棵树  
5. ETH 账户通常只对有交易的部分账户进行更新，Trie 的局部更新很好  
```
- **Trie 树的基本性质：**  
```
1. 根节点不包含字符，除根节点外的每一个子节点都包含一个字符。  
2. 从根节点到某一个节点，路径上经过的字符连接起来，为该节点对应的字符串。  
3. 每个节点的所有子节点包含的字符互不相同。  
```
通常在实现的时候，会在节点结构中设置一个标志，用来标记该结点处是否构成一个单词（关键字）。  

### 【2】Patricia Tree（压缩前缀树） --- Trie 升级版  
单词 abc、abf、adrf、siab 结构：
```
压缩前：                         压缩后：
        ( )                           ()
       /   \                         /  \
     a      s                      a    siab
    / \      \                    /  \
   b   d      i                  b    drf 
  / \   \      \                / \
 c   f   r      a              c   f
          \      \
           f      b
```
- **Patricia Tree 优点：**  
 树的高度降低，查询效率提高

- **缺点**
 添加新单词时，压缩的分支可能需要展开

### 【3】modify Merkle Patricia Tree(modify MPT)  ---- Trie 的二次升级   
![Modify MPT](https://github.com/BruceCoins/Pizza369/blob/main/0x0007%20read%20code/%E8%82%96%E8%87%BB%20%E3%80%8A%E5%8C%BA%E5%9D%97%E9%93%BE%E6%8A%80%E6%9C%AF%E4%B8%8E%E5%BA%94%E7%94%A8%E3%80%8B/images/modify%20MPT.png)   
**1. Block Header (区块头):**  

区块头是区块链中每个区块的元数据部分，包含该区块的关键信息。  

**2. stateRoot (状态根):**  

是一个 Keccak 256 位的哈希值。它是状态树的根节点的哈希值，记录了所有交易执行和最终化后的状态。

**3. Keccak 256-bit hash:**  

一种加密哈希函数（KECCAK256()），用于生成固定长度的哈希值（256 位）。
图中的 stateRoot 就是通过这个函数计算得出的。

**4. World State Trie (世界状态树):**  

是一种树状数据结构，用于存储区块链中所有账户的状态。  
它由多种节点类型组成，包括扩展节点（Extension Node）、分支节点（Branch Node）和叶子节点（Leaf Node）。  

**5. World State Trie 的节点类型:**  

- Extension Node (扩展节点):  
用于共享公共前缀的节点。例如，根节点是一个扩展节点，**前缀**为 0，说明共享的 nibble（半字节）为偶数，即 a7。  
- Branch Node (分支节点):  
包含 16 个子节点（0-f）和一个可选的值。用于进一步分支到其他节点。  
- Leaf Node (叶子节点):  
存储最终的键值对。例如，prefix、key-end、value 表示叶子节点的前缀、键的结束部分和对应的值。  

**6. Prefixes (前缀):**  
```
用于区分节点类型的标识符：  
0：扩展节点（偶数个 nibble，即长度为偶数个）。  
1▢：扩展节点（奇数个 nibble，即长度为奇数个）。  
2：叶子节点（偶数个 nibble，即长度为偶数个）。  
3▢：叶子节点（奇数个 nibble，即长度为奇数个）。  
```
**7. Nibble (半字节):**  

4 位的数据单位（1 nibble = 4 bits = 1 十六进制数）。    

### 【4】ETH 链数据结构分析  
![](https://github.com/BruceCoins/Pizza369/blob/main/0x0007%20read%20code/%E8%82%96%E8%87%BB%20%E3%80%8A%E5%8C%BA%E5%9D%97%E9%93%BE%E6%8A%80%E6%9C%AF%E4%B8%8E%E5%BA%94%E7%94%A8%E3%80%8B/images/eth_chain.png)  
这张图展示了 **以太坊（Ethereum）区块链中两个连续区块（Block N 和 Block N+1）的数据结构**，涵盖了区块头、默克尔树（Merkle Tree）和默克尔-帕特里夏状态树（Merkle-Patricia State Trie）等核心组件。以下是详细分析：  
- **Block Header（区块头）：**  
区块头是区块的元数据部分，包含以下字段（图中列出的关键字段）：
```
     Prev Hash： 前一个区块（头）的哈希值，用于维护链式结构。  
     Nonce： 工作量证明（PoW）中使用的随机数（以太坊已转向 PoS，但图中显示的是旧版 PoW 设计）。  
     Timestamp： 区块生成的时间戳。  
     Uncles Hash： 叔块（Uncle Blocks）列表的哈希值，用于奖励早期废弃区块的矿工。  
     Beneficiary： 矿工或验证者的地址，接收区块奖励和手续费。  
     Logs Bloom： 日志的布隆过滤器，用于高效检索智能合约事件。  
     Difficulty： 当前区块的挖矿难度（PoW 机制下）。  
     Extra Data ：可选字段，可存储任意数据。  
     Block Num： 区块高度（如 Block N、Block N+1）。  
     Gas Limit： 区块允许的最大 Gas 总量。  
     Gas Used： 区块中交易实际消耗的 Gas。  
     Mix Hash： PoW 的混合哈希，用于验证工作量。  
     State Root： 世界状态树（State Trie）的根哈希，反映所有账户的最新状态。  
     Transaction Root： 交易默克尔树的根哈希。  
     Receipt Root： 交易收据默克尔树的根哈希。  
```
- **State Trie 状态树**
```
     Nonce：账户发送的交易数量（或合约创建次数）。  
     Balance：账户的以太币余额。  
     CodeHash：合约代码的哈希值（外部账户为 keccak256("")）。  
     StorageRoot：合约存储数据的默克尔-帕特里夏树的根哈希（仅合约账户有）
```
## 四、交易树和收据树  
```
- 交易树 和 收据树 在节点关系上 一一对应。  
- 数据结构：都是 MPT （状态树查找的key值是账户地址、交易树和收据树查找的key值是其在发布的区块排名第几）。  
- 交易的排列顺序是由发布区块的解点决定的。
- 交易树 证明交易被打包到某个区块中的Mekle prool， 收据树提供执行结果的Merkle Prool
```
### 【1】交易树、收据树 与 状态树 区别  
```
1. 交易树、收据树：都只是把当前发布的区块里的交易组织起来，  
   状态树：是把系统中所有的账户状态都要包含进去，与当前交易无关。  

2. 交易树、收据树：每个区块独立生成，不共享节点。   
   状态树：与之前的状态树共享节点，只对有变更的节点重新生成分支  
```
### 【2】Bloom Filter 数据结构  
- **介绍：**  
Bloom Filter（布隆过滤器）是一种空间效率极高的概率型数据结构，用于快速判断一个元素是否 “可能存在” 于某个很大的集合中，或 “一定不存在” 于集合中。  

- **组成：**  
  一个固定大小的二进制数组（初始值全为 0 ）、多个独立的哈希函数（通常为 K 个）  

- **特性：**  
```
  1. 空间效率极高：只需存储二进制位，无需存储元素本身，适合存储大规模数据集。  
  2. 查询速度快：插入、查询操作均为 O(K) (K 为哈希函数数量，通常为常数)，时间效率接近 O(1)。  
  3. 存在“假阳性”：可能将 “不存在的元素” 误判为 “存在”(哈希碰撞导致)，但绝不会出现 “假阴性” 即 “存在的元素” 一定能被正确识别。  
  4. 不支持删除操作
```
- **参数设计与误判率：**
```
  1. 数组长度（m）：越长，误判率越低（但空间占用增加）。
  2. 哈希函数数量（K）：过少会导致碰撞增多，过多会使数组过早被填满，需根据 m 和 元素总数 n 平衡（最优 K 数量 ≈ (m/n) * ln2）。
  3. 元素总数（n）：n 越大，误判率越高。
```

- **公式估算误判率：**
P ≈ (1 - e^(-kn / m))^k   (当 k = (m/n) * ln2 时，P 可最小化)   

### 【3】ETH 中的 Bloom Filter  
- **应用：**   
```
每个交易执行后生成一个收据，收据中包含一个 Bloom Filter 来记录这个交易类型、地址等信息。

发布的区块在 block header 也有一个总的 Bloom Filter，是区块中所有交易的 Bloom Filter 的 并集
```
  
- **案例：**
```
查过去十天的跟某智能合约相关的所有交易：  
1. 先在 block header 中 Bloom Filter 又要查找的类型；    
2. 如果没有，那就不是要找的区块；  
3. 如果有，再去查找收据树中对应的Bloom Filter，找到相关交易进行确认。
```
## 五、GHOST 协议  

以太坊的 GHOST 协议，全称为 Greedy Heaviest Observed SubTree protocol，即贪婪最重观察子树协议，它是 Nakamoto 共识的一个延伸，主要用于解决以太坊中的**临时性分叉问题，提高系统吞吐量，降低反应时间**。以下是对 GHOST 协议的详细介绍：  

**叔块的概念：** 叔块是那些虽然合法，但没有成为主链一部分的区块。在以太坊中，由于出块时间较短，可能会出现多个节点同时挖出区块的情况，从而导致分叉，这些分叉区块中没有成为主链的部分就成为了叔块。
主链选择规则：不同于比特币的最长链规则，GHOST 协议选择主链时，会将分叉区块也考虑进去，选择包含了最多区块（包括叔块）的链作为最长链，即 “最重的链”。  

**叔块奖励机制：** 以太坊中，7 代内的叔块都能够获得奖励，奖励比例与叔块和主链上下一次出块的区块的代数有关，代数越近，奖励越高。具体奖励比例为 7/8、6/8、5/8、4/8、3/8、2/8、1/8，奖励 = 奖励比例出块奖励。例如，若出块奖励为 3ETH，某叔块与主链上下一次出块的区块代数相差为 1，则该叔块的矿工可获得 3ETH7/8 的奖励。  

**引用叔块的奖励：** 当前区块每包含 1 个叔块，会额外获得 1/32 的出块奖励，每次出块最多可包含 2 个叔块。比如，出块奖励为 3ETH，若一个区块包含了 2 个叔块，则该区块的矿工除了获得基础出块奖励外，还能额外获得 3ETH1/322 的奖励。  

**协议的作用：** GHOST 协议让以太坊在 PoW 阶段比比特币更具公平性与抗分叉性，它保证了网络的去中心化，让延迟较高的矿工也有奖励，同时减少了算力浪费，鼓励矿工集中算力、追求同步优势，使得区块链在出现分叉后能够快速合并。  

## 六、挖矿算法（POW）  
difficult to solve, but easy to verify  
memory hard minng puzzle  

### 【1】POW 挖矿逻辑     
**1. 交易收集与区块构建**   
```
1> 网络中的节点将待处理的交易广播到全网，并存储在交易池中。矿工从交易池中选择交易，优先打包手续费较高的交易。  
2> 矿工将选中的交易打包成一个“候选区块”，同时计算区块中所有交易的 Merkle root 哈希值【”三棵树“】，添加到区块头。
```  
**2. 计算哈希**    
```
1> 矿工需要找到一个合适的随机数（Nonce），将其与区块头的其他信息一起输入到 Ethash 算法中进行哈希计算，得到一个混合哈希（mixHash）。
   这个哈希值必须小于当前区块难度所规定的目标值（即哈希值的前导零足够多），才算有效。
  
2> 区块头的哈希计算：**H = SHA3-256(Block Header + Nonce)**，要求 H < Target(目标值)   

3> 矿工不断改变 nonce 值，反复计算哈希，通常从0开始，每次加1，一次尝试，直到找到符合要求的nonce值
```  
**3. 验证与广播**  
```
1> 当矿工找到一个有效的 nonce 随机数后，就相当于完成了 “工作量证明”,立即将区块广播到全网。  
2> 其他节点收到区块后，会验证：  
  ● Nonce 是否确实使哈希值满足难度目标。  
  ● 区块中的交易是否有效（如签名合法、无双花）。  
3> 如果验证通过，节点会将该区块添加到自己的区块链中，【更新本地”三棵树“】。  
```     
**4. 获得奖励**
```
1> 成功挖出区块的矿工获得固定奖励（以太坊 PoW 阶段为 2 ETH）。  
2> 区块中所有交易的手续费归矿工所有。   
3> 如果挖出的区块是叔块，也会获得 1.75 个以太币的补偿。
4> 奖励通过区块中的第一笔交易（Coinbase 交易）发放到矿工的钱包地址。  
```     
### 【2】算法逻辑  
> ETH 使用两个数据集：16M cahe + 1 G dataset (cache 生成 dataset)  
> 轻节点使用 16M cache，挖矿使用 1G dataset   

- 获取cache：
  每30000区块 seed 更新一次，并重新生cache  
  每30000区块 cache 增长初始大小的 1/128 即 128K  
```
定义一个数组，对种子节点（seed）运算
---> 通过 hash 运算获得 第一个元素 a
---> 对 a 进行哈希获得 第二个元素 b
---> 对 b 进行哈希获得 第三个元素 c
---> ...
```
- 获取dataset：
```
定义一个更大的数组
1> dataset 中每个元素都是通过伪随机顺序读取 cache 中数据
     -> 比如：第一次读取元素a，之后进行运算获取下一个元素b的位置...直到cache读取结束，【算一次运算】
     -> 如此反复读取运算求哈希 cache 256次
     -> 将最后算出的数据放到 dataset 第一位置，之后反复如此操作，填充 dataset
```
⚠️ ``cache`` 和 ``dataset`` 都是定期增长  
- 求解 puzzle(即挖矿)：
  每30000区块 cache 增长初始大小的 1/128 即 8M   
```
1> 使用 dataset 中数据
2> 按照伪随机顺序读取 dataset 中的 128 位数据
      -> 矿工挖矿时，收到block header、nonce、fullsize(大数据集元素个数)、dataset 等算出初始 hash 值，
      -> 通过运算获取 dataset 上元素 A 及其相邻位置元素 ，
      -> 对A进行运算获取下一个元素 B 及其相邻位置元素，
      -> 如此反复读取，进行 64 次循环，共读取 128 位
      -> 算出 Hash 值与目标难度的 阈值 进行比较是否符合难度要求，不符合就替换 nonce 重新运算
```

## 七、以太坊难度调整算法  
### 【1】区块难度公式  
<img src = "https://github.com/BruceCoins/Pizza369/blob/main/0x0007%20read%20code/%E8%82%96%E8%87%BB%20%E3%80%8A%E5%8C%BA%E5%9D%97%E9%93%BE%E6%8A%80%E6%9C%AF%E4%B8%8E%E5%BA%94%E7%94%A8%E3%80%8B/images/eth_puzzle.png" width = "50%">  

- 核心作用与设计目标  
**1. 维持出块速度：**  
通过 x×ς2 动态抵消全网算力变化的影响（算力↑→难度↑，算力↓→难度↓ ），确保平均出块时间稳定（以太坊 PoW 阶段目标约 12-15 秒）。  
**2. 设置难度下限：**  
max(D0 ,...)保证即使算力极端低迷，难度也不会低于 131072，避免出块过快导致链分裂或安全隐患。  
**3. 推动共识升级：**  
难度炸弹 ϵ 是 “硬分叉倒计时器”，随区块高度增加，PoW 挖矿成本指数级上升，最终让 PoW 不可行，促使社区完成向 PoS 的 Merge 升级（以太坊 2022 年 Merge 后，难度炸弹机制已失效）。

### 【2】自适应难度调整  
<img src = "https://github.com/BruceCoins/Pizza369/blob/main/0x0007%20read%20code/%E8%82%96%E8%87%BB%20%E3%80%8A%E5%8C%BA%E5%9D%97%E9%93%BE%E6%8A%80%E6%9C%AF%E4%B8%8E%E5%BA%94%E7%94%A8%E3%80%8B/images/eth_puzzle2.png" width = "50%">

> **参数详解**  
- **调整单位 $x \equiv \lfloor\frac{P(H)_{H_d}}{2048}\rfloor$**  
     -   **$P(H)_{H_d}$** ：父区块的难度值（父区块头 Difficulty 字段，反映挖矿难度的数值）。  
     -   **$\lfloor \cdot \rfloor$** ：向下取整操作，确保 x 为整数。  
     -   **作用：** 将父区块难度按照 2048 为粒度拆分，控制难度调整的基础步长（父区块难度越大，x越大，调整幅度的基础单位越高）。

- **调整系数 $\varsigma_2 \equiv \max \left( y - \lfloor\frac{H_s - P(H)_{H_s}}{9} \rfloor, -99 \right)$**
     - **y:** 与父区块是否包含叔父块（uncle）相关：  
          -    包含叔父块： y = 2 （因叔父块增发 ETH，需要提高难度抵消通胀）；
          -  不包含叔父块： y = 1 （正常难度调整逻辑）；
     - **$H_s$** ：当前区块的时间戳（区块头 timestamp，记录区块的创建时间）；
     - **$P(H)_{H_s}$** ：父区块的时间戳（夫区块头 timestamp）；
     - $\lfloor \frac{H_s - P(H)_{H_n}}{9} \rfloor$ ：计算**当前区块与父区块的时间差**，并按 9 为单位差分，反映出块速度偏差；
     - **max(⋅, -99)**：限制下调的对大幅度，繁殖极端情况导致难度暴跌；
  
<img src = "https://github.com/BruceCoins/Pizza369/blob/main/0x0007%20read%20code/%E8%82%96%E8%87%BB%20%E3%80%8A%E5%8C%BA%E5%9D%97%E9%93%BE%E6%8A%80%E6%9C%AF%E4%B8%8E%E5%BA%94%E7%94%A8%E3%80%8B/images/eth_puzzle3.png" width = "50%">

### 【3】 难度炸弹  
<img src = "https://github.com/BruceCoins/Pizza369/blob/main/0x0007%20read%20code/%E8%82%96%E8%87%BB%20%E3%80%8A%E5%8C%BA%E5%9D%97%E9%93%BE%E6%8A%80%E6%9C%AF%E4%B8%8E%E5%BA%94%E7%94%A8%E3%80%8B/images/eth_puzzle4.png" width = "50%">  

> **计算逻辑**
难度炸弹的数学定义分两步，核心是**区块高度驱动的指数增长**  
- **伪区块高度 $H'_i$ 的计算**   
  $H'_i \equiv \max \left(H_i - 3000000, 0 \right)$  
  - **$H_i$**：当前区块真实高度（区块链中地政的区块编号，创世块为 0 ）；  
  - **max(.,0)**：保证 $H'_i$ 非负（区块高度不足 300 万时，难度炸弹不激活）；  
    
- **难度炸弹 $\epsilon$ 的计算**  
  $\epsilon \equiv \lfloor 2^ {\lfloor H'_i - 100000 \rfloor - 2} \rfloor$
  - **$\lfloor H'_i - 100000 \rfloor$**：将伪区块高度 **按每10 万区块**为周期拆分，控制指数增长的频率；  
  - **$2^.$**：指数增长，每 10 万区块难度炸弹值翻倍；  
  - **$\lfloor⋅\rfloor$**：向下取整，确保 $\epsilon$ 是整数难度值；  

## 八、智能合约    
### 【1】solidity  
☑️☑️ **遵循 ”检查-生效-交互“模式** ：先检查输入合法性，在更新合约状态，最后执行转账，防止重入攻击

☑️ **不支持多线程** 以太坊是交易驱动的状态机，这个状态机**必须是完全确定性的**，即给定一组输入，产生的输出或者说转移到下一个状态必须是完全确定的。如此所有全节点执行同一组操作时才能到达同一个状态，验证通过。   

**多线程问题**在于多个核访问内存顺序不同，执行结果有可能是不确定的。 

☑️ **不产生真正意义上的随机数**

### 【2】智能合约的创建与运行  
```
1> 智能合约的代码写完后，要编译成 bytecode 
2> 创建合约：外部账户发起一个转账交易到 0x0 的地址  
     - 转账金额是 0， 但是要支付汽油费  
     - 合约的代码放在 data 域里  
3> 智能合约运行在 EVM (Ethereum Virtual Machine) 上  
4> 以太坊是一个交易驱动的状态机  
     - 调用只能合约的交易发布到 区块链上后，每个矿工都会执行这个交易，从当前状态确定性的转移到下一个状态
``` 
### 【3】汽油费（gas fee）  
```
1> 智能合约是 图灵完备的程序模型
2> 执行合约中的指令要收取汽油费，有发起交易的人来支付
3> EVM 中不同指令消耗的汽油费不一样  
     - 简单指令很便宜，复杂指令或需要存储状态的指令就很贵。
```
### 【4】错误处理  
```
1> 智能合约中不存在自定义的try-catch结构
2> 一旦遇到异常，除特殊情况外，本次执行操作全部回滚
3> 可以抛出错误的语句：
      - assert(boolcondition):如果条件不满足就抛出一用于内部错误。
      - require(bool condition):如果条件不满足就抛掉一用于输入或者外部组件引起的错误。
      - revert0:无条件抛出异常，终止运行并回滚状态变动。
```
### 【5】嵌套调用  
```
1> 智能合约的执行具有原子性:执行过程中出现错误会导致回滚
2> 嵌套调用是指一个合约调用另一个合约中的函数
3> 嵌套调用是否会触发连锁式的回滚?
     - 如果被调用的合约执行过程中发生异常,会不会导致发起调用的这个合约也跟着一起回滚?
     - 有些调用方法会引起连锁式的回滚,有些则不会
4> 一个合约直接向一个合约帐户里转账,没有指明调用哪个函数,仍以会引起嵌套调用
```
> 问题(1)：  
> 假设某个全节点要打包交易到区块中，交易中有一些事对只能合约的调用，
> 全节点是先执行智能合约再去挖矿？还是先挖矿获得记账权后再去执行智能合约？

**先合约后挖矿：** 先执行智能合约更新【”三棵树“（状态树、交易树、收据树）】，后根据”三棵树“的根哈希值等 block head 信息挖矿竞争记账权  

### 【6】智能合约获取区块信息  
```solidity
block.blockhash(uint blockNumber) returns (bytes32):获取给定区块的哈希---仅对最近256个区块有效
block.coinbase(address):挖出当前区块的矿工地址
block.difficuly(uint)：当前区块难度
block.gaslimit(uint)：当前区块的gas限额
block.number(uint)：当前区块号
block.timestamp(uint)：自 uinx epoch 起始当前区块以秒计的时间戳
```
### 【7】智能合约可以获得的调用信息
```solidity
msg.data(bytes)：完整的 calldata
msg.gas(uint)：剩余 gas
msg.sender(address)：消息发送者（当前调用）
msg.sig(uint)：calldata的前4字节（也就是函数标识符）
msg.value(uint)：随消息发送的 wei 的数量
now(uint)：目前区块时间戳（block.timestamp）
tx.gasprice(uint)：交易的 gas 价格
tx.origin(address)：交易发起者（完全的调用链）
```
### 【8】地址类型  
```diff 
- <address>.balance(uint256)
以 Wei 为单位的 地址类型 的余额

- <address>.transfer(uint256 amount) 【失败，连锁型回滚】
向 地址类型 发送数量为 amount 的 Wei，失败时抛出异常，发送 2300 gas 的矿工费，不可调节

- <address>.send(uint256 amount) returns (bool)  【失败，返回false】
向 地址类型 发送数据为 amount 的 Wei，失败时返回 false，发送 2300 gas的矿工费用， 不可调节

- <address>.call(...) returns(bool)
发出底层 CALL ，失败时返回 false ，发送所有可用的 gas，不可调节

- <address>.calldata(...) returns(bool)
发出底层 CALLCODE，失败时返回 false， 发送所有可用 gas，不可调节

- <address>.delegatecall(...) returns (bool)
发出底层 DELEGATECALL ，失败返回 false， 发送所有 gas，不可调节
```

### 【9】发送 ETH 的方式（solidity 0.7.0 以上版本）  
```diff
- <address>.transfer(uint256 amount)   【失败时，连锁型回滚】
向 address 地址发送 amount 数量的 Wei，失败抛出异常，发送 2300 gas 的矿工费，不可调节

- <address>.send(uint256 amount) returns(bool)  【失败时，返回false】
向 address 地址发送 amount 数量的 Wei，失败时返回 false，发送 2300 gas 的矿工费，不可调节

- (bool success, ) = <address>.call{value:uint256 amount, gas:}();
- require(success, "Transfer failed");  【必需检查返回值，否则失败不会回滚】
向 address 地址发送 amount 数量的 Wei，返回成功标志，省略第二个返回值 

- (bool success, bytes memory returnData) = <address>.call{uint256 amount}(
-      abi.encodeWithSignature("函数名(参数类型)", 参数值)
- );
向 合约address 发送 ETH 的同时，调用其合约中的函数（适用于需要支付 ETH 才能触发的功能，如购买 NFT、支付手续费等）
```
> 推荐原则  
**优先使用 ``call{value:...}("")``**：必须搭配 ``require(success, "...")``确保失败回滚    
**其次考虑 ``transfer()``**：适合向外部账户（EOA）转账  
**避免使用 ``send()``**：solidity 0.7.0 后已不推荐使用

## 九、The DAO(Deccentralized Autonomous  Organization)  
### 【1】 重入攻击  
> **漏洞源码：**
```diff
function spiltDao(
     uint _proposalID,
     address _newCurator
) noEther onlyTokenholders returns (bool _success) {
     ......
     // Burn DAO Tokens
     Transfer(msg.sender, 0, balances[msg.sender]);
-    withdrawRewardFor(msg.sender);        //把钱还给调用者  
-    totalSupply -= balances[msg.sender];  //减少Dao中总金额 
-    balances[msg.sender] = 0;          //将调用者 账户清零   
     paidOut[msg.sender] = 0;
     return true;          
}
``` 
代码来源：https://etherscan.io/address/0x304a554a310C7e546dfe434669C62820b7D83490#code   
> **攻击过程：**  

- 1、**攻击者部署恶意合约**v  
攻击者创建一个恶意合约，该合约包含fallback或receive函数（当收到 ETH 时会自动触发），且在该函数中再次调用spiltDao函数（或其他可提款的函数）

- 2、**攻击者触发spiltDao函数**  
攻击者通过恶意合约调用 ``spiltDao`` 函数，传入合法参数（如 ``_proposalID`` 和 ``_newCurator``）。

- 3、**第一次执行：资金转移先于状态更新**
合约执行到 ``withdrawRewardFor(msg.sender)`` 时，开始向恶意合约转账 ETH（或其他代币）。  
     - 转账触发恶意合约的fallback函数（因为接收方是合约地址）。
     - 
- 4、**恶意回调：利用未更新的状态重复提款**  
恶意合约的 ``fallback`` 函数中，再次调用 ``spiltDao`` 函数（或其他提款函数）。  
     - 此时，第一次调用尚未执行 ``totalSupply -= balances[msg.sender]`` 和 ``balances[msg.sender] = 0``，因此 ``balances[msg.sender] ``（恶意合约的余额）仍然是原始值，``totalSupply`` 也未减少。  
     - 第二次调用会再次执行 ``withdrawRewardFor(msg.sender)``，向恶意合约重复转账。

- 5、**循环提款直到资金耗尽**  
恶意合约通过多次回调，在状态变量被更新前反复触发提款逻辑，不断从合约中提取资金。

- 6、**状态更新最终执行，但已无意义**  
当所有回调结束后，第一次调用才会继续执行 ``totalSupply`` 减少和 ``balances`` 清零的操作，但此时合约资金已被掏空，状态更新无法挽回损失。
```diff
function spiltDao(
     uint _proposalID,
     address _newCurator
) noEther onlyTokenholders returns (bool _success) {
     ......
-    // 首先更新状态变量（Effects）
     uint256 senderBalance = balances[msg.sender]; // 先保存余额
     totalSupply -= senderBalance;  //减少Dao中总金额 
     balances[msg.sender] = 0;      //将调用者账户清零   
     paidOut[msg.sender] = 0;
     
-    // 最后进行外部调用（Interactions）
     // Burn DAO Tokens
     Transfer(msg.sender, 0, senderBalance);
     withdrawRewardFor(msg.sender);  //把钱还给调用者  
     
     return true;          
}
```


### 【2】以太坊补救
- **(软分叉)：** eth升级，与 TheDao 基金相关账户不能做任何交易 **--->** 相关交易不收gas费，导致攻击，矿工只能回滚之前版本，补救失败
- **(硬分叉)：** eth升级，挖到192万区块时，强制将 TheDao 上相关的账户资金转到一个新的智能合约上 **--->** 补救成功，产生新链 ETC ，由于与 ETH 公用之前数据，可能导致重入攻击，后添加 ChainID 开区分使之成为两条链

> 攻击根本原因

代码逻辑中**资金转移（withdrawRewardFor）发生在状态变量更新（totalSupply、balances）之前**，导致攻击者可以利用未更新的状态重复触发提款流程。  

> 修复方案

遵循 “Checks-Effects-Interactions” 模式 —— 先更新状态变量（清零余额、减少总供给），再执行外部资金转移（withdrawRewardFor），确保状态更新后无法被重复利用。
