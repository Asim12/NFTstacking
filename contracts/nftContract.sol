
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// this a demon NFT
contract nftContract is Ownable, ERC721, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 public listingPrice = 0.002 ether;

    using Strings for uint256;
    string public baseURI;

    uint public MAX_SUPPLY;
    uint256 public totalSupply;    
    // end
    constructor(string memory name_, string memory symbol_, string memory baseURI_, uint256 _maxSupply) ERC721(name_, symbol_) {
        baseURI = baseURI_;
        MAX_SUPPLY = _maxSupply;
    }
    mapping(address => uint) balance; 

    function setBaseURI(string memory _newURI) external onlyOwner {
        baseURI = _newURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token.");
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    receive() external payable { }

    fallback() external payable {
    }

    function mintNFT() external payable {
        require(msg.value >= listingPrice, "ERC721: mint to the zero address");
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        require(totalSupply <= MAX_SUPPLY, "max supply reached");
        _safeMint(msg.sender, newItemId);
        totalSupply++;
    }

    function withdraw() public payable onlyOwner{  
        payable(msg.sender).transfer(address(this).balance);
    }
}
// 0xE615339Fed65A767e1700DE5Af746Ee8bf0bf8ca