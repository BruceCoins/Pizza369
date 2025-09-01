// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

//引入 hardhat/console.sol库合约，可打印日志
import "hardhat/console.sol";

//简单计算器 加减法
contract Calculator{
    //加法
    function add(uint256 a, uint256 b ) public pure returns(uint256){
        uint256 c = a + b;
        console.log("a=%s, b=%s, a+b=%s ", a, b, c);
        return a+b;
    }

    //减法
    function sub(uint256 a, uint256 b) public pure returns(uint256){
        uint256 c = a - b;
        console.log("a=%s, b=%s, a+b=%s ", a, b, c);
        return a-b;
    }
}