// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Test {
    uint public  _mark;
    address public  _caller;

    function call()public {
        _mark++;
        _caller = msg.sender;
    }
}