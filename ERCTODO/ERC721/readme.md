### 1、ERC721标准规范

#### 1.1 IERC721

和`ERC20`一样，`ERC721`同样是一个代币标准，官方解释`NFT`为`Non-Fungible Token`,译作非同质化代币。

如何理解`NFT`呢？非同质化代表独一无二，其和`ERC20`的区别，在于资产是否可以分割与独一无二，而`NFT`标准都有唯一的标识符和元数据，就像是世界上没有两片完全相同的树叶，每个`NFT`代币彼此不可替代，这些独特性使得`ERC721`标准具有广泛的应用场景，包括艺术品、收藏品、域名、数字证书、数字音乐等等领域。

`ERC721`基本标准为

- balanceOf()：返回`owner`账户的代币数量。

- ownerOf()：返回`tokenId`的所有者。

- safeTransferFrom()：安全转账`NFT`。

  函数需要做以下校验

  - `msg.senfer`应该是当前`tokenId`的`owner`或是`spender`；
  - `_from`必须是`_tokenId`的所有者；
  - `_tokenId`必须存在并且属于`_from`；
  - `_to`如果是CA（合约地址）,它必须实现`IERC721Receiver-onERC721Received`接口，检查其返回值。这么做的目的是，为了避免将`tokenId`转移到一个无法控制的合约地址，导致`token`被永久转进黑洞。因为CA账户无法主动触发交易，只能由EOA账户来调用合约触发交易。

- transferFrom()：非安全转账`NFT`。
- approve()：授权地址`_to`具有`tokenId`的支配权
- setApprovalForAll()：批准或取消`_openrater`的`token`操作权限，用于批量授权
- getApproved()：获取`_tokenId`授权
- isApprovedForAll()：获取`_tokenId`的支配情况

#### 1.2 IERC165

`ERC721`要求必须符合`ERC165标准`，什么是`ERC165`？

和`ERC20`和`ERC721`一样，它也是以太坊系统的一种标准规范,其主要用于：

- 一种接口检查查询和发布标准
- 检测智能合约实现了哪些接口

`IERC165`官方定义为

```solidity
	/// @dev 查询一个合约时候实现了一个接口
    /// param interfaceID  参数：接口ID
    /// return true 如果函数实现了 interfaceID (interfaceID 不为 0xffffffff )返回true, 否则为 false
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
```

这里仅作补充，`ERC165`提供了一种确定性的互操作支持，方便了合约之间的检查交互。

#### 1.3 IERC721与IERC165

在`ERC721`当中，依赖`ERC165`接口，重写`supportsInterface(bytes4 interfaceId)`覆盖父级合约，在调用方法之前查询目标合约是否实现相应接口，具体实现如下：

```solidity
    /**
     * @dev 查询目标合约是否实现ERC721接口
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
```

