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

### 5、 编写IERC721Errors错误接口

`IERC721Errors`定义了`8`个错误，帮助我们在实现代码业务逻辑时捕获错误异常

- `ERC721InvalidOwner`

转账错误时候触发，表明NFT的owner地址不合法

```solidity
    /**
     * @dev 不合法的owner地址. 例如:address(0).
     * 用于查询balance时候调用.
     * param address -- owner.
     */
    error ERC721InvalidOwner(address owner);
    
```

- `ERC721NonexistentToken`

`tokenId`不存在时候触发

```solidity
    /**
     * @dev 表明 `tokenId`的`owner`为address(0).
     * param uint256 -- tokenId.
     */
    error ERC721NonexistentToken(uint256 tokenId);
    
```

- `ERC721IncorrectOwner`

`tokenId`对应的token所有权错误，转账时候触发

```solidity
    /**
     * @dev 表明 `tokenId`的`owner`为发生错误.
     * param (address,tokenId,address) -- (发送方，tokenId，NFTowner).
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    
```

- `ERC721InvalidSender`

`token`转账错误，不合法的`sender`，多用于address(0)转账NFT

```solidity
    /**
     * @dev 表明`sender`发送token失败
     * param address 发生转账NFT的地址.
     */
    error ERC721InvalidSender(address sender);

```

- `ERC721InvalidReceiver`

`token`转账错误，不合法的`receiver`，多用于向address(0)转账NFT

```solidity
    /**
     * @dev 表明`receiver`接收token失败
     * param address 接收转账NFT的地址.
     */
    error ERC721InvalidReceiver(address receiver);
    
```

- `ERC721InsufficientApproval`

`operator`操作账户获取授权失败，表明未被授权`tokenId`的操作权限

```solidity
    /**
     * @dev `operater`未经授权`tokenId`，转账失败.
     * param (address uint256) -- (操作账户，`tokenId`)
     *
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

```

- `ERC721InvalidApprover`

参考转账账户发生的错误，这里用于授权账户不合法,即address(0)发生授权。授权的时候触发

```solidity
    /**
     * @dev 表明授权账户`approver`不合法，.
     * param address -- 授权账户.
     */
    error ERC721InvalidApprover(address approver);
    
```

- `ERC721InvalidOperator`

操作账户不合法，即向address(0)地址授权。授权时候触发

```solidity
    /**
     * @dev 表明操作账户`operator`不合法，.
     * param address -- 操作账户.
     */
    error ERC721InvalidOperator(address operator);
    
```

`8`个`error`，涵盖了在`NFT`发生转账、授权的时候可能遇到的错误，帮助我们在编写代码的时候捕获错误异常

### 6、 实现ERC721

`ERC721`主合约实现了`IERC721`，`IERC165`和`IERC721Metadata`，`IERCErrors`定义的所有功能,此外我们借助`Openzeppelin`的[Strings.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol)方法帮助我们处理`uint256`类型的字符串转换问题

接下来我们创建ERC721合约，导入以下接口文件

```solidity
import {IERC721} from "./IERC721.sol";
import {IERC721Metadata} from "./IERC721Metadata.sol";
import {IERC721Receiver} from "./IERC721Receiver.sol";
import {IERC165} from "./IERC165.sol";
import {IERC721Errors} from "./IERC721Errors.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

```

#### 6.1 状态变量

对比`ERC20`标准，我们同样需要使用状态变量来记录账户`NFT`信息，授权以及`token`信息

```solidity
    using  Strings for uint256;

    // 代币名称
    string private _name;
    // 代币符号
    string private _symbol;
    // NFT 的owner
    mapping (uint256  tokenId => address) private _owner;
    // 账户拥有的的NFT数量
    mapping (address owner => uint256) private  _balances;
    // NFT的授权账户
    mapping (uint256 tokenId => address) private _tokenApprovals;
    // 账户operator 是否被授权支出 owner 的NFT，即批量授权
    mapping (address owner => mapping (address operator => bool)) private  _operatorApprovals;
```

