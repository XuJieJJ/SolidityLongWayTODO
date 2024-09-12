// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@5.0.0/utils/StorageSlot.sol";
contract Test {

    bytes32 public   _VALUE = keccak256("test");
    uint  public slot0 = 1;

    function getSlot0() public view  returns(bytes32  result){
        assembly{
            result := sload(0)
        }
    }
    function getSlot1()public  view  returns (bytes32 result){
        assembly {
            result := sload(1)
        }
    }
}

contract TestStorageSlot {
    using  StorageSlot for bytes32;

    //constant 不占存储槽
    bytes32 public constant _ADDRESS_SLOT = keccak256("address slot");
    bytes32 public constant _BOOLEAN_SLOT = keccak256("boolean slot");
    bytes32 public constant _BYTES32_SLOT = keccak256("bytes32 slot");
    bytes32 public constant _UINT256_SLOT = keccak256("uint256 slot");

    uint public  slot0 = 0;
    uint public  slot1 = 10;
    uint public  slot2 = 20;

    function setAddressSlot(address newAddr) external {
        _ADDRESS_SLOT.getAddressSlot().value = newAddr;
    }
    function getAddressSlot()public  view returns (address){
        return _ADDRESS_SLOT.getAddressSlot().value;
    }

    struct AddressSlot {
        address value;
    }
    function _getAddressSlot(bytes32 slot) internal pure  returns (AddressSlot storage r){
        assembly {
            r.slot := slot
        }
    }
}



