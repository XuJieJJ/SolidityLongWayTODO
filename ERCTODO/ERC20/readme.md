### 1、ERC20标准规范

`ERC20`是以太坊上的代币标准，它实现了游戏代币转账的基本逻辑：

- 账户余额(balanceOf())
- 转账(transfer())
- 授权转账(transferFrom())
- 授权(approve())
- 代币总供给(totalSupply())
- 授权转账额度(allowance())
- 代币信息（可选）：名称(name())，代号(symbol())，小数位数(decimals())

### 2、编写ERC20函数接口

`IERC20`是`ERC20`代币标准的接口合约，规定了`ERC20`代币需要实现的函数和事件。
在接口函数中，只需要定义函数名称，输入参数，输出参数。我们将在接口实现合约当中完成接口的代码业务逻辑。

#### 2.1 定义ERC20事件

`IERC20`定义了`2`个事件：`Transfer`事件和`Approval`事件，分别在转账和授权时被释放

```solidity
/**
 * @dev 释放条件：当 `value` 单位的货币从账户 (`from`) 转账到另一账户 (`to`)时.
 * param (address , address , uint256)
 */
event Transfer(address indexed from, address indexed to, uint256 value);

/**
 * @dev 释放条件：当 `value` 单位的货币从账户 (`owner`) 授权给另一账户 (`spender`)时.
 * param (address , address , uint256)
 */
event Approval(address indexed owner, address indexed spender, uint256 value);
```

#### 2.2 定义函数接口

`IERC20`定义了`6`个函数，提供了转移代币的基本功能，并允许代币获得批准，以便其他链上第三方使用。

- `totalSupply()`

用于返回代币总供给

```solidity
/**
 * @dev 返回代币总供给.
 * param 
 * return uint256 代币总供给
 */
function totalSupply() external view returns (uint256);
```

- `balanceOf()`

用于返回账户余额

```solidity
/**
 * @dev 返回账户`account`所持有的代币数.
 * param address 账户地址 
 * return uint256 账户余额
 */
function balanceOf(address account) external view returns (uint256);
```

- `transfer()`

代币转账

```solidity
/**
 * @dev 转账 `amount` 单位代币，从调用者账户到另一账户 `to`.
 * param  (address,uint256) (接收地址，转账金额) 
 * return bool
 * 如果成功，返回 `true`.
 *
 * 释放 {Transfer} 事件.
 */
function transfer(address to, uint256 amount) external returns (bool);
```

- `allowance()`

返回授权额度

```solidity
/**
 * @dev 返回`owner`账户授权给`spender`账户的额度，默认为0。
 * param  (address  , address) (授权账户 ， 接收账户 )
 * return uint256 授权额度
 * 当{approve} 或 {transferFrom} 被调用时，`allowance`会改变.
 */
function allowance(address owner, address spender) external view returns (uint256);
```

- `approve()`

代币授权

```solidity
/**
 * @dev 调用者账户给`spender`账户授权 `amount`数量代币。
 * param  (address , uint256) (目标账户,授权额度)
 * return bool
 * 如果成功，返回 `true`.
 *
 * 释放 {Approval} 事件.
 */
function approve(address spender, uint256 amount) external returns (bool);
```

- `transferFrom()`

授权转账

```solidity
/**
 * @dev 通过授权机制，从`from`账户向`to`账户转账`amount`数量代币。转账的部分会从调用者的`allowance`中扣除。
 * param  (address , address , amount) (转账账户 , 目标账户，转账金额)
 * return bool
 * 如果成功，返回 `true`.
 *
 * 释放 {Transfer} 事件.
 */
function transferFrom(
    address from,
    address to,
    uint256 amount
) external returns (bool);
```

