// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SelectorAndabiData {

    function hello(string memory data)public pure  returns (bytes memory){
        return msg.data;
    }

    function getSelectorBySelector()public  pure returns (bytes4){
        return  this.hello.selector;
    }

    function getSelectorByKeccak()public  pure  returns (bytes4){
        return bytes4(keccak256("hello(string)"));
    }
    function getAbiData(string memory data)public  pure  returns (bytes memory){
        return abi.encodeWithSelector(bytes4(keccak256("hello(string)")), data);
    }

}


contract caller {
    string public  _caller;//调用者
    address  public  _address;//作用域地址
    address public  _msgSender;//msg.sender

    function call(address contractAddress) public  {
        contractAddress.call(abi.encodeWithSelector(bytes4(keccak256("caller()"))));
    }
    function delegatecall(address contractAddress) public  {
        contractAddress.delegatecall(abi.encodeWithSelector(bytes4(keccak256("caller()"))));
    }
}

contract called1{
    string public  _caller;
    address  public  _address;
    address public  _msgSender;
    function caller()public {
        _caller ="called1";
        _address = address(this);
        _msgSender = msg.sender;
    }
}

contract called2 {
    string public  _caller;
    address  public  _address;
    address public  _msgSender;
    function caller()public {
        _caller ="called2";
        _address = address(this);
        _msgSender = msg.sender;
    }
}