// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@5.0.0/utils/Create2.sol";

contract Target {
    address public _owner ;
    constructor(address owner){
        _owner = owner;
    }
}

contract Factory {

    function deploy1() public  returns (address){
        return  address(new Target {salt : keccak256("msg.sender")}(msg.sender));
    } 
    function deploy2()public returns (address addr){
        bytes memory bytecode = abi.encodePacked(type(Target).creationCode  , abi.encode(msg.sender));
        bytes32 salt =  keccak256("msg.sender");
        assembly {
            addr := create2(
                0,
                add(bytecode,32),
                mload(bytecode),
                salt
            )
        }
    }

    function computeAddress()public  view returns (address){
        bytes32  bytecode = keccak256(abi.encodePacked(type(Target).creationCode  , abi.encode(msg.sender)));
        bytes32 salt =  keccak256("msg.sender");
        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            bytecode
        )))));
    }
}

contract TestCreate2 {
    uint256 public _nonce;

    function getSalt() public returns (bytes32 salt) {
            _nonce++;
            salt =_getSalt(_nonce , msg.sender);
    }
    function getSalt(uint256 nonce)public view   returns (bytes32 salt){
        salt = _getSalt(nonce , msg.sender);
    }
    //计算salt
    function _getSalt(uint256 nonce,address account )internal pure returns (bytes32 salt){
            salt = keccak256(abi.encodePacked(nonce , account));
    }

    function getBytecode(address owner)public pure returns (bytes memory){
        return  abi.encodePacked( type(Target).creationCode , abi.encode(owner));
    }
    function getBytecodeHash(address owner)public pure returns (bytes32){
        
        return keccak256(getBytecode(owner));
    }
    //deploy(uint256 amount, bytes32 salt, bytes memory bytecode) 
    function _deploy(uint256 amount)public  returns (address addr){
        addr =  Create2.deploy(amount,getSalt(),getBytecode(msg.sender));
    }

    //computeAddress(bytes32 salt, bytes32 bytecodeHash) 提前计算地址
    function _computeAddress(bytes32 salt, bytes32 bytecodeHash)public view returns(address addr){
        addr = Create2.computeAddress(salt,bytecodeHash);
    }
}