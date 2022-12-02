// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract myToken is ERC20 {
   constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        mint(msg.sender, 100 * 10**uint(decimals()));
    }

   function mint(address from,uint256 amount) public  returns(bool){
        ERC20._mint(from,amount);
        return true;
    }
}