**完整代码如下：**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    /**
    * @dev 释放条件：当 `value` 单位的货币从账户 (`from`) 转账到另一账户 (`to`)时.
    * param (address , address , uint256)
    */
    event Transfer(address indexed from, address indexed to, uint256 value);

        /**
        * @dev 释放条件：当 `value` 单位的货币从账户 (`owner`) 授权给另一账户 (`spender`)时.
        * param (address , address , uint256)
        */
    event Approval(address indexed owner, address indexed spender, uint256 value);
        /**
        * @dev 返回代币总供给.
        * param 
        * return uint256 代币总供给
        */
    function totalSupply() external view returns (uint256);
    /**
    * @dev 返回账户`account`所持有的代币数.
    * param address 账户地址 
    * return uint256 账户余额
    */
    function balanceOf(address account) external view returns (uint256);

    /**
    * @dev 转账 `amount` 单位代币，从调用者账户到另一账户 `to`.
    * param  (address,uint256) (接收地址，转账金额) 
    * return bool
    * 如果成功，返回 `true`.
    *
    * 释放 {Transfer} 事件.
    */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
    * @dev 返回`owner`账户授权给`spender`账户的额度，默认为0。
    * param  (address  , address) (授权账户 ， 接收账户 )
    * return uint256 授权额度
    * 当{approve} 或 {transferFrom} 被调用时，`allowance`会改变.
    */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
    * @dev 调用者账户给`spender`账户授权 `amount`数量代币。
    * param  (address , uint256) (目标账户,授权额度)
    * return bool
    * 如果成功，返回 `true`.
    *
    * 释放 {Approval} 事件.
    */
    function approve(address spender, uint256 amount) external returns (bool);
    /**
    * @dev 通过授权机制，从`from`账户向`to`账户转账`amount`数量代币。转账的部分会从调用者的`allowance`中扣除。
    * param  (address , address , amount) (转账账户 , 目标账户，转账金额)
    * return bool
    * 如果成功，返回 `true`.
    *
    * 释放 {Transfer} 事件.
    */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
```

### 3、编写IERC20错误接口

`IERC20Errors`定义了6个错误，帮助我们在实现代码业务逻辑时捕获错误异常

- `ERC20InsufficientBalance`错误

在转账错误时候触发，表明发送方余额不足

```solidity
 	/**
     * @dev 表示与 “发送方 ”当前 “余额 ”有关的错误。用于转账
     * param (address , uint256,uint256) (转账账户 ， 账户余额 ，转账金额)
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
```

- `ERC20InvalidSender`错误

在转账错误时候触发，多用于零地址发送转账，即发送方为零地址

```solidity
    /**
     * @dev 表示代币 “发送 ”失败。用于转账。
     * param (address) (转账地址)
     */
    error ERC20InvalidSender(address sender);
```

- `ERC20InvalidReceiver`错误

在转账错误时候触发，多于与向零地址发送转账。即接收方为零地址

```solidity
    /**
     * @dev 表示代币 “接收 ”失败。用于转账
     * param (address) (接收地址)
     */
    error ERC20InvalidReceiver(address receiver);
```

- `ERC20InsufficientAllowance`错误

多用于检查授权额度时候触发，表明支出人spender的可支配额度不足以消耗此次转账

```solidity
    /**
     * @dev 表示 “spender ”的 “allowance ”失败。用于转账.
     * param (address , uint256 , uint256) (支出人，授权额度,转账金额)
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
```

- `ERC20InvalidApprover`错误

在授权的时候触发，多用于零地址向其他账户授权token

```solidity
    /**
     * @dev 表示授权token的 `approver` 失败。用于approve
     * param (address) (授权账户)
     */
    error ERC20InvalidApprover(address approver);
```

- `ERC20InvalidSpender`错误

在授权的时候触发，多用于向零地址授权token

```solidity
    /**
     * @dev 表示授权token的 `spender` 失败。用于approve。
     * param (address) (支出账户)
     */
    error ERC20InvalidSpender(address spender);
