// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;


interface demo {
    function hello()external  ;
    function say()external ;
}

contract test   {

        /// 0x8cb5a993
        bytes4 public  _selector =  bytes4(keccak256("hello()")) ^ bytes4(keccak256("say()"));
        
        /// 0x8cb5a993
        function get() public pure  returns (bytes4){
            return type(demo).interfaceId;
        }
        /// 0x8cb5a993
        function get2()public  pure  returns (bytes4 ){
            return  demo.hello.selector ^ demo.say.selector;
        }
}