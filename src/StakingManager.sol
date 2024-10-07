// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RewardToken} from "./RewardToken.sol";
import {LimitedEditionNFT} from "./LimitedEditionNFT.sol";

error NotOwner();
error NoReward();
error TokenAlreadyStaked();

/// @title Staking Manager for NFTs
/// @author Your Name
/// @notice This contract manages the staking of NFTs and distribution of rewards
/// @dev This contract implements IERC721Receiver to handle receiving NFTs
contract StakingManager is Ownable2Step, IERC721Receiver {
    LimitedEditionNFT public nftContract;
    RewardToken public rewardToken;

    mapping(uint256 => uint256) public stakings;
    uint256 public constant REWARD_PER_DAY = 10 * 1e18;

    bytes32 private constant STAKED_EVENT_HASH = 0x9e71bc8eea02a63969f509818f2dafb9254532904319f9dbda79b67bd34a5f3d;
    bytes32 private constant UNSTAKED_EVENT_HASH = 0x0f5bb82176feb1b5e747e28471aa92156a04d9f3ab9f45f28e2d704232b93f75;

    event Staked(address indexed user, uint256 indexed tokenId);
    event UnStaked(address indexed user, uint256 indexed tokenId);

    /// @notice Initializes the contract with specified NFT and reward token contracts
    /// @param _nftContract The NFT contract address
    /// @param _rewardToken The reward token contract address
    constructor(LimitedEditionNFT _nftContract, RewardToken _rewardToken) Ownable(msg.sender) {
        nftContract = _nftContract;
        rewardToken = _rewardToken;
    }

    /// @notice Accepts ownership of the reward token contract
    function acceptRewardTokenOwnership() external onlyOwner {
        rewardToken.acceptOwnership();
    }

    /// @notice Handles the receipt of an NFT
    /// @dev Required by the IERC721Receiver interface
    /// @param from The address sending the NFT
    /// @param id The token ID of the NFT
    /// @return selector to confirm receipt
    function onERC721Received(
        address,
        /* operator */
        address from,
        uint256 id,
        bytes calldata /* data */
    ) external override returns (bytes4) {
        require(msg.sender == address(nftContract), "wrong NFT");

        uint256 stakData = packData(from, block.timestamp);
        stakings[id] = stakData;
        emitStakeEvent(from, id, STAKED_EVENT_HASH);

        return this.onERC721Received.selector;
    }

    /// @notice Deposits an NFT into the contract for staking
    /// @param tokenId The token ID of the NFT to stake
    function depositNFT(uint256 tokenId) external {
        if (stakings[tokenId] != 0) revert TokenAlreadyStaked();
        address sender = msg.sender;

        uint256 data = packData(sender, block.timestamp);
        stakings[tokenId] = data;
        nftContract.transferFrom(sender, address(this), tokenId);
        emitStakeEvent(sender, tokenId, STAKED_EVENT_HASH);
    }

    /// @notice Withdraws accumulated rewards for a staked NFT
    /// @param tokenId The token ID of the staked NFT
    function withdrawReward(uint256 tokenId) external {
        address user = getStakUser(stakings[tokenId]);
        if (msg.sender != user) revert NotOwner();

        uint256 reward = checkReward(tokenId);
        if (reward < REWARD_PER_DAY) revert NoReward();

        stakings[tokenId] = packData(user, block.timestamp);
        rewardToken.mint(user, reward);
    }

    /// @notice Withdraws an NFT from staking and any accumulated rewards
    /// @param tokenId The token ID of the NFT to withdraw
    function withdrawNFT(uint256 tokenId) external {
        address user = getStakUser(stakings[tokenId]);
        if (msg.sender != user) revert NotOwner();

        uint256 reward = checkReward(tokenId);
        delete stakings[tokenId];

        if (reward > 0) {
            rewardToken.mint(user, reward);
        }

        nftContract.safeTransferFrom(address(this), user, tokenId);
        emitStakeEvent(user, tokenId, UNSTAKED_EVENT_HASH);
    }

    /// @notice Checks the reward amount for a staked NFT
    /// @param tokenId The token ID of the staked NFT
    /// @return The amount of reward due
    function checkReward(uint256 tokenId) public view returns (uint256) {
        uint256 timestamp = uint256(uint96(stakings[tokenId]));

        if (timestamp > 0) {
            uint256 stakedTime = block.timestamp - timestamp;
            return (stakedTime / 1 days) * REWARD_PER_DAY;
        }

        return 0;
    }

    /// @dev Packs the user address and timestamp into a single uint256
    /// @param user The address of the user
    /// @param timestamp The timestamp of the event
    /// @return The packed data
    function packData(address user, uint256 timestamp) private pure returns (uint256) {
        return (uint256(uint160(user)) << 96) | timestamp;
    }

    /// @dev Retrieves the user address from packed data
    /// @param data The packed data
    /// @return user The address of the user
    function getStakUser(uint256 data) private pure returns (address user) {
        return address(uint160(data >> 96));
    }

    /// @dev Emits a staking event
    /// @param user The user involved in the event
    /// @param tokenId The token ID involved in the event
    /// @param eventHash The hash of the event to emit
    function emitStakeEvent(address user, uint256 tokenId, bytes32 eventHash) private {
        assembly {
            mstore(0x00, user)
            mstore(0x20, tokenId)
            log1(0x00, 0x40, eventHash)
        }
    }
}
