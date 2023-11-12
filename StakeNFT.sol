// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakeNFT is ERC721, Ownable {
    uint256 private nextTokenId;
    string private URI;

    constructor(address _initialOwner, string memory _name, string memory _symbol, string memory _tokenURI)
        ERC721(_name, _symbol)
        Ownable(_initialOwner)
    {
        URI = string.concat("ips://", _tokenURI);
    }

    function _baseURI() internal view override returns (string memory) {
        return URI;
    }

    function safeMint(address _to) virtual public onlyOwner returns(uint256) {
        require(balanceOf(_to) == 0, string.concat(name(), " NFT for user already minted!"));

        uint256 tokenId = nextTokenId++;
        _safeMint(_to, tokenId);

        return tokenId;
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }
}