#### 6.2 函数

- 构造函数：初始化代币名称，符号。

```solidity
    /**
     * @dev 合约部署时实例化name 和 symbol 状态变量.
     */
    constructor(string memory name_ , string memory symbol_){
        _name = name_;
        _symbol = symbol_;
    }
```

- `supportsInterface()`

查询`NFT`合约支持的接口，在调用方法之前查询目标合约是否实现相应接口，详细描述见`1.3`

```solidity
    /**
     * @dev 查询接口ID.
     */
    function supportsInterface(bytes4 interfaceId)public  pure returns (bool){
        return 
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
    
```

- `balanceOf()`

查询`owner`持有的代币数量

```solidity
    /**
     * @dev 查询用户持仓数量.
     */
    function balanceOf(address owner) public  view returns (uint256){
        //地址校验
        if (owner == address(0)){
            revert ERC721InvalidOwner(address(0));
        }
        return _balances[owner];
    }
    
```

- `ownerOf()和_requireOwned()`

查询`tokenId`的所有者,校验`NFT`是否存在

```solidity
    /**
     * @dev 查询NFT的所有者.
     */
    function _ownerOf(uint256 tokenId)internal  view returns (address){
        return _owner[tokenId];
    }
    /**
     * @dev 供外部调用，逻辑处理交给_ownerOf().
     */
    function ownerOf(uint256 tokenId)public  view  returns (address){
        return _requireOwned(tokenId);
    }
    /**
     * @dev 如果 `tokenId` 没有当前所有者（尚未铸币或已被烧毁） 交易回滚
     * 返回 `owner`.
     */
    function _requireOwned(uint256 tokenId)internal view returns(address){
        //判断NFT是否存在
        address owner = _ownerOf(tokenId);
        if (owner == address(0)){
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;

    }
```

- `name()`和`symbol()`

查询NFT的名称和代号

```solidity
    /**
     * @dev 查询名称.
     */
    function name()public  view returns (string memory){
        return _name;
    }
    /**
     * @dev 查询代号.
     */
    function symbol()public  view  returns (string memory){
        return  _symbol;
    }
```

- `tokenURI()`和`_baseURI()`

查询`NFT`的`URI`元数据

```solidity
    /**
     * @dev 查询NFT扩展对应外部资源.
     */
    function tokenURI(uint256 tokenId) public  view  returns (string memory){
        //这里做NFT校验
        _requireOwned(tokenId);
        //获取基础URI
        string memory baseURI = _baseURI();

        //拼接{baseURI} + {tokenId}
        return bytes(baseURI).length > 0 ? string.concat(baseURI,tokenId.toString()) : "";
    }

    /**
     * @dev 用作{tokenURI} 的基础 URI 
     * 如果设置：
     * 每个{token}的URI 由`baseURI` + `tokenId`拼接而成
     *   
     * 这里默认为 "" 支持后续继承重载
     */
    function _baseURI()internal pure virtual returns (string memory){
        return  "";
    } 
```

- `_getApproved()`

查询`NFT`的授权地址

```solidity
    /**
     * @dev 查询`tokenId` 的授权账户. 未被授权则返回address(0)
     */
    function _getApproved(uint256 tokenId) internal  view  returns (address){
        return _tokenApprovals[tokenId];
    }
```

- `_isAuthorized()`

查询`tokenId`的NFT的账户操作权限

```solidity
    /**
     * @dev 查询`spender`是否能操作`owner`的NFT
     * 三种情况：1.spender是NFT的owner 2. spender被owner批量授权管理其NFT 3.spender被owner授权管理`tokenId`的NFT
     */
    function _isAuthorized(address owner ,address spender , uint256 tokenId) internal view returns (bool){
        return 
            spender != address(0) &&
            (owner == spender || _operatorApprovals[owner][spender] || _getApproved(tokenId) == spender);
    }
```

