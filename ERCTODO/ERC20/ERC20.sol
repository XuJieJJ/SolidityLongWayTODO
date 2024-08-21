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