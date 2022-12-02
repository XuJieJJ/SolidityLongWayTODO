# ERC20

## 1标准接口

```solidity
	//option_function
    function name() external view returns( string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    
    //required function 
    function  totalSupply()external view returns(uint256);
    function  balanceOf(address _address) external view returns(uint256);
    function  transfer(address to,uint256 _value)external returns(bool success);
    function  transferFrom(address from,address to,uint256 amount)external returns(bool);
    function  approval(address _spender,uint256 value)external returns(bool suceess);
    function  allowance(address _owner,address _spender) external view returns(uint256);
    
    // events
    event Transfer(address from,address to,uint256 value);
    event Approval(address owner,address _spender,uint256 value);
```

## 2分析 

### 	2.1option_function

​			包含name symbol decimal（名字、形式、精度）

### 	2.2六个required功能

​		totalSupply 铸币总额

​		balanceOf  账户余额

​		allowance 授权总额度

​		transfer函数 只包含接收者和value

​		approval授权函数 对特定账户授权代币发授权等 spender指帮忙花费的人

​		transferFrom  将某一账户的币转给另一账户 

![image-20221202220501647](E:\Github\ReLearnSolidity\token协议\ERC20\img\image-20221202220501647.png)

![image-20221202220841349](E:\Github\ReLearnSolidity\token协议\ERC20\img\image-20221202220841349.png)



### 	2.3两个事件

​		Transfer(from,to,amount)转账时触发

​		Approval(owner.spender,amount)授权时触发

## 3ERC20案例

```solidity
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
```

增加mint和burn函数

mint: 进行铸币

![image-20221202220323388](E:\Github\ReLearnSolidity\token协议\ERC20\img\image-20221202220323388.png)

burn 销毁代币

![image-20221202220408577](E:\Github\ReLearnSolidity\token协议\ERC20\img\image-20221202220408577.png)

## 4使用openzeppelin进行创建自己的token

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract myToken is ERC20 {
   constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        mint(msg.sender, 100 * 10**uint(decimals()));
    }

   function mint(address from,uint256 amount) public  returns(bool){
        ERC20._mint(from,amount);
        return true;
    }
}
```

