// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DutchAuction is Ownable {
    using SafeMath for uint256;

    struct Auction {
        address seller;
        uint256 tokenId;
        uint256 startPrice;
        uint256 reservePrice;
        uint256 startBlock;
        uint256 endBlock;
        bool active;
    }

    ERC721URIStorage public nftContract;
    uint256 public auctionCounter;
    mapping(uint256 => Auction) public auctions;

    event AuctionCreated(uint256 auctionId, address seller, uint256 tokenId, uint256 startPrice, uint256 reservePrice, uint256 endBlock);
    event AuctionCancelled(uint256 auctionId);
    event TicketPurchased(uint256 auctionId, address buyer, uint256 price);

    constructor(address _nftContract) {
        nftContract = ERC721URIStorage(_nftContract);
    }

    function createAuction(
        uint256 tokenId,
        uint256 startPrice,
        uint256 reservePrice,
        uint256 numBlocks
    ) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Only the owner can create an auction");
        require(startPrice > reservePrice, "Start price must be greater than reserve price");
        require(numBlocks > 0, "Number of blocks must be greater than zero");

        nftContract.transferFrom(msg.sender, address(this), tokenId);

        auctions[auctionCounter] = Auction({
            seller: msg.sender,
            tokenId: tokenId,
            startPrice: startPrice,
            reservePrice: reservePrice,
            startBlock: block.number,
            endBlock: block.number.add(numBlocks),
            active: true
        });

        emit AuctionCreated(auctionCounter, msg.sender, tokenId, startPrice, reservePrice, block.number.add(numBlocks));
        auctionCounter++;
    }

    function cancelAuction(uint256 auctionId) external {
        Auction storage auction = auctions[auctionId];
        require(auction.active, "Auction is not active");
        require(auction.seller == msg.sender, "Only the seller can cancel the auction");

        auction.active = false;
        nftContract.transferFrom(address(this), auction.seller, auction.tokenId);

        emit AuctionCancelled(auctionId);
    }

    function getCurrentPrice(uint256 auctionId) public view returns (uint256) {
        Auction storage auction = auctions[auctionId];
        require(auction.active, "Auction is not active");

        uint256 blocksPassed = block.number.sub(auction.startBlock);
        if (block.number >= auction.endBlock) {
            return auction.reservePrice;
        }

        uint256 priceDecrease = auction.startPrice.sub(auction.reservePrice).mul(blocksPassed).div(auction.endBlock.sub(auction.startBlock));
        return auction.startPrice.sub(priceDecrease);
    }

    function purchaseTicket(uint256 auctionId) external payable {
        Auction storage auction = auctions[auctionId];
        require(auction.active, "Auction is not active");

        uint256 currentPrice = getCurrentPrice(auctionId);
        require(msg.value >= currentPrice, "Insufficient funds sent");

        auction.active = false;
        nftContract.transferFrom(address(this), msg.sender, auction.tokenId);

        payable(auction.seller).transfer(msg.value);

        emit TicketPurchased(auctionId, msg.sender, currentPrice);
    }
}
