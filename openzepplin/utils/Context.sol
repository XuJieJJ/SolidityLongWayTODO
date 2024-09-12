// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@5.0.0/utils/Context.sol";

contract TestContext is Context{
    //_msgSender
    function msgSender()public  view  returns (address){
        return  _msgSender();
    }
    //_msgData
    function msgData()public view  returns (bytes calldata){
        return  _msgData();
    }
}