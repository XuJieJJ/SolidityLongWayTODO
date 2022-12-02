// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
interface  IERC20 {
    //option_function
    function name() external view returns( string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    
    //required function 
    function  totalSupply()external view returns(uint256);
    function  balanceOf(address _address) external view returns(uint256);
    function  transfer(address to,uint256 _value)external returns(bool success);
    function transferFrom(address from,address to,uint256 amount)external returns(bool);
    function approval(address _spender,uint256 value)external returns(bool suceess);
    function allowance(address _owner,address _spender) external view returns(uint256);
    
    // events
    event Transfer(address from,address to,uint256 value);
    event Approval(address owner,address _spender,uint256 value);

}