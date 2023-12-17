// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

    // 好的合约函数结构分为三个阶段：
    // 1. 检查条件
    // 2. 执行动作 (可能会改变条件)
    // 3. 与其他合约交互

contract BlindAuction{
    
    //竞拍 结构体
    struct Bid{
        bytes32 blindedBid; //盲拍加密后的金额 = keccak256(value, fake, secret)
        uint deposit;   //订金
    }

    address payable public beneficiary;
    uint public biddingEnd;  //竞拍结束时间
    uint public revealEnd;   //披露结束时间
    bool public ended;       //竞拍结束标志

    mapping(address => Bid[]) public bids;  //参与的所有竞拍

    address public highestBidder;   //最高出价者地址
    uint public highestBid;         //最高出价金额

    mapping(address => uint) pendingReturns; //可以取回的之前的出价

    event AuctionEnded(address winner, uint highestBid);  //事件，返回最后赢家、最高出价

    error TooEarly(uint time);
    error TooLate(uint time);
    error AuctionEndAlreadyCalled();

    modifier onlyBefore(uint time){
        if(block.timestamp >= time) revert TooLate(time);
        _;
    }
    modifier onlyAfter(uint time){
        if(block.timestamp <= time) revert TooEarly(time);
        _;
    }

    //构造函数（参数：竞拍用时，披露用时，受益者地址）
    constructor(
        uint biddingTime,
        uint revealTime,
        address payable beneficiaryAddress
    ){
        beneficiary = beneficiaryAddress;           // 受益者地址
        biddingEnd = block.timestamp + biddingTime; // 竞拍结束时间
        revealEnd = biddingEnd + revealTime;        // 披露结束时间
    }

    //竞拍，将竞拍出价、订金 记录到bids中
    function bid(bytes32 _blindBid) external payable onlyBefore(biddingEnd){
        bids[msg.sender].push(Bid({
            blindedBid : _blindBid,
            deposit : msg.value
        }));
    }

    ///披露竞拍出价
    ///对于所有正确披露的无效出价以及除最高出价意外的所有出价，都将得到退款
    function reveal(
        uint[] calldata values,
        bool[] calldata fakes,
        bytes32[] calldata secrets
    )
        external 
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(values.length == length);
        require(fakes.length == length);
        require(secrets.length == length);

        uint refund; //退款
        for(uint i = 0; i < length; i++){
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint value, bool fake, bytes32 secret) = (values[i], fakes[i], secrets[i]);
            if(bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))){
                //出价未能正确披露
                //不返回订金
                continue;
            }
            refund += bidToCheck.deposit;
            if (!fake && bidToCheck.deposit >= value){
                if(placeBid(msg.sender, value))
                    refund -= value;
            }
            //使发送者不可能再次认领同一笔订金
            bidToCheck.blindedBid = bytes32(0);
        }
        payable (msg.sender).transfer(refund);
    }    

    // 内部函数
    function placeBid(address bidder, uint value) internal returns (bool success)
    {
        if(value <= highestBid){
            return false;
        }
        if(highestBidder != address(0)){
            // 返还之前的最高价
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    ///撤回出价过高的竞标
    function withdraw() external 
    {
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            payable (msg.sender).transfer(amount);
        }
    }

    /// 结束拍卖,并把最高出价发给受益人
    function aunctionEnd() external onlyAfter(revealEnd)
    {
        if(ended) revert AuctionEndAlreadyCalled();
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }

}