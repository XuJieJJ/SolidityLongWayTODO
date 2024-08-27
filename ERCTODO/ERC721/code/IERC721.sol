// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

interface IERC721 {
    /**
     * @dev 释放条件：发生`tokenId`代币转移，从`from`转移至`to`.
     * param( address , address , uint256 )
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev 释放条件：发生`tokenId`代币授权,`owner`授权给`approved`支配token.
     * param( address , address , uint256 )
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev 释放条件：当`owner`管理`operator`的所有资产管理权限，即批量授权
     * param(address,address,bool)
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    /**
     * @dev 返回代币数量.
     * param address 账户地址
     * return uint256 代币数量
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev 查询`tokenId`的拥有者
     * 
     *  param uint256 tokenId
     *  return address 代币拥有者
     * 查询条件:
     * - `tokenId` 必须存在.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);
    
    /**
     * @dev 安全转账,将NFT的所有权从`from`转移至`to`.
     *
     * 转移条件:
     *
     * - `from` 不能是address(0).
     * - `to` 不能是address(0).
     * - `tokenId` 必须存在且属于`from`.
     * - 如果调用者不是`from`,则必须通过授权校验，拥有该`tokenId`的支配权.
     * - 如果`to`为合约地址，则必须实现{IERC721Receiver-onERC721Received}接口.
     *
     *释放 {Transfer} 事件.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    
    /**
     * @dev 功能参考 ``safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data)``
     *
     * 释放 {Transfer} 事件.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev 转移 `tokenId` 从 `from` 到 `to`.
     *
     * notice: 调用此方法需注意接收者有能力调配`ERC721`，否则可能会永久丢失，推荐使用`safeTransferFrom`，但这会增加一次外部调用，可能会导致重入，注意防范.
     *
     * 条件:参考`safeTransferFrom`
     *
     * 释放 {Transfer} 事件.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev 授权`to`账户支配调用者`msg.sender`的`tokenId`-`NFT`权限.
     * 当`token`发生转账时会清除授权.
     *
     * NFT只能授权给一个账户，当发生新的授权时候会更新授权账户.
     *
     * 条件:
     *
     * - 调用者必须为拥有该`NFT`或者被授权能够支配该`NFT`
     * - `tokenId` 必须存在.
     *
     * 释放 {Approval} 事件.
     */
    function approve(address to, uint256 tokenId) external;
    

    /**
     * @dev 批准或者移除`operator`账户对`msg.sender`账户所有NFT操作的权限
     * operator可以调用{transferFrom}或者{safeTransferFrom}转移token
     *
     * 条件:
     *
     * - `operator` 不能是address(0).
     *
     * 释放 {ApprovalForAll} 事件.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev 返回`tokenId`批准支配的账户.
     *
     * 条件:
     *
     * - `tokenId` 必须存在.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);
    
    /**
     * @dev 返回是否允许`operator`能够支配`owner`的所有NFT
     *
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}