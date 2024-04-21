//SPDX-License-Identifier:MIT

pragma solidity ^0.8.21;

// 透明代理 
contract TransparentProxy{
    address implementation;
    address admin;
    string public words;

    constructor(address _implemention){
        admin = msg.sender;
        implementation = _implemention;
    }

    //fallback 函数，将调用委托给逻辑合约
    //不能被admin调用，避免选择器冲突引发意外
    fallback() external {
        require(msg.sender != admin);
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    //升级函数
    function upgrade(address newImplementation) external{
        if (msg.sender != admin) revert();
        implementation = newImplementation;
    }
}


// 旧逻辑合约
contract Logic1{
    //状态变量和 proxy 保持一致，防止插槽冲突
    address public implementation;
    address public admin;
    string public words;

    function foo() public{
        words = "old";
    }
}

//新 逻辑合约
contract Logic2{
    address public implementation;
    address public admin;
    string public words;

    function foo() public{
        words = "new";
    }
}