- `_checkAuthorized()`

检查NFT授权情况，捕获相应错误

```solidity
    /**
     * @dev 检查`spender`是否能操作`owner`的NFT
     * 捕获相应错误{ERC721NonexistentToken} {ERC721InsufficientApproval}
     */
    function _checkAuthorized(address owner , address spender , uint256 tokenId)internal  view {
        if (!_isAuthorized(owner, spender, tokenId)){
            //这里的owner一般是后续外部调用： 通过`tokenId`查询得到的地址，即使用`_ownerOf()`函数得到的地址，所以非捕获的{ERC721InvalidOwner}错误
            if (owner  == address(0)){
                revert ERC721NonexistentToken(tokenId);
            }else {
                revert ERC721InsufficientApproval(spender,tokenId);
            }
        }
    }
```

- `_approve()`

授权逻辑，参考`ERC20`的授权函数入参，这里同样引入`emitEvent`来区分是否需要释放授权事件

```solidity
    /**
     * @dev 授权内部处理逻辑 emitEvent可选
     *
     * @param to 授权地址
     * @param tokenId NFT id
     * @param auth 支出账户 
     * @param emitEvent 事件释放信号
     */
    function _approve(address to , uint256 tokenId , address auth , bool emitEvent)internal {
        //地址校验
        if (emitEvent || auth != address(0)){
            address owner = _requireOwned(tokenId);
            
            //权限判断，授权账户非address(0)情况下：owner和auth不等且未获得批量授权;
            if (auth != address(0) && owner != auth && !_operatorApprovals[owner][auth]){
                 revert ERC721InvalidApprover(auth);
            }

            if ( emitEvent ){
                emit  Approval(owner, to, tokenId);
            }
        }
        //更新授权
        _tokenApprovals[tokenId] = to;
    }
```

- `_setApprovalForAll()`

批量授权逻辑

```solidity
    /**
     * @dev 批量授权owner的NFT
     *
     * 条件:
     * - operator 不能是address(0).
     *
     *  释放{ApprovalForAll} 事件.
     */
    function _setApprovalForAll(address owner , address operator , bool approved) internal {
        //地址校验
        if (operator == address(0)){
            revert ERC721InvalidOperator(operator);
        }

        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
```

- `_checkOnERC721Received()`

在安全转账`NFT`的时候调用，检查如果接收账户为CA则检查目标合约是否实现`IERC721Receiver`接口，提醒开发者注意合约是否能够正确处理转入合约的`NFT`，而`_checkOnERC721Received`内部检查目标合约是否返回指定的接口ID

```solidity
    /**
     * @dev 在目标地址上调用 {IERC721Receiver-onERC721Received}数。如果
     * 接收方不接受token转账。如果目标地址不是合约，则不执行调用。
     *
     * @param from 地址，代表给定token ID 的上一个所有者
     * @param to 将接收代币的目标地址
     * @param tokenId uint256 要传输的NFT
     * @param data bytes 可选数据，与调用一起发送
     */
    function  _checkOnERC721Received(address from , address to ,uint256 tokenId ,bytes memory data)private {
        //在 {address} 的代码，EOA为空
        if (to.code.length > 0){
            try IERC721Receiver(to).onERC721Received(msg.sender , from , tokenId , data) returns (bytes4 retval){
                //校验返回值和指定ID是否一致
                if (retval != IERC721Receiver.onERC721Received.selector){
                    revert ERC721InvalidReceiver(to);
                }
            }catch (bytes memory reason ) {
                if (reason.length == 0){
                    revert ERC721InvalidReceiver(to);
                }else {
                    assembly {
                        //这里简单介绍：
                        //reason指向存储错误消息的指针位置
                        //add(32,reason)指针向前移动32个字节，因为Solidity动态数组在内存存储时候，前32个字节用于存储数组的长度
                        //这里加上32个字节，指针跳过数组长度信息，直接指向错误消息的实际内容

                        //mload指令： 从内存中加载数据
                        //从内存中reason + 32的位置开始，以mload(reason)指定的长度来返回错误消息，并终止交易
                        revert(add(32,reason),mload(reason))
                    }
                }
            }
        }
    }

```

