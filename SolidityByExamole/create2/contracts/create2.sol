// SPDX-License-Identifier: MIT
pragma solidity >0.8.16;
contract create2{
    uint public  x ;
    constructor(uint _x){
        x=_x;
    }


}

contract testCreate2{
    bytes32 public  salt = keccak256(abi.encode(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4));
    function create2BySalt(bytes32 salt,uint args) public {
       address predicted = address(uint160(uint(keccak256(abi.encodePacked(
        bytes1(0xff),
        address(this),
        salt,
        keccak256(abi.encodePacked(type(create2).creationCode,abi.encode(args)))   
       )))));
       create2 d = new create2{salt:salt}(args);
       require(predicted==address(d),"create success");

    }
}