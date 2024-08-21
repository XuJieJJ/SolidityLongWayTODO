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