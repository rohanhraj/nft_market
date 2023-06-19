// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract NFT is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter  private  _tokenIds;
    address ContractAddress;

    constructor(address marketPlaceAddress) ERC721("BeatHood","BEAT")
    {
        ContractAddress = marketPlaceAddress;
    }

    function createToken(string memory tokenURI) public returns(uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(ContractAddress, true);
        return newItemId;
    }
}