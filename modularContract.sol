// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

// 创建库文件
library Balances{

    // 创建函数，检查地址之间发送的余额是否满足条件
    function move(mapping(address => uint256) storage balances, address from, address to, uint amount) internal
    {
        require(balances[from] >= amount);
        require(balances[to] + amount >= balances[to]);
        balances[from] -= amount;
        balances[to] += amount;
    }
}

contract Token{

    mapping(address => uint256) balances;   // 地址->金额 
    using Balances for *;                   // 引用库函数
    mapping(address => mapping(address => uint256)) allowed;    // 
    
    event Transfer(address from, address to, uint amount);
    event Approval(address owner, address spender, uint amount);

    // 交易函数
    function transfer(address to, uint amount) external returns (bool success)
    {
        balances.move(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // 
    function transferFrom(address from, address to, uint amount) external returns(bool success)
    {
        require(allowed[from][msg.sender] >= amount);
        allowed[from][msg.sender] -= amount;
        balances.move(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint tokens) external returns(bool success)
    {
        require(allowed[msg.sender][spender] == 0, "");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function balanceOf(address tokenOwner) external view returns(uint balance)
    {
        return balances[tokenOwner];
    }

}