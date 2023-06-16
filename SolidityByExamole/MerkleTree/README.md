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

以以下代码为例，做一次Merkel证明验证

```solidity
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
```

在合约初始化中给出了简单的树结构abcd，分别计算哈希以及父节点哈希，验证结果如下：

以a1 =0x0d21c1f44608f011baa9968b6773a6ea7e16c7d6577bca10f6045779631f5c19

proof=["0x6f0d7dc0d964b4e3d0ebf6f9e7b21a31446d85b7c660c0e46f55d33dcb4411c8","0x261dcf312e478bf2321ecb37f8d2d63eadfbb209005bb6d603da8ed33acc85a3"]

root= 0xd28cfa6b11bfe27d5a4d9046ea737a14a4a60d71d0b28a6ef757111b882a966d



## MerkleTree实例

在MerkleTree中常见的使用场景是空投，现在以ERC20代币为例，采用oz中MerkleProof库实现ERC20代币空投

```solidity
contract MerkleDistributor {
    address public immutable token;
    bytes32 public immutable merkleRoot;

    mapping(address => bool) public isClaimed;

    constructor(address token_, bytes32 merkleRoot_) {
        token = token_;
        merkleRoot = merkleRoot_;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        require(!isClaimed[account], 'Already claimed.');

        bytes32 node = keccak256(
            abi.encodePacked(account, amount)
        );
        bool isValidProof = MerkleProof.verifyCalldata(
            merkleProof,
            merkleRoot,
            node
        );
        require(isValidProof, 'Invalid proof.');

        isClaimed[account] = true;
        require(
            IERC20(token).transfer(account, amount),
            'Transfer failed.'
        );
    }
}

```

### 创建Merkle分发合约

首先创建分发合约，它将持有所有的代币，或者允许铸造新的代币。这个合约核心是claim申领函数，他接受用户的地址、金额和Merkle证明。

在claim中，需要验证：

1.原始Merkle树确实包含一个叶子，其值与账户地址和金额相匹配；

2.用户还没有认领代币；

接下来创建原始Merkle树和Merkle根哈希

```javascript
const keccak256 = require("keccak256");
const { MerkleTree } = require("merkletreejs");
const Web3 = require("web3");

const web3 = new Web3();

let balances = [
  {
    addr: "0xb7e390864a90b7b923c9f9310c6f98aafe43f707",
    amount: web3.eth.abi.encodeParameter(
      "uint256",
      "10000000000000000000000000"
    ),
  },
  {
    addr: "0xea674fdde714fd979de3edf0f56aa9716b898ec8",
    amount: web3.eth.abi.encodeParameter(
      "uint256",
      "20000000000000000000000000"
    ),
  },
];

const leafNodes = balances.map((balance) =>
  keccak256(
    Buffer.concat([
      Buffer.from(balance.addr.replace("0x", ""), "hex"),
      Buffer.from(balance.amount.replace("0x", ""), "hex"),
    ])
  )
);

const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

console.log("---------");
console.log("Merke Tree");
console.log("---------");
console.log(merkleTree.toString());
console.log("---------");
console.log("Merkle Root: " + merkleTree.getHexRoot());

console.log("Proof 1: " + merkleTree.getHexProof(leafNodes[0]));
console.log("Proof 2: " + merkleTree.getHexProof(leafNodes[1]));
```

