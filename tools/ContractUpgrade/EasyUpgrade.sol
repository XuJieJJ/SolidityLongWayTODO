// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//简单可升级合约
contract Proxy {
    string public  _mark;

    address public  _implementation;

    constructor(address implementation_) {
        _implementation = implementation_;
    }

    fallback() external payable {
        (bool success ,) =_implementation.delegatecall(msg.data);
        require(success,"call error");
     }

     receive() external payable { } 

     function upgrade(address implementation)public {
        _implementation = implementation;
     }


}

contract Logic1{
    string public  _mark;

    //0x28b5e32b
    function call()public {
        _mark = "Logic1";

    }
}
contract Logic2{
    string public  _mark;

    function call()public {
        _mark = "Logic2";

    }
}