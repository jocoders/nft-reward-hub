// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

error AlreadyMinted();
error InvalidProofCheck();
error InvalidProofParams();

/// @title Limited Edition NFT Contract
/// @author Evgenii Kireev
/// @notice This contract manages the minting and distribution of limited edition NFTs with optional discount via Merkle proof
/// @dev This contract extends ERC721, ERC2981 for NFT functionality and royalties, and Ownable2Step for enhanced ownership control
contract LimitedEditionNFT is Ownable2Step, ERC721, ERC2981 {
    uint256 public immutable basePrice;
    uint256 public immutable discountPrice;
    uint256 public remainingSupply = 1000;

    bytes32 private merkleRoot;
    mapping(uint256 => uint256) private discountBitmap;

    /// @notice Validates the minting conditions before proceeding
    /// @dev Checks for zero address, supply limits, and sufficient payment
    /// @param to The address of the recipient
    /// @param price The price at which the NFT is being minted
    modifier validateMint(address to, uint256 price) {
        assembly {
            if iszero(to) {
                let InvalidAddressSelector := 0x4b1b2ee7
                mstore(0x00, InvalidAddressSelector)
                revert(0x00, 0x04)
            }
            if lt(sload(remainingSupply.slot), 1) {
                let MaxSupplyReachedSelector := 0xd05cb609
                mstore(0x00, MaxSupplyReachedSelector)
                revert(0x00, 0x04)
            }
            if lt(callvalue(), price) {
                let InsufficientFundsSelector := 0x356680b7
                mstore(0x00, InsufficientFundsSelector)
                revert(0x00, 0x04)
            }
        }
        _;
    }

    /// @notice Constructor to create LimitedEditionNFT
    /// @dev Sets the base price, discount price, and the Merkle root for discount eligibility
    /// @param _basePrice The base price for each NFT
    /// @param _discountPrice The discounted price for eligible addresses
    /// @param _merkleRoot The root of the Merkle tree used for verifying discount eligibility
    constructor(uint256 _basePrice, uint256 _discountPrice, bytes32 _merkleRoot)
        Ownable(msg.sender)
        ERC721("LimitedEditionNFT", "LENFT")
    {
        basePrice = _basePrice;
        discountPrice = _discountPrice;
        merkleRoot = _merkleRoot;
        _setDefaultRoyalty(msg.sender, 250);
    }

    /// @notice Mints a new NFT to an address with a potential discount if eligible
    /// @dev Requires a valid Merkle proof to claim discount
    /// @param to The address of the recipient
    /// @param merkleProof A list of bytes32 hashes that are used to verify discount eligibility
    function mint(address to, bytes32[] calldata merkleProof) external payable validateMint(to, discountPrice) {
        if (merkleProof.length < 1) revert InvalidProofParams();

        bytes32 leaf = keccak256(abi.encodePacked(to));
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) revert InvalidProofCheck();

        uint256 uintAddress = uint256(uint160(to));
        uint256 index = uintAddress / 256;
        uint256 bit = uint256(1) << (uintAddress % 256);

        bool isDiscountClaimed = discountBitmap[index] & bit != 0;
        if (isDiscountClaimed) revert AlreadyMinted();

        discountBitmap[index] |= bit;
        _mintNFT(to);
    }

    /// @notice Mints a new NFT to an address at the base price
    /// @param to The address of the recipient
    function mint(address to) external payable validateMint(to, basePrice) {
        _mintNFT(to);
    }

    /// @notice Allows the owner to withdraw funds from the contract
    /// @param to The address to which the funds will be sent
    /// @param amount The amount of funds to withdraw
    function withdraw(address payable to, uint256 amount) external onlyOwner {
        assembly {
            let success := call(gas(), to, amount, 0, 0, 0, 0)

            if iszero(success) {
                let widhdrawFailedSelector := 0x2e49dd2f

                mstore(0x00, widhdrawFailedSelector)
                revert(0x00, 0x04)
            }
        }

        (bool success,) = to.call{value: amount}("");
        require(success, "Withdraw failed");
    }

    /// @notice Checks if the contract supports a specific interface
    /// @dev Overrides the supportsInterface function to check for ERC721 and ERC2981 interface support
    /// @param interfaceId The interface identifier to check
    /// @return bool indicating support of the interface
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }

    /// @dev Internal function to mint an NFT
    /// @param to The address of the recipient
    function _mintNFT(address to) private {
        _mint(to, remainingSupply);
        unchecked {
            --remainingSupply;
        }
    }
}