- `_update()`

转账的内部处理逻辑，包含用户转账、`NFT`铸造、`NFT`销毁等，都可视作`NFT`的转账，区别在于转账账户的不同。

```solidity
    /**
     * @dev 将 `tokenId` 从其当前拥有者转移到 `to` 中，或者，如果当前拥有者或 `to` 是零地址，则进行铸币（或烧毁）
     *       
     * `auth` "参数是可选参数。如果传递的值非零地址，则此函数将检查
     * `auth` 是`token`的所有者，或已获准对`token`进行操作（由所有者批准）
     *
     * 释放 {Transfer} 事件。
     *
     */
    function _update(address to , uint256 tokenId , address auth)internal returns (address){
        //获取NFT的owner
        address from = _ownerOf(tokenId);   

        //地址校验 && 检查auth是否有支出权限 
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        //执行转账逻辑，首先判断NFT
        if (from != address(0)){
            //更新授权 授权账户清除
            _approve(address(0), tokenId, address(0), false);
            //更新from持仓数量
            unchecked {
                _balances[from] -= 1;
            }
        }
        //to 如果不是零地址 则代表不是销毁
        if (to != address(0)){
            //更新to持仓数量
            unchecked{
                _balances[to] += 1 ;
            }
        }
        //更新NFT所有者
        _owner[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return  from;
    }
```

- `_mint()`

铸造`NFT`

```solidity
    /**
     * @dev 为 `tokenId` 造币并将其传输到 `to`。
     *
     * 建议使用 {_safeMint}
     *
     * 要求：
     *
     * `tokenId` 必须不存在。
     * `to` 不能是零地址。
     *
     * 释放 {Transfer} 事件。
     */
    function _mint(address to , uint256 tokenId) internal {
        if (to == address(0)){
            revert ERC721InvalidReceiver(address(0));
        }
        //判断前置NFT的Owner , 如果未铸造账户应是零地址
        address _previousOwner = _update(to, tokenId, address(0));

        if (_previousOwner != address(0) ){
            revert ERC721InvalidSender(address(0));
        }
    }
```

- `_safeMint()`

安全铸造`NFT`，校验接收账户的NFT处理

```solidity
    /**
     * @dev 安全铸造NFT，接收方若为合约地址则进行接口ID校验
     *
     *  详细解释参考{_checkOnERC721Received}
     */
    function _safeMint(address to, uint256 tokenId )internal {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, "");
    }
```

- `_burn()`

销毁`NFT`

```solidity
    /**
     * @dev 为 `tokenId` 销毁，看作将其传输到 `address(0)`。
     *
     * 要求：
     *
     * `tokenId` 必须存在
     *
     * 释放 {Transfer} 事件。
     */
    function _burn(uint256 tokenId)internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)){
            revert ERC721NonexistentToken(tokenId);
        }
    }
```

- `transferFrom()`

转账`NFT`，用户转账自己的`NFT`

```solidity
    /**
     * @dev 将 `tokenId` 从 `from` 传输到 `to`，与 {transferFrom} 相反，这对 msg.sender 没有任何限制。
     *
     * 要求：
     * -`to` 不能是零地址。
     * -`tokenId` 必须为 `from` 所有
     *
     * 释放 {Transfer} 事件
     */
    function transferFrom(address from , address to , uint256 tokenId)public {
        if (to == address(0)){
             revert ERC721InvalidReceiver(address(0));
        }
        //执行转账逻辑
        address previousOwner = _update(to, tokenId, msg.sender);
        //返回NFT的owner值校验
        //如果为address(0) 则NFT不存在
        if (previousOwner == address(0)){
             revert ERC721NonexistentToken(tokenId);
        //如果owner和from不等，则转账NFT错误
        }else if (previousOwner != from){
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }

    }
```

