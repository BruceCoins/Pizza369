# 基于 ChainLink VRF V2.5 进行开发  
[VRF（可验证随机数）V2.5 官方文档](https://docs.chain.link/vrf)  

- 本文档内容均在测试网 sepolia 上进行操作

## 1> 获取测试网代币  
[获取 Link 和 Sepolia ETH 水龙头](https://faucets.chain.link/sepolia)  

## 2> 申请 VRF V2.5 订阅并转入 Link  

### 2.1> 订阅  

进入[订阅管理界面](https://vrf.chain.link/)  
--> 点击 "Create Subscription"  
--> 连接钱包 "Connect Wallet"  
--> 创建订阅 "Create Subscription"，邮箱、项目名选填，钱包确认  
--> 转入代币 "Fund Subscription" ，选择资产、金额，此处使用 Link  
--> 添加用户 ”Add Consumer“，消费者地址即钱包地址，**Subscription ID（订阅ID号） 非常重要，使用 VRF 时用到** ，
    若忘记可在具体某条 **订阅的详情中查看 ID**


### 2.2> 取消订阅  

--> 在 My Subscriptions 选择取消的订阅  
--> 在右上角 Action 中点击 cancel Subscription 选项
--> 输入关联的钱包地址，点击 cancel Subscription 按钮即可  

## 3> 合约开发  

### 3.1> 用户合约继承 VRFConsumerBaseV2Plus

为了使用VRF获取随机数，合约需要继承 VRFConsumerBaseV2Plus 合约，并在构造函数中初始化 IVRFCoordinatorV2Plus 和 Subscription Id。  

- **注意：** 文档使用的网络是 Sepolia ，若使用其他网络，配置信息可参考 [V2.5支持的网络](https://docs.chain.link/vrf/v2-5/supported-networks)
