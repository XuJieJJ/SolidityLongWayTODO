// SPDX-License-Identifier: MIT
pragma solidity >0.8.16;
contract create{
    //create contracts by new
    uint x;
    constructor(uint a)payable  {
        x= a;
    }
    function D(uint _x)payable public  {
        x=_x;
    }
}
contract testCreate{
    create d = new create(4);
    address public  _address =address(d);
    function createD(uint args)public {
        create newD = new create(args);

    }
    function createWithTransfer(uint args,uint amount)public payable {
        create newD =(new create){value:amount}(args);
    }
}