- `safeTransferFrom()`

安全转账`NFT`

```solidity
    /**
     * @dev 安全地将 `tokenId` 令牌从 `from` 传输到 `to`，检查合约接收方,防止代币被永久锁定。
     *
     * `data` 是附加数据，没有指定格式，在调用 `to` 时发送。
     *
     * 要求：
     *
     * -`tokenId` 令牌必须存在并为 `from` 所有。
     * - `to` 不能是零地址。
     * - `from`不能是零地址。
     * - 如果 `to` 指向一个智能合约，它必须实现 {IERC721Receiver-onERC721Received}，在安全转移时调用。
     */
    function safeTransferFrom(address from , address to ,uint256 tokenId)public  {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * 与[`safeTransferFrom`]相同，但多了一个`data`参数。
     */
    function safeTransferFrom(address from, address to,uint256 tokenId , bytes memory data)public {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }
```

- `approve()`

授权函数

```solidity
    /**
     *  实现{IERC721}, 调用内部处理逻辑
     *  释放 {Approval} 事件
     */
    function approve(address to ,uint256 tokenId)public  {
        _approve(to, tokenId, msg.sender, true);
    }
```

- `getApproved()`

查询授权账户

```solidity
    /**
     *  实现{IERC721-getApproved}, 调用内部处理逻辑
     *  
     */
    function getApproved(uint256 tokenId)public view returns (address){
        //确保NFT存在
        _requireOwned(tokenId);

        return _getApproved(tokenId);

    }
```

- `setApprovalForAll()`

进行批量授权

```solidity
    /**
     *  实现{IERC721-setApprovalForAll}, 调用内部处理逻辑
     *  释放 {ApprovalForAll} 事件
     */
    function setApprovalForAll(address operator , bool approved)public {
        _setApprovalForAll(msg.sender, operator, approved);
    }
```

- `isApprovedForAll()`

查询`operator`是否获得`owner`账户批量授权`NFT`

```solidity
    /**
     *  实现{IERC721-isApprovedForAll}, 调用内部处理逻辑
     * 
     */
    function isApprovedForAll(address owner , address operator) public  view  returns (bool) {
        return  _operatorApprovals[owner][operator];
    }
```

查询NFT的外部资源文件，

