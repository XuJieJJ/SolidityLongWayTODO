// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
/**
 * @title ERC-721 元数据扩展接口
 * @dev 见 https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev 查询代币名称.
     */
    function name() external view returns (string memory);

    /**
     * @dev 查询代币代号符号.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev 查询NFT的URI元数据
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}