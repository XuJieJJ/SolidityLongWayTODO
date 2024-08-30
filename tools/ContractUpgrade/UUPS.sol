// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//通用可升级代理
contract UUPSProxy {
    string public  _mark;
    address public  _implementation;
    address public  _admin;
    bytes4 public  _selector = bytes4(keccak256("upgrade(address)"));
    constructor(address implementation_){
        _implementation = implementation_;
        _admin = msg.sender;
    }
    fallback() external payable { 
        (bool success,) = _implementation.delegatecall(msg.data);
        require( success,"ERRO");
    }
    receive() external payable { }

    function getCalldata(address addr)external pure returns (bytes memory){
        return abi.encodeWithSelector(bytes4(keccak256("upgrade(address)")), addr);
    }
}

contract UUPSProxiable1 {
    string public  _mark;
    address public  _implementation;
    address public  _admin;
    constructor(){
        _admin   = msg.sender;
    }

    function upgrade(address newImplementation) external  {
        require(msg.sender == _admin,"");
        _implementation = newImplementation;
    }
    //0x28b5e32b
    function call()external {
        _mark = "UUPSProxiable1";
    }
}
contract UUPSProxiable2 {
    string public  _mark;
    address public  _implementation;
    address public  _admin;
    constructor(){
        _admin   = msg.sender;
    }

    function upgrade(address newImplementation) external  {
        require(msg.sender == _admin,"");
        _implementation = newImplementation;
    }

    function call()external {
        _mark = "UUPSProxiable2";
    }
}
