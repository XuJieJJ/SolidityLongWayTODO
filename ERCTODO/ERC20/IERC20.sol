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