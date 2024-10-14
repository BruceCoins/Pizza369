// SPDX-License-Identifier: PDX-3.0
pragma solidity ^0.8.0;

/*
@函数类型
-   介绍
    solidity的函数也可以作为其他函数参数，与其他静态语言类似;
    函数类型：function(<params types>) {external|internal}
            [pure|constant|view|payable] [returns (<return types>)]
    其中external/public函数拥有以下成员属性、方法：
        -   .address  返回函数所属合约地址
        -   .selector   函数选择器，本质上是函数签名的前4字节，bytes4类型；其计算方式公开：bytes4(keccak256(funcSign))
            -   selector 是函数对于合约的唯一标识，可以通过它来调用函数
        -   .gas(uint)   调用函数时指定可消耗的gas；新版本语法改为：somefunc{gas:xxx}
        -   .value(uint)  调用函数时给函数注入以太币，将被函数所属合约接收；新版本语法改为：somefunc{value:xxx}

-   函数的唯一性由函数名和参数组成：即可以存在多个同名函数，参数类型或数量不同即可。
*/
contract FunctinTypes{
    //状态变量
    uint256 public number = 5; 

    //默认函数，对 状态变量 进行操作
    function add() external{
        number = number + 1;
    }

    /** pure ：
            作用于 状态变量
            不能读取、写入链上的状态变量
    */

    // 如果 默认函数被 pure 修饰 【function add() external pure{ number = number + 1; } 】将报错，因为pure不能对状态变量进行读、写操作
    // 如果 改成 对局部变量 的操作 是可以的：
    function add2(uint256 number_2) external pure returns(uint256){
        return number_2 + 1;
    }


    /** view：
            作用于 状态变量
            不能写入，只能读取链上的状态变量
    */
    // 如果 默认函数被 view 修饰 【function add() external view{ number = number + 1 } 】将报错，因为 view 不能对 状态变量 进行写操作，只能读取
    // 如果 默认函数没有参数、但是有返回值，则可以：
    function add3() external view returns(uint256){
        return number + 1;
    }
    /** internal: 只允许合约内部调用
        external: 只允许外部合约调用
    */
    function minus() internal{
        number = number - 1;
    }
    
    //外部合约 可以通过 minusCall() 调用内部合约 minus()
    function minusCall() external{
        minus();   
    }

    /**
        payable: 允许支付eth
    */
    //间接调用 minus() 方法，返回合约剩余金额
    function minusPayable() external payable returns(uint256 balance){
        minus();
        balance = address(this).balance;
    }
}
contract Example{
    bytes4 public add_selector;
    event receiveEther(uint);
    constructor() {
    }
    function add(uint a, uint256 b) public pure returns (int){
        return int(a+b);
    }
    function set_selector_val() public {
        // 注意
        add_selector = this.add.selector;
        // 其生成方式如下
        bytes4 x = bytes4(keccak256("add(uint256,uint256)")); // 函数签名不含返回值，且对于uint/int都要写为256类型
        require(add_selector == x);
    }

    // 允许同名函数，只要参数不同
    function add(uint a) internal pure {
        require(a + 1>0);
    }

    function receive_ether() public payable {
        // 记录收到的以太币数量
        emit receiveEther(msg.value);
    }
}

contract LearnFunctionType {
    Example exp = new Example();
    constructor(){
        exp.set_selector_val();
    }

    function call_example_func()public{
        // 演示使用selector来调用函数
        // -    abi.encodeWithSelector() 将函数selector和参数编码为ABI编码，传入call进行调用
        bytes memory payload = abi.encodeWithSelector(exp.add_selector(), 1,2);
        (bool succ, bytes memory data) = address(exp).call(payload);
        require(succ, "call add() failed!");

        uint256 ret = abi.decode(data, (uint256));
        require(ret==3, "add(1,2) != 3 ???");
    }

    // 透传msg.data 作为address.call()参数，本质上是一个效果。因为以太坊的函数交互也是使用函数和参数的ABI编码形式
    // 注意：这里要求函数名和参数类型及数量完全一致
    function add(uint a, uint b) public {
        (bool succ, bytes memory data) = address(exp).call(msg.data);
        require(succ, "call add() failed!");

        uint256 ret = abi.decode(data, (uint256));
        require(ret==a+b, "add(a,b) != a+b ???");
    }

    // abi.encodeWithSignature 直接以函数签名为参数
    function call_example_func2() public {
        bytes memory payload = abi.encodeWithSignature("add(uint256,uint256)", 1,2);
        (bool succ, bytes memory data) = address(exp).call(payload);
        require(succ, "call add() failed!");

        uint256 ret = abi.decode(data, (uint256));
        require(ret==3, "add(1,2) != 3 ???");
    }

    // 测试发送以太币给目标函数，以太币将被目标函数所属合约接收（测试时在部署控制台的Value输入框中输入要注入的以太币数量，然后观察调用logs）
    function testSendEther(address exp2) public payable {
        // 给函数发送以太币不同于地址转账，无需消耗2300gas，这里由于该函数内只有一条emit语句，所需消耗0gas，但是再添加一条emit就会需要更多gas，具体指令的消耗规则需要观察编译后的操作码
        Example(exp2).receive_ether{value: msg.value, gas:0}();
        //  exp.receive_ether{value: msg.value}();
    }
}
