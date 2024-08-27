// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Errors{
    /**
     * @dev 不合法的owner地址. 例如:address(0).
     * 用于查询balance时候调用.
     * param address -- owner.
     */
    error ERC721InvalidOwner(address owner);
    
    /**
     * @dev 表明 `tokenId`的`owner`为address(0).
     * param uint256 -- tokenId.
     */
    error ERC721NonexistentToken(uint256 tokenId);
    
    /**
     * @dev 表明 `tokenId`的`owner`为发生错误.
     * param (address,tokenId,address) -- (发送方，tokenId，NFTowner).
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    
    /**
     * @dev 表明`sender`发送token失败
     * param address 发生转账NFT的地址.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev 表明`receiver`接收token失败
     * param address 接收转账NFT的地址.
     */
    error ERC721InvalidReceiver(address receiver);
    
    /**
     * @dev `operater`未经授权`tokenId`，转账失败.
     * param (address uint256) -- (操作账户，`tokenId`)
     *
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev 表明授权账户`approver`不合法，.
     * param address -- 授权账户.
     */
    error ERC721InvalidApprover(address approver);
    
    /**
     * @dev 表明操作账户`operator`不合法，.
     * param address -- 操作账户.
     */
    error ERC721InvalidOperator(address operator);
    
}