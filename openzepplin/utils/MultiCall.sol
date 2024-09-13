// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@5.0.0/utils/Multicall.sol";
contract Caller {

    
    struct   Calldata{
        address _target;
        bytes _data;
    }
    Calldata public  _calldata;
    function call(Calldata[] memory calldatas)public {
        for(uint i =0 ; i < calldatas.length; ){
            (bool success,) = calldatas[i]._target.call(calldatas[i]._data);
            require(success , "call error");
            unchecked{++i;}
        }
    }
}

contract Target {
    string public  _mark1;
    string public  _mark2;
    //[0x15998874,0xe236188c]
    function call1()public  {
        _mark1 = "call1";
    }
    function call2()public  {
        _mark2 = "call2";
    }
}

contract MultiCall is Multicall {
    uint256 public  _number ;
    //["0x4f2be91f","0xc54124be"]
    function add()public {
        _number +=2;
    }
    function sub()public {
        _number -=1;
    }

}