```solidity
// SPDX-License-Identifier: MIT
// by 0xAA
pragma solidity ^0.8.21;

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./String.sol";

contract ERC721 is IERC721, IERC721Metadata{
    using Strings for uint256; // 使用String库，

    // Token名称
    string public override name;
    // Token代号
    string public override symbol;
    // tokenId 到 owner address 的持有人映射
    mapping(uint => address) private _owners;
    // address 到 持仓数量 的持仓量映射
    mapping(address => uint) private _balances;
    // tokenID 到 授权地址 的授权映射
    mapping(uint => address) private _tokenApprovals;
    //  owner地址。到operator地址 的批量授权映射
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // 错误 无效的接收者
    error ERC721InvalidReceiver(address receiver);

    /**
     * 构造函数，初始化`name` 和`symbol` .
     */
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 实现IERC165接口supportsInterface
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    // 实现IERC721的balanceOf，利用_balances变量查询owner地址的balance。
    function balanceOf(address owner) external view override returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }

    // 实现IERC721的ownerOf，利用_owners变量查询tokenId的owner。
    function ownerOf(uint tokenId) public view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    }

    // 实现IERC721的isApprovedForAll，利用_operatorApprovals变量查询owner地址是否将所持NFT批量授权给了operator地址。
    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    // 实现IERC721的setApprovalForAll，将持有代币全部授权给operator地址。调用_setApprovalForAll函数。
    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 实现IERC721的getApproved，利用_tokenApprovals变量查询tokenId的授权地址。
    function getApproved(uint tokenId) external view override returns (address) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }
     
    // 授权函数。通过调整_tokenApprovals来，授权 to 地址操作 tokenId，同时释放Approval事件。
    function _approve(
        address owner,
        address to,
        uint tokenId
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 实现IERC721的approve，将tokenId授权给 to 地址。条件：to不是owner，且msg.sender是owner或授权地址。调用_approve函数。
    function approve(address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    // 查询 spender地址是否可以使用tokenId（需要是owner或被授权地址）
    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) private view returns (bool) {
        return (spender == owner ||
            _tokenApprovals[tokenId] == spender ||
            _operatorApprovals[owner][spender]);
    }

    /*
     * 转账函数。通过调整_balances和_owner变量将 tokenId 从 from 转账给 to，同时释放Transfer事件。
     * 条件:
     * 1. tokenId 被 from 拥有
     * 2. to 不是0地址
     */
    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    
    // 实现IERC721的transferFrom，非安全转账，不建议使用。调用_transfer函数
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _transfer(owner, from, to, tokenId);
    }

    /**
     * 安全转账，安全地将 tokenId 代币从 from 转移到 to，会检查合约接收者是否了解 ERC721 协议，以防止代币被永久锁定。调用了_transfer函数和_checkOnERC721Received函数。条件：
     * from 不能是0地址.
     * to 不能是0地址.
     * tokenId 代币必须存在，并且被 from拥有.
     * 如果 to 是智能合约, 他必须支持 IERC721Receiver-onERC721Received.
     */
    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, _data);
    }

    /**
     * 实现IERC721的safeTransferFrom，安全转账，调用了_safeTransfer函数。
     */
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    // safeTransferFrom重载函数
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /** 
     * 铸造函数。通过调整_balances和_owners变量来铸造tokenId并转账给 to，同时释放Transfer事件。铸造函数。通过调整_balances和_owners变量来铸造tokenId并转账给 to，同时释放Transfer事件。
     * 这个mint函数所有人都能调用，实际使用需要开发人员重写，加上一些条件。
     * 条件:
     * 1. tokenId尚不存在。
     * 2. to不是0地址.
     */
    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // 销毁函数，通过调整_balances和_owners变量来销毁tokenId，同时释放Transfer事件。条件：tokenId存在。
    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    // _checkOnERC721Received：函数，用于在 to 为合约的时候调用IERC721Receiver-onERC721Received, 以防 tokenId 被不小心转入黑洞。
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /**
     * 实现IERC721Metadata的tokenURI函数，查询metadata。
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_owners[tokenId] != address(0), "Token Not Exist");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * 计算{tokenURI}的BaseURI，tokenURI就是把baseURI和tokenId拼接在一起，需要开发重写。
     * BAYC的baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
}

```

### 7、 发行NFT

我们来利用`ERC721`来写一个免费铸造的`NFT`：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";

contract NFT is ERC721 {
    uint256 public counters = 1;

    constructor()ERC721("NFT","NFT") {

    }
    function mint(address to )public {
        _mint(to, counters);
        counters++;
    }
}
```

总结：ERC721的剖析我们就到这里，NFT还有很多优秀的设计模式，包括：

- `ERC721Enumerable`：支持对ERC721持有的代币进行枚举；
- `ERC721A`：实现批量铸造;
- `Merkle`树实现铸造白名单;
- ... 后面有时间再更新吧

参考：

[EIP 721](https://learnblockchain.cn/docs/eips/eip-721.html#简要说明)

[Openzeppelin-contracts--ERC721](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/token/ERC721/ERC721.sol)

完整项目代码见：[SolidityLongWayTODO/ERCTODO](https://github.com/XuJieJJ/SolidityLongWayTODO/tree/main/ERCTODO)