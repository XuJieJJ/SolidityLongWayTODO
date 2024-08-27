// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {IERC721} from "./IERC721.sol";
import {IERC721Metadata} from "./IERC721Metadata.sol";
import {IERC721Receiver} from "./IERC721Receiver.sol";
import {IERC165} from "./IERC165.sol";
import {IERC721Errors} from "./IERC721Errors.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC721 is IERC165,IERC721,IERC721Metadata,IERC721Errors{
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

    /**
     * @dev 合约部署时实例化name 和 symbol 状态变量.
     */
    constructor(string memory name_ , string memory symbol_){
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev 查询接口ID.
     */
    function supportsInterface(bytes4 interfaceId)public  pure returns (bool){
        return 
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
    
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
/////////////////internal////////////////////////

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

    /**
     * @dev 查询`tokenId` 的授权账户. 未被授权则返回address(0)
     */
    function _getApproved(uint256 tokenId) internal  view  returns (address){
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev 查询`spender`是否能操作`owner`的NFT
     * 三种情况：1.spender是NFT的owner 2. spender被owner批量授权管理其NFT 3.spender被owner授权管理`tokenId`的NFT
     */
    function _isAuthorized(address owner ,address spender , uint256 tokenId) internal view returns (bool){
        return 
            spender != address(0) &&
            (owner == spender || _operatorApprovals[owner][spender] || _getApproved(tokenId) == spender);
    }

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
     * 发出 {Transfer} 事件。
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

    /**
     * @dev 安全铸造NFT，接收方若为合约地址则进行接口ID校验
     *
     *  详细解释参考{_checkOnERC721Received}
     */
    function _safeMint(address to, uint256 tokenId )internal {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, "");
    }

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


    /**
     * @dev 将 `tokenId` 从 `from` 传输到 `to`，与 {transferFrom} 相反，这对 msg.sender 没有任何限制。
     *
     * 要求：
     * -`to` 不能是零地址。
     * -`tokenId` 必须为 `from` 所有
     *
     * 释放 {Transfer} 事件
     */
    function transferFrom(address from , address to , uint256 tokenId)public  {
        if (to == address(0)){
             revert ERC721InvalidReceiver(address(0));
        }
        //执行转账逻辑
        address previousOwner = _update(to, tokenId, msg.sender);
        //返回NFT的owner值校验
        //如果为address(0) 则NFT不存在
        if (previousOwner == address(0)){
             revert ERC721NonexistentToken(tokenId);
        //如果owner和from不等，则转账账户不
        }else if (previousOwner != from){
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }

    }

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

    /**
     *  实现{IERC721-approve}, 调用内部处理逻辑
     *  释放 {Approve} 事件
     */
    function approve(address to ,uint256 tokenId)public  {
        _approve(to, tokenId, msg.sender, true);
    }

    /**
     *  实现{IERC721-getApproved}, 调用内部处理逻辑
     *  
     */
    function getApproved(uint256 tokenId)public view returns (address){
        //确保NFT存在
        _requireOwned(tokenId);

        return _getApproved(tokenId);

    }

    /**
     *  实现{IERC721-setApprovalForAll}, 调用内部处理逻辑
     *  sh
     */
    function setApprovalForAll(address operator , bool approved)public {
        _setApprovalForAll(msg.sender, operator, approved);
    }

        /**
     *  实现{IERC721-isApprovedForAll}, 调用内部处理逻辑
     * 
     */
    function isApprovedForAll(address owner , address operator) public  view  returns (bool) {
        return  _operatorApprovals[owner][operator];
    }
}