// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.0;
import "@openzeppelin/contracts@5.0.0/utils/types/Time.sol";

contract TestTime {
        using Time for Time.Delay;

        Time.Delay public  _lock;

        constructor(uint32  lock){
            _lock = Time.toDelay(lock);
        }

        //timestamp()
        function getTimestamp()public view returns (uint48){
            return  Time.timestamp();
        }

        //blockNumber()
        function getBlockNumber()public view returns (uint48){
            return Time.blockNumber();
        }
        //--getFull(Delay self) 
        function _getFull()public view  returns (uint32, uint32, uint48) {
            return _lock.getFull();
        }

        //get(Delay self) 
        function _get()public  view  returns (uint32){
            return  _lock.get();
        }

        function _withUpdate(uint32 newValue,uint32 minSetback)public  {
               (Time.Delay newLock ,) = _lock.withUpdate(newValue,minSetback);
               _lock = newLock;
        }

        function getCurrentDelay()public  view returns (uint32){
            (uint32 before , uint32 valueafter ,uint48 effect ) = _getFull();

            uint48 current = getTimestamp();
            if (current > effect && effect != 0){
                return valueafter;
            }else {
                return before;
            }
        }

}


