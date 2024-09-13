// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;
import "@openzeppelin/contracts@5.0.0/utils/Strings.sol";


contract TestStrings {
    using Strings for *;



    //toString(uint256 value)
    function TestToString(uint256 value)public pure returns (string memory){
        return value.toString();
    }

    //toHexString(uint256 value) 
    function TestToHexString(uint256 value)public  pure returns (string memory){
        return value.toHexString();
    }

    //toHexString(address addr)
    function TestToHexString(address addr)public  pure  returns (string memory){
        return  addr.toHexString();
    }

    //equal(string memory a, string memory b) 
    function TestEqual(string memory a , string memory b ) public  pure returns (bool){
        return  a.equal(b);
    }

}