```

**完整代码如下：**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Error {
    /**
     * @dev 表示与 “发送方 ”当前 “余额 ”有关的错误。用于转账
     * param (address , uint256,uint256) (转账账户 ， 账户余额 ，转账金额)
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    /**
     * @dev 表示代币 “发送 ”失败。用于转账。
     * param (address) (转账地址)
     */
    error ERC20InvalidSender(address sender);
    /**
     * @dev 表示代币 “接收 ”失败。用于转账
     * param (address) (接收地址)
     */
    error ERC20InvalidReceiver(address receiver);
    /**
     * @dev 表示 “spender ”的 “allowance ”失败。用于转账.
     * param (address , uint256 , uint256) (支出人，授权额度,转账金额)
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    /**
     * @dev 表示授权token的 `approver` 失败。用于approve
     * param (address) (授权账户)
     */
    error ERC20InvalidApprover(address approver);

        /**
     * @dev 表示授权token的 `spender` 失败。用于approve。
     * param (address) (支出账户)
     */
    error ERC20InvalidSpender(address spender);
}
```

### 4、实现ERC20

现在我们写一个`ERC20`，将`IERC20`规定的函数实现。

#### 4.1 状态变量

我们需要状态变量来记录账户余额，授权额度和代币信息。其中`balanceOf`, `allowance`和`totalSupply`为`public`类型，会自动生成一个同名`getter`函数，实现`IERC20`规定的`balanceOf()`, `allowance()`和`totalSupply()`。而`name`, `symbol`, `decimals`则对应代币的名称，代号和小数位数。

**注意**：用`override`修饰`public`变量，会重写继承自父合约的与变量同名的`getter`函数，比如`IERC20`中的`balanceOf()`函数。

```solidity
mapping(address => uint256) public override balanceOf;

mapping(address => mapping(address => uint256)) public override allowance;

uint256 public override totalSupply;   // 代币总供给

string public name;   // 名称
string public symbol;  // 代号

uint8 public decimals = 18; // 小数位数
```

#### 4.2 函数

- 构造函数：初始化代币名称、代号。

```solidity
constructor(string memory name_, string memory symbol_){
    name = name_;
    symbol = symbol_;
}

```

- `update()`函数：在转账时候更新代币状态变量

 从 `from` 到 `to` 转移 `value` 数量的代币，或者，如果 `from`（或 `to` 是零地址），则进行mint（或burn）。或 `to`）为零地址时，则可使用mint（或burn）。

```solidity
function _update(address from , address to , uint256 value) internal {
        if (from == address(0)){
            //from 为零地址 代表代币新铸造 非用户之间转账
            //溢出检查 
            totalSupply += value;
        }else {
            uint256 fromBalance = balanceOf[from];
            if (fromBalance < value){
                //发送方余额小于转账金额 触发ERC20InsufficientBalance错误
                revert ERC20InsufficientBalance(from,fromBalance,value);
            }
            //溢出已检查 发送方余额足够 使用unchecked节省gas费
            unchecked{
                balanceOf[from] = fromBalance - value;
            }
        }
        if (to == address(0)){
            //溢出已在from代码校验检查
            unchecked{
                totalSupply -= value;
            }
        }else {

            unchecked{
                balanceOf[to] += value;
            }
        }
        //触发转账事件
        emit Transfer(from, to, value);
    }
    
```

- `_mint()`函数：铸造代币

```solidity
function _mint(address account , uint256 value)internal {
        //地址检查 mint铸造接收方不应该是零地址 捕获错误ERC20InvalidReceiver()
        if (account == address(0)){
            revert ERC20InvalidReceiver(address(0));
        }
        //mint也可视作代币之间的转账 由零地址向接收方转账，所以底层调用update()更新代币状态
        _update(address(0), account, value);
    }
    
```

- `_burn()`函数：销毁代币

```solidity
function _burn(address account , uint256 value)internal {
        //地址检查 burn销毁发送方不应是零地址 捕获错误ERC20InvalidSender()
        if (account == address(0)){
            revert ERC20InvalidSender(account);
        }
        //burn也可视作代币之间的转账，由发送方向零地址转账，代币进入黑洞，底层调用_update()更新代币状态
        _update(account, address(0), value);
    }
    
```

