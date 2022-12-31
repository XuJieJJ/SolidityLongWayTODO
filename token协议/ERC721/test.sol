// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC721.sol";
contract test is ERC721{
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    }
    function _Mint(address account,uint256 amount) external{
            _mint(account,amount);
    }
    function _Burn(uint256 tokenID)external{
        _burn(tokenID);
    }
}