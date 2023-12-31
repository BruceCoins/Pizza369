# 区块链密码学（整理）

### 目录
<!-- TOC -->
* [对称密码算法](#对称密码算法)
  * [1. 流密码](#1-流密码) 
  * [1. 流密码](#1-流密码)  
  * [2. 分组密码](#2-分组密码)  
  * [3. 对称密码算法小结](#3-对称密码算法小结)
  * [4. 对称密码算法在区块链中的应用](#4-对称密码算法在区块链中的应用)
* [非对称密码算法](#非对称密码算法)
  * [1. RSA](#1-rsa)
  * [2. ECC](#2-ecc)
  * [3. 非对称密码算法小结](#3-非对称密码算法小结)
  * [4. 非对称密码算法在区块链中的应用](#4-非对称密码算法在区块链中的应用)
* [Hash函数](#hash函数)
  * [1. SHA](#1-sha)
  * [2. RipeMD-160](#2-ripemd-160)
  * [3. Hash函数在区块链中的应用](#3-Hash函数在区块链中的应用)
* [PKI](#pki)
  * [1. PKI组成](#1-PKI组成)
  * [2. PKI与区块链](#2-PKI与区块链)
* [Merkle树](#Merkle树)
  * [1. 基于hash列表的完整性校验](#1-基于hash列表的完整性校验)
  * [2. 基于Merkle树的完整性校验](#2-基于Merkle树的完整性校验)
* [数字签名技术](#数字签名技术)
  * [1. 原理](#1-原理)
  * [2. 可选方案](#2-可选方案)
* [零知识证明（Zero—Knowledge Proof，ZKP）](#零知识证明zeroknowledge-proofzkp)
  * [1. 交互式零知识证明（Interactive Zero-Knowledge, IZK）](#1-交互式零知识证明interactive-zero-knowledge-izk)
  * [2. 非交互式零知识证明（Non-Interactive Zero-Knowledge, NIZK）](#2-非交互式零知识证明non-interactive-zero-knowledge-nizk)
  * [3. 发展历史](#3-发展历史)
  * [4. 区块链如何应用零知识证明](#4-区块链如何应用零知识证明)
* [Base58编码方案](#Base58编码方案)
<!-- TOC -->


## 对称密码算法
特点是加解密密钥一致，根据加密方式分为两类：流密码和分组密码（区块链使用）。比较知名的对称密码算法有DES、3DES、IDEA、RC2、RC4、RC5、Blowfish以及AES等。

### 1. 流密码
- 用于WEP加密的RC4
- 3G中的SNOW 3G
- GSM系统的A5
- 4G通信加密的祖冲之序列密码

### 2. 分组密码
是将长明文序列分层固定长度的段后，每段分别加密。它是一类重要的密码算法，除了用来加密以外，也可用于构造随机生成器、流密码、消息认证码（MAC）和Hash函数等。
DES、IDEA、AES等分组密码算法因其安全和简洁获得了广泛使用。

#### 2.1 DES
1992年美国IBM公司研制的对称密码体制加密算法，是现代密码学体系的基础思想。1976年被美国联邦政府的国家标准局确定为联邦资料处理标准（FIPS），随后在国际上广泛流传开来 。

其入口参数有三个：key、data、mode。key为加密解密使用的密钥，
data为加密解密的数据，mode为其工作模式。当模式为加密模式时，明文按照64位进行分组，形成明文组，key用于对数据加密，当模式为解密模式时，
key用于对数据解密。实际运用中，密钥只用到了64位中的56位。

>**DES现在已经不是一种安全的加密方法**，主要因为它使用的56位密钥过短。1999年1月，distributed.net与电子前哨基金会合作，
> 在22小时15分钟内即公开破解了一个DES密钥。也有一些分析报告提出了该算法的理论上的弱点，虽然在实际中难以应用。为了提供实用所需的安全性，
> 可以使用DES的派生算法3DES来进行加密，虽然3DES也存在理论上的攻击方法。DES标准和3DES标准已逐渐被高级加密标准（AES）所取代。
> 另外，DES已经不再作为国家标准科技协会（前国家标准局）的一个标准。

DES自1977年公布后服务了20多年，直到2000年高级加密标准（AES）公布，替代DES成为新的加密标准。

#### 2.2 AES
AES是一套加密标准，通常指的是Rijndael加密算法，由美国国家标准与技术研究员（NIST）于2001年11月26日发布并确定为FIPS PUB 197（一项标准）。

AES将分组长度固定为128比特，密钥长度可以是128/192/256比特，根据密钥长度，将AES也分为AES-128，AES-192和AES-256，相应的加密轮数N，分别指定为10、
12和14轮。

#### 2.3 分组密码工作模式
这不是加密算法，而是一种工作模式，用于和DES，AES搭配使用。可以隐蔽明文的统计特性、数据格式等，以提高整体安全性，降低删除、重放、插入和伪造等攻击成功机会。
大概有4种工作模式：ECB/CBC/CFB/OFB。

- ECB（electronic codebook）：是最简单的模式，它将每个128bit明文分组分别加密，每个分组使用相同秘钥。特点是模式简单，有利用并行计算，没有误差传播；缺点是相同明文分组的密文也相同，
不利于隐藏含有某些固定内容的明文。
- CBC（cipher block chaining）：将明文分组与前一密文分组异或后作为加密算法的输入。优点是安全性高，缺点是有错误传播、不利于并行计算；在SSL、IPSec中有应用。
- CFB（cipher feedback）：将分组密码转化为流密码模式，算法每次输入除了秘钥以外，还包括前一密文分组的部分比特。特点是可以及时加密传输小分组的数据，只要更换IV
便可以很好隐藏明文内容；缺点是比特错误传播。
- OFB（output feedback）：类似CFB，不同之处是本次加密的输入是前一次加密的输出。优点是无错误传播，克服了CBC和CFB的错误传播问题。缺点是需要频繁更换密钥或初始向量。

### 3. 对称密码算法小结
对称加密算法的特点是算法公开、计算量小、加密速度快、加密效率高。不足之处是，交易双方都使用同样钥匙，安全性得不到保证，同时还必须在一个绝对安全的通信通道中传输密钥。
此外，对称加密算法的安全性取决于密钥的保存情况，如果密钥被多人掌握，那么密钥泄露的概率会大大提高。

### 4. 对称密码算法在区块链中的应用
由于对称密码的特性，导致其在区块链中的应用场景较少。目前主要是在数字钱包的私钥管理中使用，数字钱包根据去中心化程度分为全节点钱包、轻节点钱包和中心化钱包。
三种钱包都提供密钥存储功能，即将用户的私钥、公钥和账户地址存放在一个加密文件中，供用户存储和使用，而这个加密文件就是使用的对称加密方式（用户设置了一个对称加密密码）。
这样即使加密文件泄露了，用户私钥在一段时间内还是安全的，用户应当在加密文件泄露后尽快转移资产到新的私钥对应的账户地址中，并妥善保存新的加密文件。

其次，对称密码算法一般还应用在区块链网络层通信场景中，即TLS协议。

>比特币官方使用AES加密用户的私钥文件。

## 非对称密码算法
又称公钥加密算法，弥补了对称密码算法在认证、签名用途上的不足。特点是采用两个一公一私两个密钥，二者具有互补性，即其中任一密钥用于加密，另一密钥都能解密。  
优点是安全性更高，不足是在效率上稍慢于对称密码算法，常用于数字签名场景。  

公钥加密，私钥解密 ---- 解决密钥分发问题  
私钥加密，公钥解密 ---- 解决身份认证问题【发送方将原文、私钥加密后的密文同时发送，接收方用公钥对密文解密，解密后内容与原文一致，则证明发送方身份】

常见的公钥密码算法有：RSA、Diffie-Hellman、ElGamal以及ECC（椭圆曲线密码）算法。其中RSA对应的数学难题是大质因数分解难题、Diffie-Hellman和ElGamal对应离散对数难题、
ECC对应椭圆曲线上的离散对数难题，下面仅介绍常用的RSA和ECC算法。

### 1. RSA
是目前应用最广泛的非对称密码算法，由MIT于1987年提出，可直接用于加密和数字签名。RSA广泛应用于SSL/TLS传输层协议中。

### 2. ECC
椭圆曲线密码算法（Elliptic Curve Cryptography，ECC），在1985年提出。在许多应用中，ECC取代了RSA，因为相同安全性下，前者的系统参数更短。
区块链中使用的就是ECC，例如ECC公钥用于生成比特币地址、区块链的验证使用了ECDSA（DSA基于椭圆曲线的版本）作为数字签名算法。

### 3. 非对称密码算法小结
非对称密码算法的特点是算法强度高、安全性依赖于算法与密钥，但是由于其算法复杂，而使得加密解密速度没有对称加密解密的速度快。另外，
非对称密码算法不需要一个安全信道来传输密钥，它的公钥可以直接公开，用户只需要私密保存私钥即可。

### 4. 非对称密码算法在区块链中的应用
非对称密码算法在区块链中有着广泛的应用，主要场景包含私钥生成、账户地址生成、交易签名以及网络层的密钥协商等。

## Hash函数
也叫哈希函数、散列函数、单向加密或杂凑加密算法。它将任一长度的序列作为输入，转换成固定长度的输出，可以是128/160/256比特。多用于消息认证、数据完整性验证和密钥生成等场景。
常见Hash函数有MD4/MD5、RipeMD-160、SHA系列函数以及SM3国密算法。
>MD5和SHA1都被攻破，不能用于要求安全性较高的场景，区块链使用了SHA-256算法；

### 1. SHA
SHA包含SHA-[0~3]共四个系列，见下图（来自维基百科）  
![](https://github.com/BruceCoins/Pizza369/blob/main/docs/image/hash_func_cmp.png)

SHA系列应用在很多安全协议中，如TLS、SSL、PGP、SSH、S/MIME和IPSec等。

#### 1.1 Keccak介绍
TODO

### 2. RipeMD-160
是1996年设计出来的一系列Hash算法，是基于MD4的设计原理而设计的增强版本。RipeMD-160是RipeMD-128的增强版本，用来替代MD4/MD5/RipeMD-128。
另外还有RipeMD-256/320这两个是更强的版本，但效率也更低，根据具体场景选用。

### 3. Hash函数在区块链中的应用
Hash函数在区块链中有着广泛的应用，主要场景包含账户地址生成、Merkle树、交易ID生成等。

## PKI
Public Key Infrastructure(公钥基础设施)是一个包括硬件、软件、人员、策略和规程的集合，用来实现基于公钥加密体制的密钥和数字证书的产生、管理、存储、分发和撤销等功能。
使在网络世界中的用户可以通过数字证书进行身份认证，从而实现安全通信。

### 1. PKI组成
一个典型的PKI包括PKI策略、软硬件系统、CA（Certificate Authority，证书机构）、RA（Registration Authority，注册机构）、证书发布系统和PKI应用等。

#### 1.1 PKI策略
PKI策略建立了一个组织信息安全的指导方针，同时定义了密码系统的使用方法和原则。一般包含两种类型的策略：
- 证书策略。管理证书使用
- CPS（Certificate Practice Statement，证书操作声明）。包含CA运作方式、证书签发、吊销流程以及用户密钥生成、存储和传递方式。外界可通过CPS分析PKI可信度。

#### 1.2 CA
CA是PKI的信任基础，它可以发放证书、设置证书有效期、掌管证书吊销列表（CRL）实现证书的吊销、管理用户密钥等。

CA掌管公钥的整个生命周期，用于签发、吊销、更新数字证书等。
- **数字证书**是一个用来证明公钥拥有者身份的电子文件，其中包含公钥信息、拥有者的身份信息，以及CA对这份证书的签名等信息。
比如，我们可以通过浏览器很方便的查询某个启用HTTPS的网站的证书信息（具体步骤可自行查询）。为了方便数字证书的验证，ITU-T（国际电信联盟电信标准化部门）规定了一个统一证书格式X.509，
X.509标准目前有V1,V2,V3三个标准。
- **CRL**用于验证证书的有效性。证书吊销后，CA通过更新CRL来通知各相关方那些证书失效了。X.509标准规定了CRL的格式，限于篇幅不列出。
- **双证书服务**。上面描述的数字证书指的是签名证书，许多CA提供双证书服务，即在提供签名证书同时，为用户生成一张加密证书。
该证书中存储了一个对称加密密钥，这个密钥通常由签名证书中的公钥派生而来。加密证书产生后使用签名证书中的公钥进行加密，与签名证书一起发给用户，
用户可以使用私钥对加密证书进行解密，以获得加密密钥。如果使用的是**单证书**服务，那么网站就使用签名证书来进行（私钥）签名和（公钥）加密（数据传输）操作；
但如果使用双证书服务，签名证书就只负责签名（以便用户验证网站身份），不再使用签名证书中的公钥负责加密数据传输，而使用加密证书中的密钥就负责加密功能。另外，CA一般会留存加密证书中的密钥，以便政府监管和网站遗失加密证书时申请恢复。
- **KMC**是密钥管理中心，在CA中负责密钥生成、管理、更新、恢复和查询的功能。KMC通常只是CA服务器上运行的一个组件，不是一个单独机构。

>另外，这部分内容还包含证书申请与吊销流程、证书链与证书验证流程，由于不是本文重点，所以此处不再赘述，有兴趣的读者请自行查询相关内容。

#### 1.3 RA
RA是用户和CA之间的桥梁，它可以获取、认证用户的身份，然后向CA发送申请证书的请求。对于规模较小的PKI来说，RA的功能可以整合到CA中，以节约成本，
但是PKI国际标准建议使用独立的RA来实现用户注册功能，以提高PKI系统安全性。

#### 1.4 证书发布系统
实现证书的发放，可以通过LDAP服务器供用户进行证书及CRL的下载。

#### 1.5 PKI应用
是基于PKI的证书和密钥使用特定功能的一些系统，如VPN、TLS协议等，它们的实现原理都是基于PKI的数字证书实现身份认证，然后使用非对称加密实现密钥协商。

### 2. PKI与区块链
在公链中，节点可自由上下链，没有任何门槛。但在联盟链中，节点准入需要授权，而且需要对节点进行访问控制。仅使用数字签名技术无法实现身份认证和访问控制，
所以也需要一个数字证书将密钥和密钥拥有者身份信息联系起来，从而实现对应功能。

联盟链中的节点主要与链内节点通信，所以节点证书不一定由外部第三方可信CA产生，区块链内部被大多数节点信任的一个或多个CA就能满足联盟链网络中各节点间身份认证的需求。
除了CA，区块链还需要一个实现密钥的生成与管理等功能的服务，在联盟中这个服务通常称为MSP（member service provider）。

MSP是区块链上一个身份认证和权限管理的抽象逻辑组件，认证的范围是所有可能与本网络建立联系的节点，只有经过授权的节点才能通过验证。区块链上证书的验证过程，
依旧是「证书链」的验证过程，即直到找到一个颁发者是区块链上的可信CA，证书验证才完成，所以MSP还要维护一份CRL，以及自己可信的CA列表（内容是CA证书列表），
这两份列表在验证节点身份时发挥重要作用。MSP的配置文件还可以配置相应的安全策略，如是否对RPC请求来源进行验证、是否验证对等节点身份、是否采用分布式CA等。
MSP使用配置文件初始化后，可以实现签名、验签、密钥生成等具体功能。

#### 2.1 区块链中的CA
大体分两种，一种是本地CA，本地系统掌握私钥；另一种是远程CA，远程系统掌握私钥，如CFCA（中国金融认证中心）。根据是否需要配置相同的可信CA列表，
区块链中的CA可分为两种：中心式CA和分布式CA，趣链区块链平台支持这两种CA。

**【一、中心式CA】**  
在中心式CA中，所有节点都需要配置一个CRL及一个相同的可信CA列表（内容为CA证书列表），这些证书可以是本地CA或远程CA证书。在节点通信时，
根据本地的两个CA列表对对方节点发来的证书进行验证其合法性，同时也发送自己的证书给对方验证。

**【二、分布式CA】**  
在分布式CA中，所有节点依然需要配置一个CRL，但是不需要为节点配置相同的可信CA列表，需要配置网络内所有CA对**本节点**颁发的证书，
在与不同节点通信时，只需要使用该节点支持的CA颁发的证书。为了实现节点的动态添加，在分布式CA中，仅支持本地CA，不支持远程CA，因此每个节点本质上都是一个CA。
新节点在加入后，需要向本网络中的所有CA申请证书，并记录在指定文件中，这样节点在重启后可以顺利地与其他节点进行通信。

#### 2.2 不同类型的证书
为了实现对节点和其他外部连接的访问控制，通常需要设计多种证书类型，节点持有不同类型的证书，代表拥有不同权限。例如，趣链区块链平台支持三种证书类型：
SDK证书、节点准入证书、CA证书。使用SDK访问链上数据时，需要提供SDK证书，否则不能建立连接；普通节点在加入区块链网络时，需要提供节点准入证书；
验证这些证书需要CA证书支持。

## Merkle树
译为默克尔树，也称哈希树。是存储hash值的一棵树。其叶子节点是原始数据的hash值，非叶节点是其子节点串联字符串的hash值。  
Merkle树可以看做是hash列表的泛化，通过构造树形结构的hash验证路径，可以对完整数据的单个分支单独完成验证，一定程度上这提高了完整性验证的效率。

### 1. 基于hash列表的完整性校验
hash列表可用于P2P网络数据传输的完整性校验。在P2P网络中，原始大数据块被分割成多个小数据块实现分布式下载，最后合成完整的大数据块。这时可以通过
构造hash列表实现对多个小数据块的完整性校验。大概过程：先计算每个小数据块的hash值，这些hash值级联在一起做一次hash计算，就得到hash列表的根hash。
下载数据时，首先从可信数据源得到正确的根hash，便可以用来校验hash列表的正确性，进而校验整个数据块的完整性。  
结构如下图 
![](https://github.com/BruceCoins/Pizza369/blob/main/docs/image/hash_tree.jpg)

### 基于Merkle树的完整性校验
它的大致结构和hash列表类似，不同的是它的相邻节点会合并计算一个新的hash值作为上一层节点，若这一层是奇数个节点，则最后一个节点的hash值直接呈上。
以此计算，最终获得一个根节点和所有内部节点。  
在P2P网络下载之前，可以先从可信节点获得文件的Merkle树根节点，然后再从其他不可信节点获取树的子节点。与hash列表不同的是，Merkle树可以下载验证一个单独
分支，如果分支节点损坏，只需重新下载分支节点。当文件较大时，Merkle树的效率显著高于Hash列表。  
Merkle树多指完全二叉树，也可以是完全多叉树。结构如下图
![](https://github.com/BruceCoins/Pizza369/blob/main/docs/image/merkle_tree.jpg)

## 数字签名技术
是指使用私密对数据进行一种密码运算生成的一串字符，用来代替手写签名或印章。在某些场景中，需要确认消息来源，防止欺诈或消息伪造，通常使用的技术就是数字签名。

### 1. 原理
数字签名技术是随着公钥密码算法（非对称加密）发展起来的，在身份验证、数据源认证、完整性保护、不可否认性方面有重要用途。  
它主要包括两部分：签名生成和签名验证。过程是：选择一种公钥算法，使用私钥加密原数据得到签名字符串，验证方使用公钥和该算法进行解密操作，若解密后的数据与收到的
源数据的摘要一致则说明签名有效。详细步骤：
1. 验证方通过可信途径获得签名者的公钥，例如可通过公钥数字证书获得；
2. 接收到签名后，计算原数据的摘要，并使用验证算法进行验证，通过摘要比对是否一致来判断签名的有效性；
### 2. 可选方案
- RSA签名
- 椭圆曲线签名方案（ECDSA）

## 零知识证明（Zero—Knowledge Proof，ZKP）

>本节内容主要参考自：https://zhuanlan.zhihu.com/p/152065162  
> 零知识证明学习资源索引：https://learnblockchain.cn/2019/11/08/zkp-info

它是在20世纪80年代初提出的，指的是证明者能够向验证者证明自己拥有某个秘密，而不暴露该秘密，即给外界的「知识」为零。   
它还分为交互式\~和非交互式\~。

零知识证明具有以下三个重要的性质：
- 完备性（Completeness）：只要证明者拥有相应的知识，那么就能通过验证者的验证，即证明者有足够大的概率使验证者确信。；
- 可靠性（Soundness）：如果证明者没有相应的知识，则无法通过验证者的验证，即证明者欺骗验证者的概率可以忽略;
- 零知识性（Zero-Knowledge）：证明者在交互过程中仅向验证者透露是否拥有相应知识的陈述，不会泄露任何关于知识的额外信息。

从零知识证明定义中可以提取到两个关键词：“不泄露信息”，“证明论断有效”，基于这两个特点扩展出零知识证明在区块链上的两大应用场景：

**隐私**：在隐私场景中，我们可以借助零知识证明的“不泄露信息”特性，在不泄漏交易的细节（接收方，发送方，交易余额）的情况下证明区块链上的资产转移是有效的。  
**扩容**：在扩容场景中，我们不太需要关注零知识证明技术的“不泄露信息”这个特性，我们的关注重点是它的“证明论断有效”这个特性，由于链上资源是有限的，所以我们需要把大量的计算迁移到链下进行，因此需要有一种技术能够证明这些在链下发生的动作是可信的，零知识证明正好可以帮助我们做链下可信计算的背书。

### 1. 交互式零知识证明（Interactive Zero-Knowledge, IZK）
证明者和验证者双方按照一个协议，通过一系列交互，最终验证者会得出一个明确的结论，证明者是或不掌握这个秘密。

### 2. 非交互式零知识证明（Non-Interactive Zero-Knowledge, NIZK）
交互式零知识证明协议依赖于验证者的随机尝试，需要证明者和验证者进行多次交互才能完成。非交互式零知识证明，将交互次数减少到一次，可实现离线证明和公开验证。

>区块链系统使用的就是这种，因为在区块链系统中，不能假设双方一直在线进行交互，在区块链网络上，证明者只要向全网广播一条证明交易，网络上的矿工在将
这条交易打包到区块中的时候就帮验证者完成了零知识证明的校验。

### 3. 发展历史
- 1985 年，零知识证明Zero-Knowledge Proof - 由 S.Goldwasser、 S.Micali 及 C.Rackoff 首次提出。
- 2010年，Groth实现了首个基于椭圆曲线双线性映射全能的，常数大小的非交互式零知识证明协议。后来这个协议经过不断优化，最终成为区块链著名的零知识证明协议SNARKs。
- 2013年，Pinocchio协议实现了分钟级别证明，毫秒级别验证，证明大小不到300字节，将零知识证明从理论带到了应用。后来Zcash使用的SNARKs正是基于Pinocchio的改进版。
- 2014 年，名为Zerocash的加密货币则使用了一种特殊的零知识证明工具zk-SNARKs （ Zero-Knowledge Succinct Non-interactive Arguments of Knowledge ) 实现了对交易金额、交易双方的完全隐藏，更注重于隐私，以及对交易透明的可控性。
- 2017 年， Zerocash 团队提出将 zk-SNARKs 与智能合约相互结合的方案，使交易能在众目睽睽下隐身，打造保护隐私的智能合约。

**零知识证明开发工具**  
目前，为了解决零知识证明技术的广泛应用需求，产生了多个用于实现zk-SNARK 零知识证明协议工程化的开源算法库，包括 **libsnark、bellman、ZoKrates** 等等。

### 4. 区块链如何应用零知识证明
#### 4.1 隐私
例如在比特币交易过程中，一笔交易是否合法，实际只需验证三件事：
- 发送方确实拥有这么多钱
- 发送方转的钱和接收方收的钱一致
- 发送方的钱对应数额确实被销毁了

整个证明过程中，矿工其实并不关心具体花掉了多少钱，发送者具体是谁，接受者具体是谁。**矿工只关心系统的钱是不是守恒的**。Zcash(大零币) 
就是用这个思路实现了隐私交易。

#### 4.2 扩容
早期的公链项目的TPS非常低，如比特币的TPS约为7，以太坊TPS约为15，这意味着以太坊每秒只能处理15笔交易，如此低的TPS严重限制了区块链应用的大规模落地，
所以有人开始研究区块链扩容的问题，目的就是为了提高链上的TPS。但区块链扩容受到Vitalik提出的不可能三角的限制，不可能三角是指区块链系统设计无法同时
兼顾可扩展性，去中心化和安全性，三者只能取其二。这是一个很让人失望的结论，但我们必须知道，一切事物都有自己的边界，公链不应该做所有的事情，公链应该
做它该做的事情：“公链是以最高效率达成共识的工具，能够以最低成本来构建信任”。  

作为共识的工具，信任的引擎，公链不应该为了可扩展性放弃去中心化与安全性。那么公链的TPS这么低，该怎么使用呢？我们是否可以将大量的工作放到链下去解决，
仅仅将最重要的数据提交到区块链主链上，让所有节点都能够验证这些链下的工作都是准确可靠的呢？社会的发展带来的是更精细化的分工，区块链的技术发展也是如此，
在底层区块链（Layer1）上构建一个扩展层（Layer2)，Layer1来保证安全和去中心化，绝对可靠、可信；它能做到全球共识，并作为“加密法院”，通过智能合约
设计的规则进行仲裁，以经济激励的形式将信任传递到Layer2 上，而Layer2追求极致的性能，它只能做到局部共识，但是能够满足各类商业场景的需求。

**链下扩容**  
ZK-Rollup就是基于零知识证明的二层扩容方案， ZK-Rollup方案起源于18年下半年，由Barry Whitehat和Vitalik先后提出。Rollup顾名思义有“卷起”和
“汇总”的意思，将大量的交易“卷起/汇总”打包成一个交易。  
ZK-Rollup的原理一句话就可以讲清楚：链下进行复杂的计算和证明的生成，链上进行证明的校验并存储部分数据保证数据可用性。ZK-Rollup数据可用性可以
让任何人都能根据链上存储的交易数据，还原出账户的全局状态。

## Base58编码方案
是一种58进制编码方案，与Base64类似，是一种基于58个可打印字符来表示二进制数据的方法。这些可打印字符包含了阿拉伯数字，大小写英文字母。
在Base64基础上去掉了6个易混淆字符，如数字0，大写O，小写L，大写i以及+/，以便在任何字体中都能肉眼区分字符。
>Base58和Base64的缺点是会造成信息冗余，输出比输入大许多，所以这种编码方案只适合小数据。而且Base58与Base64不同的是，前者采用大数进制转换，
> 效率更低，所以使用场景更少。

Base64普通应用于URL，短文本，图片；Base58一般用在比特币地址、私钥和脚本哈希场景。