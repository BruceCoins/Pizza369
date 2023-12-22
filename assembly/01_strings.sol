// SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.0;

library strings{
    struct slice{
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint length) private pure{

        for (; length >= 32; length -= 32){
            assembly{
                mstore(dest,mload(src))
            }
            dest += 32;
            src += 32;
        }
    }
}