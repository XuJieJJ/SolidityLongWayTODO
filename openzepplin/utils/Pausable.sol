// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts@5.0.0/utils/Pausable.sol";

//紧急暂停

contract TestPausable is Pausable {
    uint public _number;
    //bool private _paused;

    //whenNotPaused
    function add()public whenNotPaused {
        _number +=2;
    }

    function sub()public  whenPaused {
        _number -=1;
    }
    //_pause(); 锁定
    function pause()public  {
        _pause();
    }
    //解锁
    function unPause()public {
        _unpause();
    }
}


