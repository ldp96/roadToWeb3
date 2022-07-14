// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//deployed at: 0x0E93Eeb1C28Fdbe3039095A2934c04Bfbd35b145 goerli
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
