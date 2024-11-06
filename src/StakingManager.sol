// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { IERC721Receiver } from '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import { Ownable2Step } from '@openzeppelin/contracts/access/Ownable2Step.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { RewardToken } from './RewardToken.sol';
import { LimitedEditionNFT } from './LimitedEditionNFT.sol';

/// @title Staking Manager for NFTs
/// @author Your Name
/// @notice This contract manages the staking of NFTs and distribution of rewards
/// @dev This contract implements IERC721Receiver to handle receiving NFTs
contract StakingManager is Ownable2Step, IERC721Receiver {
  LimitedEditionNFT public immutable nftContract;
  RewardToken public immutable rewardToken;

  mapping(uint256 => uint256) public stakings;
  uint256 public constant REWARD_PER_DAY = 10 * 1e18;

  event Staked(address indexed user, uint256 indexed tokenId);
  event UnStaked(address indexed user, uint256 indexed tokenId);

  error NoReward(uint256 availableReward);
  error NotOwner(address sender, address owner);
  error TokenAlreadyStaked(uint256 tokenId);
  error WrongNftContract(address sender, uint256 nftId);

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
    if (msg.sender != address(nftContract)) revert WrongNftContract(msg.sender, id);

    uint256 stakData = packData(from, block.timestamp);
    stakings[id] = stakData;
    emit Staked(from, id);

    return this.onERC721Received.selector;
  }

  /// @notice Deposits an NFT into the contract for staking
  /// @param tokenId The token ID of the NFT to stake
  function depositNFT(uint256 tokenId) external {
    if (stakings[tokenId] != 0) revert TokenAlreadyStaked(tokenId);
    address sender = msg.sender;

    uint256 data = packData(sender, block.timestamp);
    stakings[tokenId] = data;
    nftContract.transferFrom(sender, address(this), tokenId);
    emit Staked(sender, tokenId);
  }

  /// @notice Withdraws accumulated rewards for a staked NFT
  /// @param tokenId The token ID of the staked NFT
  function withdrawReward(uint256 tokenId) external {
    (address user, uint256 reward) = handleWithdraw(tokenId);
    if (reward == 0) revert NoReward(reward);

    stakings[tokenId] = packData(user, block.timestamp);
    rewardToken.mint(user, reward);
  }

  /// @notice Withdraws an NFT from staking and any accumulated rewards
  /// @param tokenId The token ID of the NFT to withdraw
  function withdrawNFT(uint256 tokenId) external {
    (address user, uint256 reward) = handleWithdraw(tokenId);
    delete stakings[tokenId];

    if (reward > 0) {
      rewardToken.mint(user, reward);
    }

    nftContract.safeTransferFrom(address(this), user, tokenId);
    emit UnStaked(user, tokenId);
  }

  /// @notice Checks the reward amount for a staked NFT
  /// @param tokenId The token ID of the staked NFT
  /// @return The amount of reward due
  function checkReward(uint256 tokenId) public view returns (uint256) {
    uint256 timestamp = uint256(uint96(stakings[tokenId]));

    if (timestamp > 0) {
      uint256 stakedTime = block.timestamp - timestamp;
      uint256 rewardPerSecond = (REWARD_PER_DAY * 1e18) / 1 days;
      return (stakedTime * rewardPerSecond) / 1e18;
    }

    return 0;
  }

  /// @notice Withdraws a staked NFT and calculates the reward
  /// @dev This function retrieves the staker's address and reward, checks if the caller is the owner, and calculates the reward based on the staking duration
  /// @param tokenId The token ID of the staked NFT
  /// @return user The address of the user who staked the NFT
  /// @return reward The calculated reward based on the staking duration
  function handleWithdraw(uint256 tokenId) private returns (address user, uint256 reward) {
    user = getStakUser(stakings[tokenId]);
    if (msg.sender != user) revert NotOwner(msg.sender, user);

    reward = checkReward(tokenId);
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
}
