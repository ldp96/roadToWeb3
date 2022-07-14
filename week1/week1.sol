// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//deployed at: 0x1Ca75Eb432eBa1271FcD19452B597C5DFc4004D2 rinkeby
import "@openzeppelin/contracts@4.7.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RoadTokens is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 constant MAX_SUPPLY = 100000;
    uint256 constant MAX_NFT = 5;
    mapping(address => uint256) nNFT;

    constructor() ERC721("RoadTokens", "RTK") {}

    function safeMint(address to, string memory uri) public {
        require(_tokenIds.current() <= MAX_SUPPLY, "I'm sorry we reached the cap");
        require(nNFT[msg.sender] < MAX_NFT,"Max number of NFTs reached!");
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        nNFT[msg.sender]++;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function setTokenURI (uint256 _tokenId, string memory _uri) public {
            require(_exists(_tokenId), "token does not exist");
            require(ownerOf(_tokenId) == msg.sender, "you're not the owner");
            _setTokenURI(_tokenId, _uri);
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
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
