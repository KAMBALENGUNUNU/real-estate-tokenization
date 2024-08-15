# Real Estate Tokenization Platform

## Overview
This project is a decentralized real estate tokenization platform built on the Ethereum blockchain. The platform allows properties to be tokenized into ERC-721 tokens (NFTs), enabling fractional ownership, dynamic valuation updates using Chainlink oracles, and rental income distribution to token holders.

## Smart Contract: RealEstateTokenization.sol

### Key Features:
1. **Tokenization of Properties**:
   - Properties are tokenized into NFTs (ERC-721 tokens) with unique identifiers.
   - Each property has an associated valuation, oracle address, and rent collection record.

2. **Dynamic Valuation**:
   - The `updateValuation` function uses Chainlink oracles to fetch and update the property’s valuation in real-time.
   - This ensures that the property value reflects market conditions.

3. **Rental Income Distribution**:
   - The `distributeRent` function allows rental income to be distributed to all token holders based on their shares.
   - The `nonReentrant` modifier ensures the function is protected against reentrancy attacks.

4. **Safe and Transparent Operations**:
   - SafeMath is used to prevent overflows and underflows in arithmetic operations.
   - Events are emitted for key actions such as property tokenization, rent distribution, and valuation updates, ensuring transparency.

5. **Ownership and Transfer**:
   - Ownership is managed securely, and only the owner of the contract can mint new tokens.
   - The `_transfer` function is overridden to enforce additional security measures during token transfers.

6. **Fallback Function**:
   - The `receive()` function ensures the contract can accept ETH transfers, which may be required for rental income distribution or other payments.

7. **Compliance and Modular Design**:
   - The contract is modular and can be extended with additional features like voting systems, marketplace integration, and more.

### Contract Structure:
- **Property Struct**: Holds property details such as ID, valuation, rent collected, and oracle address.
- **Events**: `PropertyTokenized`, `RentDistributed`, and `ValuationUpdated` are emitted to log key actions.
- **Functions**:
  - `tokenizeProperty`: Mint new property tokens.
  - `updateValuation`: Fetch and update the property’s valuation using Chainlink oracles.
  - `distributeRent`: Distribute rental income to token holders.
  - `getPropertyDetails`: Retrieve details of a property.
  - `_transfer`: Secure transfer of ownership.
  - `tokenExists`: Check if a token exists.
  - `receive`: Handle unexpected ETH transfers.

## Getting Started
### Prerequisites
- Node.js
- Truffle or Hardhat
- Ganache or any Ethereum client
- MetaMask

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/KAMBALENGUNUNU/real-estate-tokenization.git
