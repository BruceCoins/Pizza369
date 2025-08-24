// SPDX-License-Identifier: PDX-3.0
pragma solidity ^0.8.0;

/*
@引用类型
- 介绍
    值类型在传递时总是复制，有一定内存开销。一些较大较复杂的类型只适合传递引用，所以需要引用类型。有如下几种引用类型：
    -   struct(结构体)
    -   不定长数组（所以定长数组是值类型，如uint[2]）
    -   mapping（映射）
    引用类型声明时需要标识其存储的位置，可以是:
    -   memory：临时存储，离开执行环境则释放
    -   storage：合约存在期间持续存储
    -   calldata：用于存储函数参数的特殊位置，只读区，三者开销最小。
    引用类型在赋值时，如果改变了数据存储位置，则发生复制！
    特殊类型：bytes和string，这两个类型在声明时也需要标识位置，本质上是因为它们都是 byte[] 构成的
*/

contract LearnBase{
     //固定长度数组
    uint[8] array1;
    bytes1[2] array2;

    //可变长度数组
    uint[] array3;
    bytes1[] array4;  
    bytes array5;   //bytes是数组，不加 [] 

    // 对于 memory 修饰的 动态数组，可以使用 new 来创建，但必须声明长度，且长度不能改变
    // solidity 0.8 以后的版本，不再使用 memory ，可以直接通过 new 来创建 
    uint[]  array6 = new uint[](5);
    bytes  array7 = new bytes(9);

    function ArrayPush() public returns(uint[] memory){
        uint[2] memory a = [uint(1),2];
        array3 = a;
        array3.push();
        array3.push(3);
        return array3;
    }

    //----------结构体 struct-----------
    struct Student{
        uint256 id;
        uint256 grade;
    }
    Student public student;

    // 赋值方式 1：创建 storage 引用来赋值
    function initStudent() external{
        Student storage stu = student;
        stu.id = 12;
        stu.grade = 99;
    } 

    // 赋值方式 2：直接使用 student
    function initstudent2() external{
        student.id = 22;
        student.grade = 100;
    }

    //赋值方式 3：构造函数方式
    function initStudent3() external{
        student = Student(15, 80);
    }

    //赋值方式 4：key value
    function initStudent4() external{
        student = Student({id:6,grade:60});
    }
}

contract LearnRefType{
    // 1. 这个区域的变量都是存在storage，不能指定位置
    // 2. storage类型变量也只能在这里声明，不能在其他任何位置声明
    uint256[] arr;
    // uint[] memory arr2;

    // 调用时传入: [1]
    function testArray(uint256[] memory a) public{
        require(a.length>0, "give me a non-empty array, tks!");

        arr = a; // 允许复制值到storage变量
        // a.push(1);  // memory中的数组不能修改长度
        a[0] = 1;
        arr[0] = 0;
        require(a[0] != arr[0]);

        // 创建arr的一个指针,通过指针修改数据
        uint[] storage arr2 = arr;
        arr2[0] = 3;
        require(arr2[0] == arr[0]);
        arr2.push(1);
        require(arr.length == 2);

        // 不允许复制Memory数据到storage指针，只能再创建一个storage变量
        // arr2 = a;
        // 不允许通过一个storage指针清空数组
        // delete arr2;
        // 重置一个元素为零值
        delete arr[0];
        require(arr[0] == 0);
        // 清空一个storage变量中的元素
        delete arr;
        require(arr.length == 0);
        // arr2[0]; // 删除arr后，其指针也不可再使用

        copyRef(arr2); // storage => storage
        copyValue(arr2); // storage => memory

        // 不能主动使用calldata区
        // uint[] calldata x = arr;

        // string和bytes必须标识位置
        // string s = "";
        // bytes b = "";
        string memory s1 = "";
        bytes memory b1 = "";
        require(bytes(s1).length == b1.length); // bytes和string都不支持直接比较
        require(keccak256(abi.encodePacked(bytes(s1))) == keccak256(abi.encodePacked(b1)));
    }

    function copyRef(uint[] storage x) internal  {
        require(x.length == 0);
        x.push(100);
    }
    function copyValue(uint[] memory x) internal pure {
        require(x[0] == 100);
    }

}
