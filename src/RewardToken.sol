// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { ERC20Burnable } from '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { Ownable2Step } from '@openzeppelin/contracts/access/Ownable2Step.sol';

/// @title Reward Token for decentralized rewards management
/// @author Evgenii Kireev
/// @notice This contract handles the creation and management of a reward token
/// @dev This contract extends ERC20 standard token functionality with burning capabilities and two-step ownership transfer
contract RewardToken is ERC20, Ownable2Step, ERC20Burnable {
  /// @dev Sets the initial owner to the address that deploys the contract
  constructor() ERC20('RewardToken', 'RTK') Ownable(msg.sender) {}

  /// @notice Allows the owner to mint new tokens
  /// @dev This function can only be called by the current owner
  /// @param to The address that will receive the minted tokens
  /// @param amount The amount of tokens to mint
  function mint(address to, uint256 amount) external onlyOwner {
    _mint(to, amount);
  }
}
