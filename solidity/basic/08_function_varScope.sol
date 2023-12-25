// SPDX-License-Identifier: PDX-3.0
pragma solidity ^0.8.0;

/*
@函数
-   介绍
    -   函数可以定义在合约内、外
    -   可以有多个入参和出参，出参可以命名
    函数可见性（必须表明）：
        -   private：限制性最强，函数只能在所属的合约内使用，继承合约不可以使用
        -   internal：可以在定义和继承合约内使用
        -   external：只能从外部调用，内部可以用this.xxx来调用
        -   public：都能调用
        -   构造函数不用设置可见性，旧版本通过internal来表明不可部署，新版本通过abstract来表示。
    状态可变性（mutablity）
        -   view：只能读取状态
        -   pure：不能读写
        -   payable：调用函数可以给合约发送以太币
    函数重载：合约内可以定义多个同名但不同参数的函数，并且在合约内外有效！

@变量作用域
-   介绍
    -   与其他语言没有太大差别，也采用C99作用域规则。
    要注意的是，状态变量可以修饰可见性：
        -   public：任意位置调用，从当前合约外调用，需要访问getter函数
        -   internal：可以从合约内、继承合约内调用
        -   private：只能在当前合约内调用
*/

// v0.7.0版本开始支持合约外定义函数，不过只能被合约调用，不能直接部署
    function free(int a, int b) pure returns (int,int) {
        return (a,b); // 多返回值需要是tuple类型
    }

contract LearnFunction{

    int balance = 100;

    // pure: 这个函数没有读写合约内的状态变量(局部变量不算)
    function add(int a, int b) public pure returns (int) {
        int c = 1;
        c--;
        (int a1,int b1) = free(a,b); // 多返回值需要tuple类型接收
        return a1 + b1;
    }

    // 因为修改了状态变量，所以无需标注
    function withdraw() public {
        balance --;
    }

    // view：读取了状态变量
    function getBalance() public view returns(int) {
        return balance;
    }

    // payable支持外部调用时注入以太币
    function recharge() public payable{}
}

contract VarScope{
    uint v1; // 默认internal，可被继承合约访问
    uint public v2;
    uint private v3; // 继承合约也无法访问
    constructor(uint v1Init) {
        v1 = v1Init;
    }

    function getV1() internal view returns (uint) {
        return v1;
    }
}
contract LearnVarScope {
    constructor() {
        VarScope vs = new VarScope(1);
        vs.v2(); // getter()形式访问public变量
        // vs.v1();  // 不能外部访问internal变量
    }
}

// 继承合约VarScope，继承时需要传入构造参数（不传就变成抽象合约了）
contract LearnVarScope2 is VarScope(1) {
    constructor() {
        require(v1 == 1); // 直接访问v1
        require(v1 == getV1()); // 可以调用internal函数
    }
}

// 允许存在多个同名不同参数的函数，在合约内外可以同时使用
contract LearnFuncOverloadding{
    function add(uint a, uint b) public pure {}
    // function add(uint a, uint c) public pure {} //  函数参数同数量时不能同类型
    function add(uint a, uint b, uint c) public pure {}

    function test() public pure {
        add(1,2,3);
        add(1,2);
    }
}