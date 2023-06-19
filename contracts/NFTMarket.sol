// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;

    //counters change the state of variables in blockchain
    Counters.Counter private _itemIds;
    Counters.Counter private _itemSold;

    //current owner of each particular NFT
    address payable owner;
    //Price paid by creator to list an NFT to the market place
    uint256 listingPrice = 0.01 ether;

    //to initialize present owner of an NFT 
    constructor(){
        owner = payable(msg.sender);
    }

    struct marketItem{
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        //external account who wants to sell nft on this platform
        address payable seller;
        //present owner of item/NFT that is listed
        address payable owner;
        uint256 price;
        bool sold;      
    }  
    //maps tokenID to market item
    mapping(uint256 => marketItem) private idtoMarketItem;

    event marketItemCreated(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address indexed nftContract,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    //price to be paid to list an NFT
    function getListingPrice() public view returns(uint256)
    {
        return listingPrice;
    }

    //To place NFT in the market 
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant{
        require(price > 0,"Please set price equal to atleast 1 wei");
        require(msg.value == listingPrice,"Please pay the required listing Price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idtoMarketItem[itemId] = marketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender,address(this),tokenId);

        emit marketItemCreated(itemId, tokenId, nftContract, msg.sender, address(0), price, false);

    }

    function createMarketSale(
        address nftContract,
        uint256 itemId
    ) public payable nonReentrant{
        uint256 price = idtoMarketItem[itemId].price;
        uint256 tokenId = idtoMarketItem[itemId].tokenId;
        require(msg.value == price,"Please pay the required price to complete the order");

        idtoMarketItem[itemId].seller.transfer(msg.value);

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        idtoMarketItem[itemId].owner = payable(msg.sender);
        idtoMarketItem[itemId].sold = true;

        _itemSold.increment();
        payable(owner).transfer(listingPrice); 

    }

    function fetchMarketItems() public view returns(marketItem[] memory)
    {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount= _itemIds.current() - _itemSold.current();
        uint currentIndex = 0;

        marketItem[] memory items = new marketItem[](unsoldItemCount);

        for(uint i=0;i<itemCount;i++){
            if(idtoMarketItem[i+1].owner == address(0)){
                uint currentId = idtoMarketItem[i+1].itemId;
                marketItem storage currentItem = idtoMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }

    function fetctMyNFTs() public view returns(marketItem[] memory)
    {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for(uint i=0;i<totalItemCount;i++)
        {
            if(idtoMarketItem[i+1].owner == msg.sender)
                itemCount++;
        }
        marketItem[] memory items = new marketItem[](itemCount);
        for(uint i=0;i<totalItemCount;i++)
        {
            if(idtoMarketItem[i+1].owner == msg.sender)
            {
                uint currentId = i+1;
                marketItem storage currentItem = idtoMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }

    function fetchItemsCreated() public view returns(marketItem[] memory)
    {
        uint totalItemCount = _itemIds.current();
        uint currentIndex = 0;
        uint itemCount = 0;

        for(uint i=0;i<totalItemCount;i++)
        {
            if(idtoMarketItem[i+1].seller == msg.sender)
                itemCount++;
        }

        marketItem[] memory items = new marketItem[](itemCount);
        for(uint i=0;i< totalItemCount;i++)
        {
            if(idtoMarketItem[i+1].seller == msg.sender)
            {
                uint currentId = i+1;
                marketItem storage currentItem = idtoMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }

}