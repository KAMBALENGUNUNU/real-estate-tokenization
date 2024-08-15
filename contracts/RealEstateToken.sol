// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing necessary libraries and contracts from OpenZeppelin and Chainlink
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; // ERC721 standard for NFTs
import "@openzeppelin/contracts/access/Ownable.sol"; // Provides basic authorization control functions
import "@openzeppelin/contracts/utils/math/SafeMath.sol"; // SafeMath library to prevent overflows and underflows
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // Protects against reentrancy attacks
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // Interface for Chainlink price feeds

contract RealEstateTokenization is ERC721, Ownable, ReentrancyGuard {
    using SafeMath for uint256; // Using SafeMath for uint256 arithmetic operations

    // Structure to hold property details
    struct Property {
        string propertyId; // Unique identifier for the property
        uint256 valuation; // Current valuation of the property
        uint256 rentCollected; // Total rent collected for the property
        address oracle; // Address of the Chainlink oracle for valuation updates
    }

    // Mapping from token ID to property details
    mapping(uint256 => Property) public properties;
    uint256 public nextTokenId; // Counter for the next token ID to be minted

    // Events to log important actions for transparency
    event PropertyTokenized(uint256 indexed tokenId, string propertyId, uint256 valuation);
    event RentDistributed(uint256 indexed tokenId, uint256 amount);
    event ValuationUpdated(uint256 indexed tokenId, uint256 newValuation);

    // Constructor to set the name and symbol of the ERC721 token
    constructor() ERC721("RealEstateToken", "RET") {}

    /**
     * @dev Function to mint a new property token.
     * @param _propertyId Unique identifier for the property being tokenized.
     * @param _initialValuation Initial valuation of the property.
     * @param _oracle Address of the Chainlink oracle to fetch property valuation.
     */
    function tokenizeProperty(string memory _propertyId, uint256 _initialValuation, address _oracle) 
        external onlyOwner {
        
        uint256 tokenId = nextTokenId; // Assigning the next token ID
        _safeMint(msg.sender, tokenId); // Minting the token to the owner's address
        properties[tokenId] = Property(_propertyId, _initialValuation, 0, _oracle); // Storing property details
        nextTokenId = nextTokenId.add(1); // Incrementing the token ID for the next property

        emit PropertyTokenized(tokenId, _propertyId, _initialValuation); // Emitting the PropertyTokenized event
    }

    /**
     * @dev Function to update property valuation using Chainlink oracle.
     * @param tokenId ID of the property token whose valuation is being updated.
     */
    function updateValuation(uint256 tokenId) external {
        Property storage property = properties[tokenId]; // Fetching property details
        AggregatorV3Interface priceFeed = AggregatorV3Interface(property.oracle); // Connecting to the Chainlink oracle
        (,int256 price,,,) = priceFeed.latestRoundData(); // Fetching the latest price data from the oracle
        uint256 newValuation = uint256(price); // Converting the price to uint256
        property.valuation = newValuation; // Updating the property valuation

        emit ValuationUpdated(tokenId, newValuation); // Emitting the ValuationUpdated event
    }

    /**
     * @dev Function to distribute rental income to token holders.
     * @param tokenId ID of the property token for which rent is being distributed.
     */
    function distributeRent(uint256 tokenId) external payable nonReentrant {
        Property storage property = properties[tokenId]; // Fetching property details
        uint256 rentPerShare = msg.value.div(totalSupply()); // Calculating rent per token holder
        
        // Looping through all tokens and distributing the rent
        for (uint256 i = 0; i < totalSupply(); i++) {
            address owner = ownerOf(i); // Fetching the owner of the token
            payable(owner).transfer(rentPerShare); // Transferring rent to the token owner
        }
        
        property.rentCollected = property.rentCollected.add(msg.value); // Updating the total rent collected
        emit RentDistributed(tokenId, msg.value); // Emitting the RentDistributed event
    }

    /**
     * @dev Fallback function to handle unexpected ETH transfers.
     * This function ensures the contract can receive ETH.
     */
    receive() external payable {}

    /**
     * @dev Function to retrieve details of a property.
     * @param tokenId ID of the property token.
     * @return propertyId, valuation, rentCollected, oracle
     */
    function getPropertyDetails(uint256 tokenId) 
        external view returns (string memory propertyId, uint256 valuation, uint256 rentCollected, address oracle) {
        
        Property storage property = properties[tokenId]; // Fetching property details
        return (property.propertyId, property.valuation, property.rentCollected, property.oracle); // Returning details
    }

    /**
     * @dev Function to transfer ownership of a property token.
     * This is overridden to ensure secure transfer of ownership.
     * @param from Current owner of the token.
     * @param to New owner of the token.
     * @param tokenId ID of the token being transferred.
     */
    function _transfer(address from, address to, uint256 tokenId) 
        internal override onlyOwner nonReentrant {
        
        super._transfer(from, to, tokenId); // Calling the parent function for transferring ownership
    }

    /**
     * @dev Function to check if a token exists.
     * @param tokenId ID of the token being checked.
     * @return exists
     */
    function tokenExists(uint256 tokenId) external view returns (bool exists) {
        return _exists(tokenId); // Returning true if the token exists, otherwise false
    }
}
