// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
interface IUniswapV2ERC20 {
    event Approval(address indexed  owner,address indexed spender,uint value);
    event Transfer(address indexed from,address indexed to,uint value);
    
    function name()external view  returns (string memory);
    function symbol()external  view  returns (string memory);
    function decimal()external  view returns (uint8);
    function totalSupply()external  view  returns (uint);
    function balanceOf(address owner)external view  returns (uint);
    function allowance(address owner)external view  returns (uint);

    function approval(address spender,uint value)external returns (bool);
    function transfer(address to,uint value)external returns (bool);
    function transferFrom(address from,address to, uint value)external returns (bool);

    //DOMAIN_SEPARATOR 用于不同DAPP之间区分相同结构和内容的签名消息，有助于用户辨别哪些为可信任的DAPP
    function DOMAIN_SEPARATOR()external view returns (bytes32);
    //PERMIT_TYPEHASH用于keccak256方法的参数
    function PERMIT_TYPEHASH()external pure returns (bytes32);
    //记录合约中每个地址使用链下签名消息签名的交易数量，防止重放攻击
    function nonces(address owner) external  view returns (uint);

    //permit授权某个合约在截至时间之前花掉一定数量的代币，实现用户验证与授权
    function permit(address owner,address spender,uint value,uint deadline,uint8 v,bytes32 r,bytes32 s)external ;


    }