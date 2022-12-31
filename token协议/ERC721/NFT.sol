// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC721.sol";

contract NFT is ERC721 {
    uint256 public _totalSupply;
    
    //index to tokenId
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
 
    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;
 
    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;
 
    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    }

    function mint(address account, uint256 tokenId) external {
        // TODO
        require(account!=address(0),"mint to zero address");
       // require(_ownerOf[tokenId]==address(0),"token already minted");
       //require(msg.sender==_ownerOf[tokenId],"token already minted");
        // address owner = ERC721.ownerOf(tokenId);
        // require(owner==address(0),"token already minted!");
        _mint(account,tokenId);
        //add Token To Owner
        uint256 length = ERC721.balanceOf(account);
        _ownedTokens[account][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
        //add token to alltokens
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
        _totalSupply+=1;


        emit Transfer(address(0), account, tokenId);
    }

    function burn(uint256 tokenId) external {
        // TODO 用户只能燃烧自己的NFT
        address owner = _ownerOf(tokenId);
        require(owner==msg.sender,"only owner can burn nft");
        _burn(tokenId);
        _totalSupply-=1;
        uint256 lastTokenIndex = ERC721.balanceOf(owner) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
         if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId2 = _ownedTokens[owner][lastTokenIndex];
            _ownedTokens[owner][tokenIndex] = lastTokenId2; 
            _ownedTokensIndex[lastTokenId2] = tokenIndex; 
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[owner][lastTokenIndex];
        // //delete alltoken
        uint256 lastTokenIndex1 = _allTokens.length - 1;
        uint256 tokenIndex1 = _allTokensIndex[tokenId];
 
        
        uint256 lastTokenId = _allTokens[lastTokenIndex1];
 
        _allTokens[tokenIndex1] = lastTokenId; 
        _allTokensIndex[lastTokenId] = tokenIndex1;
 
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
        // //emit Transfer(msg.sender,address(0),tokenId);

    }

    function totalSupply() external view returns (uint256) {
        // TODO 获取总mint的NFT的数量
        return _allTokens.length-1;

    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        // TODO 加分项：根据用户的index，获取tokenId
        require(index <ERC721.balanceOf(owner));
        return _ownedTokens[owner][index];

    }

    function tokenByIndex(uint256 index) external view returns (uint256) {
        // TODO 根据index获取全局的tokenId
        require(index<_totalSupply);
        return _allTokens[index];
    }
    
}

