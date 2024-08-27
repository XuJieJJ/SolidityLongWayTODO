// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC165 {

    /**
     * @dev 查询一个合约时候实现了一个接口
     *	param interfaceID  参数：接口ID
     *  return bool
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}