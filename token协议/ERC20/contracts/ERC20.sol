// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./IERC20.sol";
contract ERC20 is IERC20{
 uint public override totalSupply;
 mapping(address => uint256) public override balanceOf;
 mapping(address => mapping(address=>uint256))public override allowance;
 string public override  name = 'eth';
 string public override symbol ="weth";
 uint8 public  override decimals=18;

 function approval(address _spender,uint256 amount) external override returns(bool){
    allowance[msg.sender][_spender]+=amount;
    emit  Approval(msg.sender,_spender, amount);
    return true;
 }
 function transfer(address to,uint256 value) external override returns(bool){
        balanceOf[to]+=value;
        balanceOf[msg.sender]-=value;
        emit Transfer(msg.sender, to, value);
        return true;
 }
 function transferFrom(address from,address to,uint256 value)external override returns(bool){
        allowance[from][msg.sender]-=value;
        balanceOf[from]-=value;
        balanceOf[to]+=value;
        emit Transfer(from, to, value);
        return true;
 }

 function mint(uint amount)external {
        balanceOf[msg.sender]+=amount;
        totalSupply+=amount;
        emit Transfer(address(0), msg.sender, amount);
}
function burn(uint256 amount)external{
    balanceOf[msg.sender]-=amount;
    totalSupply-=amount;
    emit Transfer(msg.sender,address(0), amount);
}
}