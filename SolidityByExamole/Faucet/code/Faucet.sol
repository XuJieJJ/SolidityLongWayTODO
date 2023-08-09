// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol"; 
contract ERC20 is IERC20 {
        mapping  (address => uint256) public override balanceOf;
        mapping (address=>mapping (address => uint256)) public  override allowance;
        
        uint256 public  override totalSupply;

        string public name;
        string public symbol;

        uint8 public decimals = 18;
        constructor(string memory _name,string memory _symbol){
                name = _name;
                symbol = _symbol;
        }
        
        function transfer(address to,uint amount)external override returns (bool){
                require(amount >0&&balanceOf[msg.sender]>=amount,"amount not enough");
                balanceOf[msg.sender]-=amount;
                balanceOf[to] += amount;
                emit Transfer(msg.sender, to, amount);
                return true;
        }
        function approve(address spender,uint amount)external override returns (bool){
                allowance[msg.sender][spender] = amount;
                emit Approval(msg.sender,spender,amount);
                return  true;
        }
        function transferFrom(address from,address to,uint amount)external  override returns (bool){
                allowance[from][msg.sender] -= amount;
                balanceOf[from] -=amount;
                balanceOf[to]+=amount;
                emit  Transfer(from, to, amount);
                return true;
        }

        function mint(uint amount)external {
                balanceOf[msg.sender] +=amount;
                totalSupply +=amount;
                emit Transfer(address(0), msg.sender, amount);
        }

        function burn(uint amount)external {
                balanceOf[msg.sender]-=amount;
                totalSupply -=amount;
                emit Transfer(msg.sender, address(0), amount);
        }
}

//ERC20代币的水龙头合约
contract Faucet{
        uint256 public  amountAllowed =100;//每次领100
        address public  tokenContract;//token的合约地址
        mapping(address => bool) public  requestAddress;//记录已经领取过的地址

        event SendToken(address indexed receiver,uint indexed  amount);
        constructor(address _tokenContract) {
                tokenContract = _tokenContract;
        }
        

        //faucet
        function faucet()external {
                require(!requestAddress[msg.sender],"only request 1 time");
                IERC20 token = IERC20(tokenContract);//创建IERC20合约对象
                require(token.balanceOf(address(this))>amountAllowed,"faucet empty");

                token.transfer(msg.sender, amountAllowed);
                requestAddress[msg.sender]=true;
                emit SendToken(msg.sender, amountAllowed);
        }
}