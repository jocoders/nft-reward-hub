# LimitedEditionNFT | RewardToken | StakingManager

**Overview**

This project comprises a trio of smart contracts designed to interact within an NFT and token staking ecosystem. The `LimitedEditionNFT` contract manages a collection of 1000 unique NFTs with a built-in royalty system and discount mechanism for addresses verified through a Merkle tree. The `RewardToken` is an ERC20 token used for rewarding NFT stakers. The `StakingManager` contract handles the staking of NFTs and the distribution of ERC20 rewards.

**Features**

- **NFT Minting with Discounts**: Eligible addresses can mint NFTs at a discounted rate using a Merkle proof.
- **Royalty Implementation**: Implements ERC2981 to provide a 2.5% royalty on secondary sales.
- **Staking Mechanism**: Users can stake NFTs to earn ERC20 tokens, accruing rewards over time which can be claimed periodically.
- **Ownership and Withdrawal**: Implements `Ownable2Step` for secure ownership transfer and allows the owner to withdraw funds.

**Technology**

The contracts are built on Solidity 0.8.20 and utilize OpenZeppelin's libraries for standard compliant, secure, and tested implementations of ERC721, ERC2981, and ERC20 tokens. The staking mechanism is optimized for gas efficiency and security.

**Getting Started**

**Prerequisites**

- Node.js and npm
- Foundry (for local deployment and testing)

**Installation**

1. Install Foundry if it's not already installed:

   ```
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. Clone the repository:

   ```
   git clone https://github.com/jocoders/nft-reward-hub.git
   cd nft-reward-hub
   ```

3. Install dependencies:

   ```
   forge install
   ```

**Testing**

Run tests using Foundry:

```
forge test
```

**Usage**

**Deploying the Contracts**

Deploy the contracts to a local blockchain using Foundry:

```
forge create LimitedEditionNFT --rpc-url http://localhost:8545
forge create RewardToken --rpc-url http://localhost:8545
forge create StakingManager --rpc-url http://localhost:8545
```

**Interacting with the Contracts**

**Mint an NFT**

```
LimitedEditionNFT.mint(address to, bytes32[] calldata merkleProof)
```

**Stake an NFT**

```
StakingManager.depositNFT(uint256 tokenId)
```

**Claim Rewards**

```
StakingManager.withdrawReward(uint256 tokenId)
```

**Contributing**

Contributions are welcome! Please fork the repository and open a pull request with your features or fixes.

**License**

This project is unlicensed and free for use by anyone.
