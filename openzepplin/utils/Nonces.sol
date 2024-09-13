// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts@5.0.0/utils/Nonces.sol";

contract Nonce is Nonces{

    //查看个人nonce
    function getNonces()view public returns (uint256){
        return  nonces(msg.sender);
    }
    //nonce++
    function nonceAdd()public {
        _useNonce(msg.sender);
    }
    //检查nonce
    function checkNonce(address account, uint256 nonce)public {
        _useCheckedNonce(account, nonce);
    }

}
