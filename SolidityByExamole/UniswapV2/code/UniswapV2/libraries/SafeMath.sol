// SPDX-License-Identifier: MIT
pragma solidity =0.5.16;


library SafeMath{
    function add(uint x, uint y)internal pure returns (uint z ){
        require((z = x + y) >=x,"add overflow!!" );
    }

    function sub(uint x ,uint y)internal pure returns (uint z){
        require((z = x - y )<=x,"sub underflow");
    }

    function mul(uint x ,uint y )internal pure returns (uint z ){
        require(y==0||(z=x*y)/y==x,"mul overflow");
    }
}