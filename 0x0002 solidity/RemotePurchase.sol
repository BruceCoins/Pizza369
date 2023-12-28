// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

    // 好的合约函数结构分为三个阶段：
    // 1. 检查条件
    // 2. 执行动作 (可能会改变条件)
    // 3. 与其他合约交互
//远程购买
contract RemotePurchase{
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State{Created, Locked, Release, Inactive}  //创建、锁定、释放、闲置
    //状态变量默认是第一个成员 ： 'state.Created'
    State public state;

    //验证状态
    modifier condition(bool condition_){
        require(condition_);
        _;
    }

    /// 只有买方可以调用这个函数
    error OnlyBuyer();
    /// 只有买方可以调用这个函数
    error OnlySeller();
    /// 当前状态下不能调用这个函数
    error InvalidState();
    /// 提供的值必须为偶数
    error ValueNotEven();

    modifier onlyBuyer(){
        if(msg.sender != buyer)
            revert OnlyBuyer();
        _;
    }

    modifier onlySeller(){
        if(msg.sender != seller)
            revert OnlySeller();
        _;
    }

    modifier inState(State state_){
        if(state != state_)
            revert InvalidState();
        _;
    }

    event Aborted();            // 中止，退货
    event PurchaseConfirmed();  // 确认购买
    event ItemReceived();       // 物品收到
    event SellerRefunded();     // 卖家已退款

    //确保 ‘msg.value’ 是一个偶数
    constructor() payable {
        seller = payable (msg.sender);
        value = msg.value / 2;
        if((2 * value) != msg.value)
            revert ValueNotEven();
    }

    /// 终止购买并收回ether
    /// 只能由卖方在合同锁定前能调用
    function abort() external onlySeller inState(State.Created)
    {
        emit Aborted();
        state = State.Inactive;
        // 这里使用 ‘transfer’
        // 它可以安全的重入
        // 因为它是这个函数中的最后一次调用
        // 而且我们已经改变了状态
        seller.transfer(address(this).balance);
    }

    /// 买房确认购买
    /// 交易必须包括 '2 * value' 个ether
    /// Ether将被锁定，知道调用confirmReceived.
    function confirmPurchase() 
        external 
        inState(State.Created)
        condition(msg.value == ( 2 * value))
        payable 
    {
        emit  PurchaseConfirmed();
        buyer = payable (msg.sender);
        state = State.Locked;
    }

    /// 确认您(买方)已经收到了该物品
    /// 这将释放锁定的ether
    function confirmReceived()
        external 
        onlyBuyer
        inState(State.Locked)
    {
        emit ItemReceived();
        state = State.Release;
        buyer.transfer(value);
    }

    /// 该功能为卖家退款
    /// 即退还卖家锁定的资金
    function refundSeller()
        external 
        onlySeller
        inState(State.Release)
    {
        emit SellerRefunded();
        state = State.Inactive;
        seller.transfer(3 * value);
    }
}