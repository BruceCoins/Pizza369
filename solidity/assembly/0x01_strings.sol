// SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.0;

library strings{
    struct slice{
        uint _len; //长度
        uint _ptr; //指针
    }

    function memcpy(uint dest, uint src, uint length) private pure{

        for (; length >= 32; length -= 32){
            //引入内联汇编
            assembly{
                // mload()从内存中读取，
                // mstore()用读取出的数据替换dest
                mstore(dest,mload(src))
            }
            dest += 32;  // 加偏移量
            src += 32;   
        }
    }
}