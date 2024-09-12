// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;


import "@openzeppelin/contracts@5.0.0/utils/Base64.sol";

contract TestBase64 {
    using Base64 for bytes;


    /**
    * @dev 将 `bytes` 转换为 Bytes64 `string` 
    */
    function _encode(bytes memory data) public  pure returns (string memory ){
        return  data.encode();
    }
}