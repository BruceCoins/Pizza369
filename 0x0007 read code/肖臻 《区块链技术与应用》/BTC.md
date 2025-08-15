## 一、BTC 密码学原理  

- 【1】要求：     
  - Hash 不可篡改，数据一旦篡改，其Hash值也会改变  
  - Hash 函数计算过程是单向的  
  - puzzle friendly（难求正，已验证）  
 
- 【2】 实现：SHA-256(block header) <= target 

## 二、BTC 数据结构
### 【1】Hash 指针：  
   存放 指针地址 + 结构体的 Hash 值 	

**区块链中 Hash 指针：**    
- 后一个区块，保存前一个区块（包含上上个区块的Hash值）的 Hash 值，嵌套 hash 结构。

- 只要记录后边的Hash值，就能监测前面是否进行了篡改。   
	
### 【2】Markle Tree  
  - 比特币中各个区块用Hash指针连接，每个区块中包含的交易，被组织成Markle Tree结构。  

  - 对每个交易进行Hash，然后对每两个Hash进行进一步Hash，最终得到一个根Hash。  
  
  - 每个区块分为两部分，block header和block body。 
  ```
  （1）block header：存放前一个区块头 的Hash值， 本区块的根Hash值，时间戳，难度值，Nonce值等。没有交易具体内容。 

  （2）block body：存放交易列表，多个交易被组织成Markle Tree结构。
  ```

### 【3】Markle proof   
- 轻节点只存放block header(区块头)，验证交易是否在区块中：  
```
  <1> 轻节点收到交易后，向全节点发送查询请求，要求提供该交易的Merkle路径。  
  
  <2> 根据交易Hash，与路径中提供的节点进行比较，判断交易是否在区块中。  
  
  <3> 即使交易在区块中，还要验证是否属于“最长有效链”。
```
  ![Markle proof](https://github.com/BruceCoins/Pizza369/blob/main/0x0007%20read%20code/%E8%82%96%E8%87%BB%20%E3%80%8A%E5%8C%BA%E5%9D%97%E9%93%BE%E6%8A%80%E6%9C%AF%E4%B8%8E%E5%BA%94%E7%94%A8%E3%80%8B/images/Markle%20Tree.png)  

- 轻节点验证交易不在区块中：sortedMerkleTree(排序的Merkle树)   
```
<1> 对所有交易Hash，进行排序，并生成排序后的Merkle树。

<2> 轻节点收到交易后，根据交易Hash，在排序后的Merkle树中查找该交易Hash的索引。

<3> 如果不存在，找相邻的索引，并生成Merkle proof。计算根节点
```  
:warning: 比特币中没有 sortedMerkleTree   

## 三、BTC 协议   
### 【1】双花攻击  
- 指攻击者试图将同一笔比特币重复花费的行为（竞争攻击、芬尼攻击、51%攻击）  
- 解决机制：  
  - 工作量证明与最长链结合  
  - 交易确认机制  
  - 去中心化的节点验证  
 
每个交易包括输入输出两部分，比如 铸币 -> A， A -> B 转账 
```
输入：(1)要说明币的来源， (2)要说明 A 的公钥 （3）A的私钥签名

输出：(1)收款人 B 的公钥Hash
``` 
交易验证时，需要通过 ``A的公钥`` 与铸币时产生的 ``A的公钥Hash`` 进行验证。确保A的币来源正确。  

### 【2】BTC共识机制   
CAP 模型：一致性、可用性、分区容忍性（最多同时满足两个）  

POW 工作量证明、（出块奖励 + 交易费）  

## 四、BTC 实现  
### 基于交易模式（transaction-based ledger）--- BTC 
UTXO（unspent transaction output）还没有被花出去的交易的输出，简单理解为 账户余额  
- 每个元素给出 产生输出的交易Hash值、以及在交易中的索引位置，就可以定位到这个交易输出
```   
A 转给 B 100 BTC，转给 C 50 BTC；B 又转给 D 50 BTC
UTXO 只记录 B 剩余的 50 BTC 、C 的50 BTC、D 的50 BTC。

	A ----> B (100 BTC) ---> D (50 BTC)  
	   |  
	   |--> C (50 BTC)  
```  
工作 流程示例：
```
(1) 生成 UTXO：A 向 B 转账 0.5 BTC，交易创建两个输出：
	-> 输出 1：0.5 BTC 给 B（锁定到 B 的公钥）
	-> 输出 2：剩余资金（找零）返回给 A（锁定到 A 的公钥）。
	  这两个输出均为 UTXO，分别属于 B 和 A。
(2) 花费 UTXO：B 要向 C 转账 0.3 BTC 时，需引用上述 0.5 BTC 的 UTXO 作为输入，通过私钥签名解锁，然后生成新输出：
	-> 输出 1：0.3 BTC 给 C
	-> 输出 2：0.2 BTC 找零给 B。
	原 0.5 BTC 的 UTXO 被标记为 “已花费”，新生成的两个输出成为新的 UTXO。
```

### 基于账户模式 (account-based ledger) --- 以太坊  

## 五、BTC 网络原理 