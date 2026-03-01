// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title PixelArtNFT (最终版)
 * @dev 像素工坊专属NFT合约 - 完全免费，无供应限制
 * 功能：铸造、批量铸造、查询持有、销毁
 */
contract PixelArtNFT is ERC721, ERC721URIStorage, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // 事件：记录铸造信息
    event NFTMinted(address indexed to, uint256 indexed tokenId, string tokenURI);
    // 事件：记录销毁信息
    event NFTBurned(address indexed from, uint256 indexed tokenId);

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) Ownable(msg.sender) {
        // 完全免费的极简NFT合约
    }

    /**
     * @dev 任何人都可以免费铸造NFT
     * @param to 接收NFT的地址
     * @param uri tokenURI，通常是Base64编码的图片数据 (data:image/png;base64,...)
     */
    function mint(address to, string memory uri) public returns (uint256) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        emit NFTMinted(to, tokenId, uri);
        return tokenId;
    }

    /**
     * @dev 批量铸造多个NFT
     * @param to 接收NFT的地址
     * @param uris tokenURI数组
     */
    function mintBatch(address to, string[] memory uris) public {
        require(uris.length > 0, "Empty uris");

        for (uint i = 0; i < uris.length; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(to, tokenId);
            _setTokenURI(tokenId, uris[i]);
            emit NFTMinted(to, tokenId, uris[i]);
        }
    }

    /**
     * @dev 销毁NFT（本人或合约所有者均可）
     * @param tokenId 要销毁的token ID
     */
    function burn(uint256 tokenId) public {
        // 检查权限：必须是代币持有者或者是合约所有者
        require(
            _isAuthorized(_ownerOf(tokenId), msg.sender, tokenId) || owner() == msg.sender,
            "PixelArtNFT: caller is not owner nor approved nor contract owner"
        );
        
        address owner = _ownerOf(tokenId);
        _burn(tokenId);
        emit NFTBurned(owner, tokenId);
    }

    /**
     * @dev 批量销毁多个NFT（本人或合约所有者均可）
     * @param tokenIds 要销毁的token ID数组
     */
    function burnBatch(uint256[] memory tokenIds) public {
        require(tokenIds.length > 0, "Empty tokenIds");
        
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            // 每次单独检查权限（因为token可能属于不同所有者）
            require(
                _isAuthorized(_ownerOf(tokenId), msg.sender, tokenId) || owner() == msg.sender,
                "PixelArtNFT: caller is not owner nor approved nor contract owner"
            );
            
            address owner = _ownerOf(tokenId);
            _burn(tokenId);
            emit NFTBurned(owner, tokenId);
        }
    }

    /**
     * @dev 获取当前已铸造数量
     */
    function totalSupply() public view override(ERC721Enumerable) returns (uint256) {
        return _tokenIdCounter.current();
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}