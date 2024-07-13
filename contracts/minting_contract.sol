// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EventTicket is ERC721URIStorage, Ownable {
    struct Ticket {
        uint256 price;
        uint256 eventId;
        string ticketType;
        uint256 amount;
    }

    mapping(uint256 => Ticket) public tickets;
    uint256 public nextTokenId;

    event TicketMinted(uint256 tokenId, address to, uint256 price, uint256 eventId, string ticketType, uint256 amount);
    event TicketPurchased(uint256 tokenId, address buyer, uint256 price);

    constructor() ERC721("EventTicket", "ETK") {}

    function mintTicket(
        address to,
        uint256 price,
        uint256 eventId,
        string memory ticketType,
        uint256 amount,
        string memory tokenURI
    ) external onlyOwner {
        uint256 tokenId = nextTokenId;
        tickets[tokenId] = Ticket(price, eventId, ticketType, amount);
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        emit TicketMinted(tokenId, to, price, eventId, ticketType, amount);
        nextTokenId++;
    }

    function getTicketDetails(uint256 tokenId) external view returns (Ticket memory) {
        require(_exists(tokenId), "Ticket does not exist");
        return tickets[tokenId];
    }

    function updateTicketDetails(
        uint256 tokenId,
        uint256 newPrice,
        uint256 newEventId,
        string memory newTicketType,
        uint256 newAmount
    ) external onlyOwner {
        require(_exists(tokenId), "Ticket does not exist");
        tickets[tokenId] = Ticket(newPrice, newEventId, newTicketType, newAmount);
    }

    function purchaseTicket(uint256 tokenId) external payable {
        require(_exists(tokenId), "Ticket does not exist");
        Ticket storage ticket = tickets[tokenId];
        require(ticket.amount > 0, "No tickets available");
        require(msg.value == ticket.price, "Incorrect value sent");

        ticket.amount--;
        _safeTransfer(owner(), msg.sender, tokenId, "");

        emit TicketPurchased(tokenId, msg.sender, ticket.price);
    }

    function getTicketPrice(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Ticket does not exist");
        return tickets[tokenId].price;
    }

    function getTicketAmount(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Ticket does not exist");
        return tickets[tokenId].amount;
    }
}