- `_transfer()`函数：底层转账函数

```solidity
function _transfer(address from , address to , uint256 value) internal {
        //transfer底层逻辑，地址校验
        if ( from == address(0)){
            revert ERC20InvalidSender(address(0));
        }
        if (to == address (0)){
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }
    
```

- `_approve()`函数：底层授权函数

授权函数即更改授权其他用户可供支配自己账户余额的额度

```solidity
    function _approve(address owner , address spender , uint256 value , bool emitEvent)internal  {
        //地址校验
        if (owner == address(0)){
             revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)){
            revert ERC20InvalidSpender(address(0));
        }
        allowance[owner][spender] = value;
        //判断是否需要释放授权事件
        if (emitEvent){
            emit Approval(owner, spender, value);
        }
        
```

**注意：**如果是spender在消耗owner的余额，是不用释放授权事件的，所以在这里引入`emitEvent`参数区分不同场景。

- `_spendAllowance()`函数：消耗授权额度

```solidity
    function _spendAllowance(address owner , address spender , uint256 value)internal {
        //获取当前授权额度
        uint256 currentAllowance = allowance[owner][spender];
        if (currentAllowance != type(uint256).max){
            //额度校验 捕获ERC20InsufficientAllowance异常
            if (currentAllowance < value){
                revert ERC20InsufficientAllowance(spender , currentAllowance , value);
            }
            //更新授权额度 不用释放授权事件
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
    
```

- `transferFrom()`函数：`spender`转账`owner`代币

```solidity
function transferFrom(address from , address to , uint256 amount)public returns(bool){
        address spender = msg.sender;
        //更新授权额度
        _spendAllowance(from, spender, amount);
        //执行转账逻辑
        _transfer(from, to, amount);
        return  true;
    }
    
```

- `transfer()`函数：`owner`转账代币

```solidity
    function transfer(address to , uint256 amount) public   returns (bool){
        address owner = msg.sender;
        //执行转账逻辑
        _transfer(owner, to, amount);
        return  true;
    }
    
```

- `approve()`函数：`owner`授权`spender`代币

```solidity
    function approve(address spender , uint256 value) public  returns (bool){
        address owner = msg.sender;
        //执行授权逻辑
        _approve(owner, spender, value, true);
        return  true;
    }
```

**完整代码如下：**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Error.sol";

