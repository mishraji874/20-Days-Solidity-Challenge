// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint256 public royaltyPercentage = 10;

    struct NFT {
        address creator;
        uint256 price;
    }

    mapping(uint256 => NFT) public nftsForSale;
    mapping(uint256 => uint256) public currentBid;
    mapping(uint256 => address) public currentBidder;

    event NFTMinted(uint256 indexed tokenId, address indexed creator, uint256 price);
    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
    event NFTBidPlaced(uint256 indexed tokenId, address indexed bidder, uint256 indexed bidAmount);
    event NFTBidWithdrawn(uint256 indexed tokenId, address indexed bidder, uint256 bidAmount);
    event NFTAuctionEnded(uint256 indexed tokenId, address indexed winner, uint256 winningBid);

    constructor() ERC721("NFTMarketplace", "NFTM") {}

    //mint anew NFT
    function mintNFT() external {
        uint256 tokenId = _tokenIdCounter.current();            
        _mint(msg.sender, tokenId);
        _tokenIdCounter.increment();
        emit NFTMinted(tokenId, msg.sender, 0);
    }

    //list an NFT for sale
    function listNFTForSale(uint256 tokenId, uint256 price) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        nftsForSale[tokenId] = NFT(msg.sender, price);
        emit NFTListed(tokenId, price);
    }

    //buy and NFT
    function buyNFT(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        NFT memory nft = nftsForSale[tokenId];
        require(nft.price > 0, "Token is not for sale");
        require(msg.value >= nft.price, "Insufficient funds");
        address seller = nft.creator;
        nftsForSale[tokenId] = NFT(address(0), 0);
        _safeTransfer(seller, msg.sender, tokenId,"");
        payable(seller).transfer(msg.value);
        emit NFTSold(tokenId, seller, msg.sender, nft.price);
    }

    //place a bid on an NFT auction
    function placeBid(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        NFT memory nft = nftsForSale[tokenId];
        require(nft.price == 0, "Token is not for auction");
        require(msg.value > currentBid[tokenId], "Bid must be higher than the current bid");
        if (currentBidder[tokenId] != address(0)) {
            payable(currentBidder[tokenId]).transfer(currentBid[tokenId]);
        }
        currentBid[tokenId] = msg.value;
        currentBidder[tokenId] = msg.sender;
        emit NFTBidPlaced(tokenId, msg.sender, msg.value);
    }

    //withdraw a bid from an NFt auction
    function withdrawBid(uint256 tokenId) external {
        require(_exists(tokenId), "Token does not exists");
        require(msg.sender == currentBidder[tokenId], "You did not place the current bid");
        uint256 bidAmount = currentBid[tokenId];
        require(bidAmount > 0, "No active bid");
        currentBid[tokenId] = 0;
        currentBidder[tokenId] = address(0);
        payable(msg.sender).transfer(bidAmount);
        emit NFTBidWithdrawn(tokenId, msg.sender, bidAmount);
    }

    //end an NFT auction and transfer the NFt to tthe highest bidder
    function endAuction(uint256 tokenId) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        NFT memory nft = nftsForSale[tokenId];
        require(nft.price == 0, "Token is not for auction");
        require(currentBid[tokenId] > 0, "No active bid");
        address winner = currentBidder[tokenId];
        uint256 winningBid = currentBid[tokenId];
        currentBid[tokenId] = 0;
        currentBidder[tokenId] = address(0);
        _safeTransfer(nft.creator, winner, tokenId, "");
        payable(nft.creator).transfer(winningBid);
        emit NFTAuctionEnded(tokenId, winner, winningBid);
    }

    //set the royalty percentage for creators
    function setRoyaltyPercentage(uint256 percentage) external onlyOwner {
        require(percentage <= 100, "Percentage must be <= 100");
        royaltyPercentage = percentage;
    }

    //withdraw royalties earned by the creator
    function withdrawRoyalties() external {
        uint256 balance = address(this).balance;
        uint256 royalties = (balance * royaltyPercentage) / 100;
        payable(owner()).transfer(royalties);
    }

    //override _baseURI to provider metadata for NFTs
    function _baseURI() internal view override returns (string memory) {
        return "https://your-metadata-api.com/api/token/";
    }
}