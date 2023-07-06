// SPDX-License-Identifier: MIT
pragma solidity >0.8.16;
interface IERC20 {
    event Transfer(address indexed from,address indexed  to, uint value);
    event Approval(address indexed  owner,address indexed  spender,uint value);


    function name()external  view returns(string memory);
    function symbol()external view returns (string memory);
    function decimal()external  view returns (uint8);

    function totalSupply()external view returns (uint);
    function balanceOf(address onwer) external  view returns (uint);
    function allowance(address owner,address spender)external  view  returns (uint);


    function approve(address spender,uint value)external returns (bool);
    function transfer(address to,uint value)external returns (bool);
    function transferFrom(address from,address to,uint value)external returns (bool);
    
}