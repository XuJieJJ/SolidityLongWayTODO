// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.8.0/utils/Arrays.sol";


//uint256[] storage / address[] storage / bytes32[] storage
contract TestArrays {
    using Arrays for uint[];

    uint[] public  _arr = [1,2,3,4];

    //findUpperBound 搜索已排序的数组，并返回第一个包含值大于或等于 `element`的第一个索引 如不存在返回数组长度
    function getIndex(uint element) public  view returns (uint){
        return  _arr.findUpperBound(element);
    }

}