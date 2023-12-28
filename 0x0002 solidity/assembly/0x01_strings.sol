// SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.0;

library strings{

    //切片结构体
    struct slice{
        uint _len; //长度
        uint _ptr; //指针
    }

    function memcpy(uint dest, uint src, uint length) private pure{

        for (; length >= 32; length -= 32){
            //引入内联汇编
            assembly{
                // mload()从内存中读取到栈，
                // mstore()将堆栈数据存储到内存
                mstore(dest,mload(src))  //dest为偏移变量，mload(src)为要存储的值
            }
            dest += 32;  // 加偏移量
            src += 32;   
        }

        uint mask = type(uint).max;
        if(length > 0){
            mask = 256 ** (32-length) - 1;
        }
        assembly{
            let srcpart := and(mload(src), not(mask)) //and()按位与；not()按位非，获取补码
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart)) //or()按位或
        }
    }

    function toSlice(string memory self) internal pure returns(slice memory){

    }
}