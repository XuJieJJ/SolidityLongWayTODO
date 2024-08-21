// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Token is ERC20 {

    address private  _owner ; 

    constructor(address owner_,string memory name_, string memory symbol_)ERC20(name_,symbol_){
        _owner = owner_;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }
    function mint(address to , uint256 amount)public  onlyOwner{
        _mint(to, amount);
    }
    function burn(address to , uint256 amount) public  onlyOwner{
        _burn(to, amount);
    }
}