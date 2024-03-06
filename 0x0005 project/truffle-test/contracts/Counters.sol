//SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.9.0;

contract Counters {
    uint counters;

    constructor(){
        counters = 0;
    }

    function add() public{
        counters = counters + 1;
    }

    function get() public view returns(uint) {
        return counters;
    }
}