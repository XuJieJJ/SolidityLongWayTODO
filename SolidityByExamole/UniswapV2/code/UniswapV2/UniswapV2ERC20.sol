// SPDX-License-Identifier: MIT
pragma solidity =0.5.16;
import './interface/IUniswapV2ERC20.sol';
import './libraries/SafeMath.sol';
contract  UniswapV2ERC20 is  IUniswapV2ERC20{
    using SafeMath for uint;
    string public   constant name= "Uniswap V2";
    string public constant symbol = "UNI-V2";
    uint8 public constant decimal= 18;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint))public allowance;

    bytes32 public DOAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH=0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping (address => uint ) public nonces;

    event Approval(address indexed owner,address indexed spender,uint value);
    event Transfer(address indexed from,address indexed to ,uint value);
    constructor()public{
        uint chainId;
        
    }
    


}