// SPDX-License-Identifier: GPT-3.0

pragma solidity >=0.7.0 <0.9.0;

//目标合约
contract OtherContract{
    uint256 private _x = 0;
    event Log(uint amount, uint gas);
    fallback() external payable{}
    receive() external payable { }

    //返回合约ETH余额
    function getBalance() view public returns(uint){
        return address(this).balance;
    }

    //修改 _x 值，并可以向合约转ETH(payable)
    function setX(uint256 x) external payable{
        _x = x;
        if(msg.value > 0){
            emit Log(msg.value, gasleft());
        }
    }

    //读取x值
    function getX() external view returns(uint x){
        x = _x;
    }
}

//call测试合约
contract CallContract{
    event Response(bool success, bytes data);

    //调用setX(uint256)函数
    //参数：目标合约地址，被调用函数参数
    function callSetX(address payable addr, uint256 x) public payable{
        (bool suc, bytes memory data) = 
            addr.call{value:msg.value}(abi.encodeWithSignature("setX(uint256)", x));

        emit Response(suc, data); 
    }

    //调用 getX()函数
    //参数：目标合约地址
    function callGetX(address  addr) public returns(uint256){
        (bool suc, bytes memory data) = 
            addr.call(abi.encodeWithSignature("getX()"));
        
        emit Response(suc, data);
        return abi.decode(data, (uint256)); 
    }

    //调用不存在的函数
    //参数：目标合约地址
    function callNoExist(address addr) external {
        (bool suc, bytes memory data) = 
            addr.call(abi.encodeWithSignature("noMethod(uint256)"));
        
        emit Response(suc, data);
    }
}