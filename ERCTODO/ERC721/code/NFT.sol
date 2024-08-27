// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";

contract NFT is ERC721 {
    uint256 public counters = 1;

    constructor()ERC721("NFT","NFT") {

    }
    function mint(address to )public {
        _mint(to, counters);
        counters++;
    }
}