// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
contract merkleproof{
    bytes32 public  a1 =0x0d21c1f44608f011baa9968b6773a6ea7e16c7d6577bca10f6045779631f5c19;
    bytes32 public  b1 =0x6f0d7dc0d964b4e3d0ebf6f9e7b21a31446d85b7c660c0e46f55d33dcb4411c8;
    bytes32 public  c1 =0x1020d1848c57006b4ea18697f08f4a3c7c9dca4247439925e64b8e523f2605ab;
    bytes32 public  d1 =0xecd303ae67abdb89a5a1e8fb0d4596de732cc5f21ed01fbb1a1cc4870a2ad62d;
    bytes32 public ab =_hashPair(a1, b1);
    bytes32 public cd =_hashPair(c1, d1);
    bytes32 public  root1 =_hashPair(ab, cd);
    function verifyCalldata(
        bytes32 [] calldata proof,
        bytes32 root,
        bytes32 leaf
        )public pure returns (bool){
            return processProofCalldata(proof,leaf)==root;
        }
    function processProofCalldata(
        bytes32 [] calldata proof,
        bytes32 leaf
    )public  pure returns(bytes32){
        bytes32 computehash =leaf;
        for (uint i =0;i<proof.length;i++){
            computehash = _hashPair(computehash,proof[i]);
        }
        return  computehash;
    }
    function _hashPair(bytes32 a,bytes32 b) public pure returns (bytes32 value){
        return a < b? ParentHash(a,b):ParentHash(b, a);
    }
    function ParentHash(bytes32 a,bytes32 b)public  pure returns (bytes32 value){
            value =keccak256(abi.encodePacked(a,b));
            return value;
    }
}