contract ERC20 is IERC20 , IERC20Error{
    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply;   // 代币总供给

    string public name;   // 名称
    string public symbol;  // 代号

    uint8 public decimals = 18; // 小数位数

        constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    } 
    /**
    * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
    *(or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
    * this function.
    *
    * Emits a {Transfer} event.
    */
    function _update(address from , address to , uint256 value) internal {
        if (from == address(0)){
            //from 为零地址 代表代币新铸造 非用户之间转账
            //溢出检查 
            totalSupply += value;
        }else {
            uint256 fromBalance = balanceOf[from];
            if (fromBalance < value){
                //发送方余额小于转账金额 触发ERC20InsufficientBalance错误
                revert ERC20InsufficientBalance(from,fromBalance,value);
            }
            //溢出已检查 发送方余额足够 使用unchecked节省gas费
            unchecked{
                balanceOf[from] = fromBalance - value;
            }
        }
        if (to == address(0)){
            //溢出已在from代码校验检查
            unchecked{
                totalSupply -= value;
            }
        }else {

            unchecked{
                balanceOf[to] += value;
            }
        }
        //触发转账事件
        emit Transfer(from, to, value);
    }
    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account , uint256 value)internal {
        //地址检查 mint铸造接收方不应是零地址 捕获错误ERC20InvalidReceiver()
        if (account == address(0)){
            revert ERC20InvalidReceiver(address(0));
        }
        //mint可视作代币之间的转账 由零地址向接收方转账，所以底层调用_update()更新代币状态
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */

    function _burn(address account , uint256 value)internal {
        //地址检查 burn销毁发送方不应是零地址 捕获错误ERC20InvalidSender()
        if (account == address(0)){
            revert ERC20InvalidSender(account);
        }
        //burn也可视作代币之间的转账，由发送方向零地址转账，代币进入黑洞，底层调用_update()更新代币状态
        _update(account, address(0), value);
    }
     /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from , address to , uint256 value) internal {
        //transfer底层逻辑，地址校验
        if ( from == address(0)){
            revert ERC20InvalidSender(address(0));
        }
        if (to == address (0)){
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }
    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner , address spender , uint256 value , bool emitEvent)internal  {
        //地址校验
        if (owner == address(0)){
             revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)){
            revert ERC20InvalidSpender(address(0));
        }
        allowance[owner][spender] = value;
        //判断是否需要释放授权事件
        if (emitEvent){
            emit Approval(owner, spender, value);
        }
    }
     /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner , address spender , uint256 value)internal {
        //获取当前授权额度
        uint256 currentAllowance = allowance[owner][spender];
        if (currentAllowance != type(uint256).max){
            //额度校验 捕获ERC20InsufficientAllowance异常
            if (currentAllowance < value){
                revert ERC20InsufficientAllowance(spender , currentAllowance , value);
            }
            //更新授权额度 不用释放授权事件
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from , address to , uint256 amount)public returns(bool){
        address spender = msg.sender;
        //更新授权额度
        _spendAllowance(from, spender, amount);
        //执行转账逻辑
        _transfer(from, to, amount);
        return  true;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to , uint256 amount) public   returns (bool){
        address owner = msg.sender;
        //执行转账逻辑
        _transfer(owner, to, amount);
        return  true;
    }

     /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender , uint256 value) public  returns (bool){
        address owner = msg.sender;
        //执行授权逻辑
        _approve(owner, spender, value, true);
        return  true;
    }
}
```

### 5、发行代币合约

新建`Token.sol`文件，继承`ERC20`合约

```solidity
contract Token is ERC20 {

    address private  _owner ; 

    constructor(address owner_,string memory name_, string memory symbol_)ERC20(name_,symbol_){
        _owner = owner_;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }
    function mint(address to , uint256 amount)public  onlyOwner{
        _mint(to, amount);
    }
    function burn(address to , uint256 amount) public  onlyOwner{
        _burn(to, amount);
    }
}
```

### 6、合约部署与测试

#### 6.1部署合约

部署合约，填写构造函数参数，完成合约`owner`、`name`、`symbol`参数的实例化

![image-20240821162932977](.\img\image-20240821162932977.png)

可以看到部署的合约地址具有以下`ERC20`标准规范的方法

![image-20240821163151347](.\img\image-20240821163151347.png)

#### 6.2测试合约

1)状态变量检查

![image-20240821163245568](.\img\image-20240821163245568.png)

2）`mint()`函数，使用`owner`账户给地址一：`0x5B38Da6a701c568545dCfcB03FcB875f56beddC4`铸造100代币

![image-20240821163513967](.\img\image-20240821163513967.png)

3）`balanceOf()`函数，检查`0x5B38Da6a701c568545dCfcB03FcB875f56beddC4`账户代币余额

![image-20240821163805716](.\img\image-20240821163805716.png)

4）`approve()`函数，使用`0x5B38Da6a701c568545dCfcB03FcB875f56beddC4`授权`0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2`账户50代币

![image-20240821163944435](.\img\image-20240821163944435.png)

5）`transferFrom()`函数，使用`0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2`调用`transferFrom()`函数转账`0x5B38Da6a701c568545dCfcB03FcB875f56beddC4`账户50代币给自己

![image-20240821164226928](.\img\image-20240821164226928.png)

其他函数调用可根据自己需求选择测试

