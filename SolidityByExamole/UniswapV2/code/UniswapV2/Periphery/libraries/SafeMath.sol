pragma solidity ^0.6.6;

library SafeMath{
    function add(uint x ,uint y) internal pure returns(uint z){
        require( (z = x + y ) >= x,"add-overflow");
    }
    function sub(uint x,uint y ) internal  pure  returns (uint z){
        require(( z = x - y) <= x,"sub- overflow");
    }
    function mul(uint x,uint y)internal pure returns (uint z){
        require(y == 0 || (z = x*y )/y == x ,"mul -ovreflow");
    }
            

}