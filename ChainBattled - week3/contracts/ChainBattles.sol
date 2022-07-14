// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//../node_modules/
//deployed at: 0x3eC53d7E033662498881063E7CBde8A813910998 mumbai
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Strings for uint8;
    using Counters for Counters.Counter; 
    Counters.Counter private _tokenIds;

    struct Attributes{
        uint8 level;
        uint8 speed;
        uint8 strength;
        uint8 life;
    }

    mapping(uint256 => Attributes) public tokenIdToData;

    constructor() ERC721 ("Chain Battles", "CBTLS"){}

    function generateCharacter(uint256 tokenId) public view returns(string memory){

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getSpeed(tokenId),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getStrength(tokenId),'</text>',
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",getLife(tokenId),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }
    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToData[tokenId].level;
        return levels.toString();
    }
    function getSpeed(uint256 tokenId) public view returns (string memory) {
        uint8 speed = tokenIdToData[tokenId].speed;
        return speed.toString();
    }
    function getStrength(uint256 tokenId) public view returns (string memory) {
        uint8 strength = tokenIdToData[tokenId].strength;
        return strength.toString();
    }
    function getLife(uint256 tokenId) public view returns (string memory) {
        uint8 life = tokenIdToData[tokenId].life;
        return life.toString();
    }
    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        tokenIdToData[newItemId].level = 0;
        tokenIdToData[newItemId].speed = 0;
        tokenIdToData[newItemId].strength = 0;
        tokenIdToData[newItemId].life = 100;


        _setTokenURI(newItemId, getTokenURI(newItemId));
    }
     function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");
        require(tokenIdToData[tokenId].life>0, "your token can't be trained anymore");
        tokenIdToData[tokenId].level++;
        tokenIdToData[tokenId].speed++;
        tokenIdToData[tokenId].strength++;
        tokenIdToData[tokenId].life--;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