当查询的是`IERC721`、`IERC721Metadata`或`IERC165`的接口id时，返回`true`；反之返回`false`，参考：[EIP165官方提案](https://learnblockchain.cn/docs/eips/eip-165.html#实现)

### 2、编写ERC721函数接口

`IERC721`是`ERC721`标准的接口合约，规定了`ERC721`要实现的基本函数。它利用`tokenId`来表示特定的非同质化代币，授权或转账都要明确`tokenId`，它通过一组标准化的函数接口来管理资产的所有权和交易；而`ERC20`只需要明确转账的数额即可。

#### 2.1 IERC165接口

`IERC721`必须符合`IERC165`接口,便于合约交互做接口查询

```solidity
interface IERC165 {
    /**
     * @dev 查询一个合约时候实现了一个接口
     *	param interfaceID  参数：接口ID
     *  return bool
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
```

#### 2.2 ERC721事件

`IERC721`定义了`3`个事件：`Transfer`、`Approval`和`ApprovalForAll`，分别在转账、授权和批量授权时候释放；

```solidity
 	/**
     * @dev 释放条件：发生`tokenId`代币转移，从`from`转移至`to`.
     * param( address , address , uint256 )
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev 释放条件：发生`tokenId`代币授权,`owner`授权给`approved`支配token.
     * param( address , address , uint256 )
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev 释放条件：当`owner`管理`operator`的所有资产管理权限，即批量授权
     * param(address,address,bool)
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

```

#### 2.3 函数接口

`IERC721`定义了9个函数，实现代币的交易、授权和查询功能。

- `balanceOf()`

返回目标账户`owner`的代币数量,区分`ERC20`代币数量,这里可理解为`tokenId`数量

```solidity
	/**
     * @dev 返回代币数量.
     * param address 账户地址
     * return uint256 代币数量
     */
    function balanceOf(address owner) external view returns (uint256 balance);

```

- `ownerOf()`

返回`tokenId`的`owner`

```solidity
    /**
     * @dev 查询`tokenId`的拥有者
     * 
     *  param uint256 tokenId
     *  return address 代币拥有者
     * 查询条件:
     * - `tokenId` 必须存在.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);
    
```

- `safeTransferFrom()`

安全转账，将`tokenId`从`from`转移至`to`，携带`data`参数,`data`的作用可以是附加额外的参数（没有指定格式），传递给接收者。

```solidity
    /**
     * @dev 安全转账,将NFT的所有权从`from`转移至`to`.
     *
     * 转移条件:
     *
     * - `from` 不能是address(0).
     * - `to` 不能是address(0).
     * - `tokenId` 必须存在且属于`from`.
     * - 如果调用者不是`from`,则必须通过授权校验，拥有该`tokenId`的支配权.
     * - 如果`to`为合约地址，则必须实现{IERC721Receiver-onERC721Received}接口.
     *
     *释放 {Transfer} 事件.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    
```

- `safeTransferFrom()`

安全转账， 将`tokenId`从`from`转移至`to`，功能同上，不带data参数。

```solidity
    /**
     * @dev 功能参考 ``safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data)``
     *
     * 释放 {Transfer} 事件.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    
```

- `transferFrom()`

普通转账， 将`tokenId`从`from`转移至`to`

```solidity
    /**
     * @dev 转移 `tokenId` 从 `from` 到 `to`.
     *
     * @notice: 调用此方法需注意接收者有能力调配`ERC721`，否则可能会永久丢失，推荐使用`safeTransferFrom`，但这会增加一次外部调用，可能会导致重入，注意防范.
     *
     * 条件:参考`safeTransferFrom`
     *
     * 释放 {Transfer} 事件.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

```

- `approve()`

代币授权，和`ERC20`一致，授权其他用户支配自己的代币，这里体现为`NFT`

```solidity
    /**
     * @dev 授权`to`账户支配调用者`msg.sender`的`tokenId`-`NFT`权限.
     * 当`token`发生转账时会清除授权.
     *
     * NFT只能授权给一个账户，当发生新的授权时候会更新授权账户.
     *
     * 条件:
     *
     * - 调用者必须为拥有该`NFT`或者被授权能够支配该`NFT`
     * - `tokenId` 必须存在.
     *
     * 释放 {Approval} 事件.
     */
    function approve(address to, uint256 tokenId) external;
    
```

- `setApprovalForAll()`

批量授权其他账户支配自己NFT的权限

```solidity
    /**
     * @dev 批准或者移除`operator`账户对`msg.sender`账户所有NFT操作的权限
     * operator可以调用{transferFrom}或者{safeTransferFrom}转移token
     *
     * 条件:
     *
     * - `operator` 不能是address(0).
     *
     * 释放 {ApprovalForAll} 事件.
     */
    function setApprovalForAll(address operator, bool approved) external;

```

- `getApproved()`

查询某`tokenId`被授权给哪个账户

```solidity
    /**
     * @dev 返回`tokenId`批准支配的账户.
     *
     * 条件:
     *
     * - `tokenId` 必须存在.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);
    
```

- `isApprovedForAll()`

查询某地址的NFT是否批量授权给了operator`地址支配

```solidity
    /**
     * @dev 返回是否允许`operator`能够支配`owner`的所有NFT
     *
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
```

### 3、 编写IERC721Metadata接口

`IERC721Metadata`是`IERC721`的扩展接口，实现了`ERC721`的元数据扩展，包括`name`、`symbo`、和`tokenURI`（`NFT`所对应的资源）。该接口用于存储额外数据，包括：

- `name()`：返回代币名称
- `symbol()`：返回代币代号符号
- `tokenURI()`：返回`tokenId`对应的元数据，URI通常存储图片的链接路径或者是`IPFS`存储链接

其**接口标准**为

```solidity
/**
 * @title ERC-721 元数据扩展接口
 * @dev 见 https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev 查询代币名称.
     */
    function name() external view returns (string memory);

    /**
     * @dev 查询代币代号符号.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev 查询NFT的URI元数据
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
```

### 4、 编写IERC721Receiver接口

`IERC721Receiver`确保合约地址如果要接收`NFT`的安全转账，必须实现其接口。这里在于提醒合约开发者在编写接收`NFT`的合约时候，能够编写有效处理`NFT`的转账逻辑.

这里可以理解为当`EOA`转账`ETH`给`CA`时，如果合约代码没有实现`withdraw`函数进行提现`eth`，那么这个`eth`便永久的储存在合约当中，因为合约代码不能自发调用其代码，必须通过`EOA`账户进行函数调用。对比`NFT`的转账，如果开发者在接收`NFT`的合约中没有提供转账`NFT`的功能，那么这个`token`便会永久留在这个合约当中，相当于发送进黑洞。

为了防止这种情况，`IERC721Receiver`接口中包含`onERC721Received`函数，只用接收合约中实现了这个接口才能接收`NFT`，意味着开发者意识到了这个问题，在自己的合约代码中防范了这种情况，当然，如果实现了这个接口，但是仍然没有针对合约转账`NFT`做出防范措施，那头铁的结果依然是`NFT`进了黑洞。

`IERC721Receiver`标注规范为：

```solidity
interface IERC721Receiver {
    /**
     * @dev 当发送想合约转账NFT时，回调此函数
     *
     * @notice 返回其函数选择器，以确认token转账.
     * @notice 返回其他值，或者接收合约未实现该接口，转账将被revert.
     *
     * 函数选择器可通过`IERC721Receiver.onERC721Received.selector`获得.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
```

# TODO 

### 5、 编写IERC721Errors错误接口

`IERC721Errors`

### 6、编写ERC721工具库

#### 5.1 ERC721Utils 

`ERC721Utils `提供了校验库函数，确保目标地址to能够正确接收代币，