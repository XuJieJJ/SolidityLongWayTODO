// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Receiver {
    /**
     * @dev 当发送想合约转账NFT时，回调此函数
     *
     * @notice 返回其函数选择器，以确认token转账.
     * @notice 返回其他值，或者接收合约未实现该接口，转账将被revert.
     *
     * 函数选择器可通过`IERC721Receiver.onERC721Received.selector`获得.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}