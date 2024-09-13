// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts@5.0.0/utils/ReentrancyGuard.sol";

contract TestReentrancyGuard  is ReentrancyGuard{
    uint256 public _number ;

    function add()public  nonReentrant {
        _number++;
    }
}