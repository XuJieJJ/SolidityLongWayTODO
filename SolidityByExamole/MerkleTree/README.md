# 剖析MerkleTree

## 源码解读

在**MerkleTree**中根部叫做根哈希，两个叶子节点的哈希通过创建一个哈希被组合成为自己的父节点，而单个的叶子节点即自己再做一次哈希得到父节点，重复这样的步骤便可以得到一棵只有一个根哈希的树

在solidity中，一个merkle证明是你向**知道根哈希的人证明**某一值是这棵树的叶子节点之一，以oz库[MerkleProof.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)为例

```solidity
function verifyCalldata(
	bytes32[] calldata proof,
    bytes32 root, bytes32 leaf) 
internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }
```

在verifyCalldata中，proof为链外创建的数据，root为根哈希，leaf为将要证明的叶子节点

```solidity
function processProofCalldata(
	bytes32[] calldata proof, 
	bytes32 leaf) 
internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }
    function _hashPair(bytes32 a, bytes32 b)
    private
    pure
    returns(bytes32)
{
    return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
}

function _efficientHash(bytes32 a, bytes32 b)
    private
    pure
    returns (bytes32 value)
{
    assembly {
        mstore(0x00, a)
        mstore(0x20, b)
        value := keccak256(0x00, 0x40)
    }
}
```

在verifyCalldata中，将遍历proof数组中的每个元素，从将要证明的叶子节点开始，proof为证明路径，在每一步操作中proof中的元素与叶子节点进行哈希计算出父节点，哈希计算中总是先取较小的值，在示例的oz库中，采用keccak256操作码的汇编来进行哈希计算，这样在solidity中可以使用keccak(abi.encodePacked())进行哈希计算。这样通过层层调用，计算出叶子节点和proof的根节点哈希，通过与root对比，即可得出证明结果。

## MerkleTree实例

