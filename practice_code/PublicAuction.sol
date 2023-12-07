// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.4;

contract PublicAuction{

    // 好的合约函数结构分为三个阶段：
    // 1. 检查条件
    // 2. 执行动作 (可能会改变条件)
    // 3. 与其他合约交互

    address payable public beneficiary;

    //拍卖结束时间，unix的绝对时间（自1970-01-01以来的秒数）
    uint public auctionEndTime;

    //拍卖的当前状态
    address public highestBidder; //出价最高者
    uint public highestBid; //最高价

    //可以取回的之前的出价 ‘用户地址=>出价’ 合集
    mapping(address => uint) pendingReturns;

    bool ended; //拍卖结束标志 true，将禁止所有变更
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);    //获胜者地址、金额

    //Errors 用来定义失败
    /// 拍卖会已经结束
    error AuctionAlreadyEnded();
    /// 已经有相同出价或更高出价
    error BidNotHighEnough(uint highestBid);
    /// 拍卖会还没有结束
    error AuctionNotYetEnded();
    /// 函数 “actionEnd” 已经被调用过了
    error AuctionEndAlreadyCalled();

    //  构造函数
    /// 以受益者地址 beneficiaryAddress 名义，
    /// 创建一个简单的拍卖，拍卖时间为 biddingTime 秒
    constructor(uint biddingTime, address payable beneficiaryAddress){
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;   //拍卖结束时间 = 系统时间 + 拍卖时间
    }

    /// 对拍卖进行出价，具体的出价随交易一起发出
    /// 如果没有在拍卖中胜出，则返还出价
    function bid() external payable{
        // 参数不是必要的，因为所有的信息已经包含在交易中
        // 对于能接收以太币的函数，关键字用 payable 是必须的

        // 如果拍卖已结束，撤销函数的调用
        if(block.timestamp > auctionEndTime)
            revert AuctionAlreadyEnded();
        // 如果出价不够高，提醒价格不是最高，返还钱
        if(msg.value <= highestBid)
            revert BidNotHighEnough(highestBid);
        if(highestBid != 0){
            // 返回出价时，简单的调用 highestBidder.send(highestBid) 函数
            // 有安全风险，因为它可能执行一个非信任合约，
            // 更安全的做法是让 接收方 自己提取金钱
            pendingReturns[highestBidder] += highestBid;  //计算应返还的总价
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    ///取回出价（当前出价已被超越）
    function withdraw() external returns(bool re){
        uint amount = pendingReturns[msg.sender];
        if (amount > 0){
            // (1)先设置为0，防止接收者在“send”返回之前，重新调用该函数
            pendingReturns[msg.sender] = 0;
            // 将地址显示的转换为 payable 类型，才可调用send函数
            if(!payable (msg.sender).send(amount)){ //转账失败，重置未付款
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
    }

    //拍卖结束，并把最高的出价发送给受益人
    function auctionEnd() public {
        // 1 条件
        if(block.timestamp < auctionEndTime)
            revert AuctionNotYetEnded();
        if(ended)
            revert AuctionEndAlreadyCalled();
        
        // 2 生效
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // 3 交互
        beneficiary.transfer(highestBid);
    }
}
