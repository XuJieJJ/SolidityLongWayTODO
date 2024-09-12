// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.8.0/utils/Address.sol";

contract TestAddress {
    using Address for address;
    
    //isContract --account.code.length > 0;
    function _isContract(address account) public  view returns (bool){
        return  account.isContract();
    }

    function _sendValue(address payable recipient , uint256 amount)public {
        require(address(this).balance >= amount,"Address:insufficient balance");
        Address.sendValue(recipient , amount);
    }

    function _functionCall(address caller, bytes memory data) public  returns (bytes memory){
        return  caller.functionCall(data);
    }

    function _functionDelegateCall(address target , bytes memory data) public  returns (bytes memory){
        return Address.functionDelegateCall(target , data);
    }

}