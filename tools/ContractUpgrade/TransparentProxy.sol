// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//透明代理

contract Proxy{
    string public  _mark;
    address public  _owner;
    address public  _implementation;

    constructor(address implementation_ , address owner_){
        _implementation = implementation_;
        _owner = owner_;
    }
    fallback() external payable {
        require(msg.sender != _owner);
        (bool success ,) =_implementation.delegatecall(msg.data);
        require(success,"call error");
     }
     receive() external payable { }

     function upgrade(address implementation) external {
        if (msg.sender != _owner) revert();

        _implementation = implementation;
     }
}


contract Logic1 {
    string public  _mark;

    //0x28b5e32b
    function call()public {
        _mark = "logic1";

    }
}

contract Logic2 {
    string public  _mark;

    address public  _implementation;

    function call()public {
        _mark = "logic2";

    }
}

