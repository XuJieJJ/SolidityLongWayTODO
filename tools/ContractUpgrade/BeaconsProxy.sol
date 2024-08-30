// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//信标代理
contract Proxy {
    Beacon immutable _beacon;

    fallback() external payable { 
        address implementation = _beacon.implementation();
        implementation.delegatecall(msg.data);
    }
}

contract Beacon {
    address public  _implementation;

    function implementation()public  view returns (address){
        return _implementation;
    }
    function upgrade(address newImplementation) public {
        _implementation = newImplementation;
    }
}

contract Logic {

    function call()external {
        //TODO
    }
}