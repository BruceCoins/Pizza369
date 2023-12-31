// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.1 <0.9.0;

/// 修饰器(modifier),
/// 修饰器执行后，调用函数在'_;'处执行
/// 修饰器可继承；可以被派生合约重载，但需要被标记为 virtual
contract owned{
    constructor() {owner = payable (msg.sender); }
    address payable owner;

    // 本合约定义了修饰器，但是没有使用
    // 它将在派生合约中使用
    modifier onlyOwner{
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
}

// 子合约继承了父类合约 的修饰器
contract destructible is owned{
    function destroy() public onlyOwner{
        selfdestruct(owner);
    }
}

//--------------------------------- 
contract priced{
    /// 修饰器 可以接收 参数
    modifier costs(uint price){
        if(msg.value >= price){
            _;
        }
    }
}

// 子合约继承多个父合约，可以使用每个父合约中的修饰器
contract Register is priced, destructible{
    mapping(address => bool) registeredAddresses;
    uint price;

    constructor(uint initialPrice) { price = initialPrice; }

    // 使用 priced 父合约中的 costs() 修饰器
    // payable 非常重要，否则函数会自动拒绝所有发送给它的以太币
    function register() public payable costs(price){
        registeredAddresses[msg.sender] = true;
    }

    // 使用destructible 父合约中的 onlyOwner() 修饰器
    function changePrice(uint price_) public onlyOwner{
        price = price_;
    }
}

contract Mutex{
    bool locked;
    modifier noReentrancy{
        require(
            !locked,
            "Reentrant call."
        );
        locked = true;
        _;
        locked = false;
    }

    /// 这个函数受互斥量保护，这意味着‘msg.sender.call’ 中的重入调用不能再次调用 ‘f()’
    /// ‘return 7 语句指定返回值为7， 但修饰器中语句 locked = false 仍会执行
    function f() public noReentrancy returns(uint){
        (bool success,) = msg.sender.call("");
        require(success);
        return 7;
    } 
}