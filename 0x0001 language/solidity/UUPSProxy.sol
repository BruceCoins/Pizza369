//SPDX-License-Identifier:MIT 
pragma solidity ^0.8.21;

//UUPS 和 透明代理的区别在于， UUPS 的升级函数放在了 逻辑合于中实现

//代理合约
contract UUPSProxy{
    address public implementation;  // 逻辑合约地址
    address public admin;   // admin地址
    string public words;    // 字符串，可以通过逻辑合约的函数改变

    constructor(address _implementation){
        admin = msg.sender;
        implementation = _implementation;
    }

    fallback() external {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }
}


//逻辑合约 1 
contract UUPS1{
    address public implementation;
    address public admin;
    string public words;


    // 改变 proxy 中状态变量，选择器： 0xc2985578
    function foo() public{
        words = "old";
    }

    // 升级函数，改变逻辑合约地址，只能由admin调用。选择器：0x0900f010
    // UUPS中，逻辑合约中必须包含升级函数，不然就不能再升级了。
    function upgrade(address newImplementation) external{
        require(msg.sender == admin);
        implementation = newImplementation;
    }

}


//逻辑合约2
contract UUPS2{
    address public implementation;
    address public admin;
    string public words;

    // 改变 proxy 中状态变量，函数选择器：0xc2985578
    function foo() public{
        words = "new";
    }

    // 升级函数，改变逻辑合约地址，只能由admin调用。选择器：0x0900f010
    // UUPS中，逻辑合约中必须包含升级函数，不然就不能再升级了。
    function upgrade(address newImplementation) external{
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}