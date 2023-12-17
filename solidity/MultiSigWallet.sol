// SPDX-License- Identifier: MIT
pragma solidity ^0.8.10;

/*
    多签名钱包
 */

contract MultiSigWallet{
    event Deposit(address indexed sender, uint amount);     //存款事件
    event Submit(uint indexed txId);                        //提交交易申请事件
    event Approve(address indexed owner, uint indexed txId);//批准事件
    event Revoke(address indexed owner, uint indexed txId); //撤销批准事件
    event Execute(uint indexed txId);                       //执行事件（批准后执行）

    //交易的结构体，保存 每次对外发出主币 的交易数据
    //交易数据 由一个签名人发起提议，其他签名人同意通过，来完成交易
    struct Transaction{
        address to;     //交易发送的 目标地址
        uint value;     //交易发送的 主币数量
        bytes data;     //如果交易地址是 合约，还可以执行 合约中的一些操作
        bool exeuted    //交易发送状态（成功、失败）；交易已被执行，就不能重复执行
    }

    address[] public owners;                    //合约所有的签名人
    mapping(address => bool) public isOwner;    //映射，判断是否是签名人（若用for循环遍历数组，浪费gas）
    uint public required;                       //确认数，至少满足签名的人数

    Transaction[] public transactions;                          //记录 所有交易的id
    mapping(uint => mapping(address => bool)) public approved;  //记录 某个交易中 => 签名人(地址)是否 签名过 


    //修改器：判断当前的消息发送者 是不是 签名数组中的成员
    modifier onlyOwner(){
        require(isOwner[msg.sender], "not owner");
        _;
    }

    //修改器：判断交易id号 是否存在; 交易id号是通过【数组长度-1】得到的
    modifier txExits(uint _txId){
        require( _txId < transactions.length, "tx does not exist");
        _;
    }

    //修改器：判断 签名人是否对 交易id号 进行过批准
    modifier notApproved(uint _txId){
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }
    
    //修改器：判断 交易id号 是否被执行过
    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    /*
        构造函数
        参数：所有签名人地址、最少的签名数
    */
    constructor(address[] memory _owners, uint _required){
        require(_owners.length > 0, "owners required");         //判断签名人数量
        require(_required > 0 && _required <= _address.length, 
                "invalid required number of owners");           //判断最少签名数,且不能多于签名人数量

        //判断 签名人地址 是否有效
        for(uint i; i < _owners.length; i++){
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");      //不能是0地址
            require(!isOwner[owner], "owner is not unique");    //不能已经被添加过

            isOwner[owner] = true;
            owners.push(owner);
        }
        require = _required;    //最少签名数
    }

    /*
        合约接受主币
    */
    receive() external payable{
        emit Deposit(msg.sender, msg.value);
    }

    /*
        提交交易
        参数：发送的目标地址 _to; 发送数量 _value；
              若目标地址是合约，可触发合约函数，返回data数据
    */
    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner{
        //将 交易结构体 推入到数组 中
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        }));
        emit Submit(transactions.length - 1) //交易id号
    }

    /*
        批准交易：一个签名人提交，其他签名人针对 交易id号 进行批准，达到最小确认数后，交易执行
                onlyOwner：判断批准方法只能是签名人
                txExits(_txId)：判断交易id号 是否存在
                notApproved(_txId)：判断签名人是否 已经批准过了，避免重复批准
                notExecuted(_txId)：判断交易id号 是否已经执行过了
    */
    function approve(uint _txId) 
        external 
        onlyOwner           
        txExits(_txId)
        notApproved(_txId)
        notExecuted(_txId){
            approved[_txId][msg.sender] = true;
            emit Approve(msg.sender, _txId);
    }

    /*
        计算多少签名人批准了交易：(内部函数)
    */
    function _getApprovalCount(uint _txId) private view returns(uint count) {
        for(uint i; i<owners.length; i++){
            if(approved[_txId][owners[i]]){
                count += 1;
            }
        }
    }

    /*
        执行方法
    */
    function execute(uint _txId) external txExits(_txId) notExecuted(_txId){
        require(_getApprovalCount(_txId) >= required, "approvals < required");
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;    //首先修改 交易执行状态
        (bool success, )transaction.to.call{value:transaction.value}(
            transaction.data
        );                              //call{value:主币数量} 也可以加入gas，逗号隔开
        require(success, "tx failed")
    }
    emit Execute(_txId)


    /*
        撤销执行
    */
    function revoke(uint _txId) external onlyOwner txExits(_txId) notExecuted(_txId){
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false; //撤销当前用户对某一交易的批准
        emit Revoke(msg.sender, _txId);
    }
}