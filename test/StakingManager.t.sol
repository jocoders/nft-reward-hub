// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test, console } from 'forge-std/Test.sol';
import { StakingManager } from '../src/StakingManager.sol';
import { LimitedEditionNFT } from '../src/LimitedEditionNFT.sol';
import { RewardToken } from '../src/RewardToken.sol';

contract StakingManagerTest is Test {
  address alice = address(0x1);
  address bob = address(0x2);
  address zeroAddress = address(0x0);

  uint256 private constant REWARD_PER_DAY = 10 * 1e18;

  StakingManager public manager;
  LimitedEditionNFT public tokenNFT;
  RewardToken public tokenReaward;

  error InvalidAddress();
  error MaxSupplyReached();
  error InsufficientFunds();
  error NoReward();
  error NotOwner();

  event Staked(address indexed user, uint256 indexed tokenId);
  event Unstaked(address indexed user, uint256 indexed tokenId);

  function setUp() public {
    uint256 basePrice = 9999 gwei;
    uint256 discountPrice = 7777 gwei;
    bytes32 merkleRoot = 0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0;

    tokenNFT = new LimitedEditionNFT(basePrice, discountPrice, merkleRoot);
    tokenReaward = new RewardToken();
    manager = new StakingManager(tokenNFT, tokenReaward);

    vm.deal(alice, 100 ether);
    vm.deal(bob, 10 ether);
  }

  function testAcceptRewardTokenOwnership() public {
    tokenReaward.transferOwnership(address(manager));
    manager.acceptRewardTokenOwnership();

    address newOwner = tokenReaward.owner();
    assertEq(newOwner, address(manager), 'StakingManager should be the new owner of RewardToken');
  }

  function testAliceSuccessMintNFT() public {
    tokenNFT.mint{ value: 9999 gwei }(alice);
    uint256 aliceNftBalanceAfter = tokenNFT.balanceOf(alice);
    assertEq(aliceNftBalanceAfter, 1, 'Alice should have 1 NFT');
  }

  function testAliceAndBobSuccessMintNFT() public {
    tokenNFT.mint{ value: 9999 gwei }(alice);
    uint256 aliceNftBalanceAfter = tokenNFT.balanceOf(alice);

    assertEq(aliceNftBalanceAfter, 1, 'Alice should have 1 NFT');
    assertEq(tokenNFT.remainingSupply(), 999, 'Remaining supply should be 998');

    tokenNFT.mint{ value: 9999 gwei }(bob);
    tokenNFT.mint{ value: 9999 gwei }(bob);
    uint256 bobNftBalanceAfter = tokenNFT.balanceOf(bob);
    assertEq(bobNftBalanceAfter, 2, 'Bob should have 1 NFT');
    assertEq(tokenNFT.remainingSupply(), 997, 'Remaining supply should be 996');
  }

  function testBobSuccessMercleMintNFT() public {
    uint256 aliceNftBalanceBefore = tokenNFT.balanceOf(alice);
    tokenNFT.mint{ value: 9999 gwei }(alice);
    uint256 aliceNftBalanceAfter = tokenNFT.balanceOf(alice);
    assertEq(aliceNftBalanceAfter, 1, 'Alice should have 1 NFT');
  }

  function testInsufficientFundsMintNFT() public {
    for (uint256 i = 0; i < 1000; i++) {
      tokenNFT.mint{ value: 9999 gwei }(alice);
    }

    uint256 aliceNftBalanceAfter = tokenNFT.balanceOf(alice);
    vm.expectRevert(abi.encodeWithSelector(MaxSupplyReached.selector));
    tokenNFT.mint{ value: 9999 gwei }(bob);
  }

  function testInvalidAddressRevert() public {
    vm.expectRevert(abi.encodeWithSelector(InvalidAddress.selector));
    tokenNFT.mint{ value: 9999 gwei }(address(0));
  }

  function testMaxSupplyReachedMintNFT() public {
    vm.expectRevert(abi.encodeWithSelector(InsufficientFunds.selector));
    tokenNFT.mint{ value: 1 gwei }(alice);
  }

  function testSuccessWithdraw() public {
    uint256 currentBalance = address(this).balance;
    tokenNFT.mint{ value: 9999 gwei }(alice);
    tokenNFT.mint{ value: 9999 gwei }(bob);
    tokenNFT.mint{ value: 9999 gwei }(bob);

    address payable payableAddr = payable(address(this));
    try tokenNFT.withdraw(payableAddr, 9999 gwei) {
      uint256 newBalance = address(this).balance;
      assertEq(newBalance, currentBalance + 9999 gwei, 'Balance should be 9999 gwei');
    } catch (bytes memory lowLevelData) {
      console.log('Withdraw failed with data', string(lowLevelData));
    }
  }

  function testBobSuccessDepositTwoNFT() public {
    uint256 nftId_1 = 1000;
    uint256 nftId_2 = 999;

    tokenNFT.mint{ value: 9999 gwei }(bob);
    tokenNFT.mint{ value: 9999 gwei }(bob);

    vm.startPrank(bob);
    tokenNFT.approve(address(manager), nftId_1);
    manager.depositNFT(nftId_1);

    tokenNFT.approve(address(manager), nftId_2);
    manager.depositNFT(nftId_2);
    vm.stopPrank();

    uint256 stak_1 = manager.stakings(nftId_1);
    uint256 stak_2 = manager.stakings(nftId_2);
    uint256 bobNftBalance = tokenNFT.balanceOf(bob);

    assertNotEq(stak_1, 0, 'Stak should not be 0');
    assertNotEq(stak_2, 0, 'Stak should not be 0');
    assertEq(bobNftBalance, 0, 'Bob should not have NFT');
  }

  function testAliceSuccessDepositNFT() public {
    uint256 nftId = 1000;
    tokenNFT.mint{ value: 9999 gwei }(alice);

    vm.startPrank(alice);
    tokenNFT.approve(address(manager), nftId);

    manager.depositNFT(nftId);
    vm.stopPrank();

    uint256 stak = manager.stakings(nftId);
    uint256 aliceNftBalance = tokenNFT.balanceOf(alice);

    assertNotEq(stak, 0, 'Stak should not be 0');
    assertEq(aliceNftBalance, 0, 'Alice should not have NFT');
  }

  function testAliceCheckReward() public {
    uint256 nftId_1 = 1000;
    uint256 nftId_2 = 999;

    tokenNFT.mint{ value: 9999 gwei }(alice);
    tokenNFT.mint{ value: 9999 gwei }(alice);

    vm.startPrank(alice);
    tokenNFT.approve(address(manager), nftId_1);
    tokenNFT.approve(address(manager), nftId_2);
    manager.depositNFT(nftId_1);
    manager.depositNFT(nftId_2);
  }

  function testAliceZeroCheckReward() public {
    uint256 nftId = 1000;
    tokenNFT.mint{ value: 9999 gwei }(alice);
    vm.startPrank(alice);
    uint256 reward = manager.checkReward(nftId);
    assertEq(reward, 0, 'Reward should be 0');
    vm.stopPrank();
  }

  function testBobWithdrawReward() public {
    testAcceptRewardTokenOwnership();
    uint256 nftId = 1000;
    tokenNFT.mint{ value: 9999 gwei }(bob);

    vm.startPrank(bob);
    tokenNFT.approve(address(manager), nftId);
    manager.depositNFT(nftId);
    vm.warp(block.timestamp + 3 days);

    uint256 reward = manager.checkReward(nftId);
    assertEq(reward, REWARD_PER_DAY * 3, 'Reward should be 30000000000000000000');

    manager.withdrawReward(nftId);
    uint256 rewardAfter = manager.checkReward(nftId);
    assertEq(rewardAfter, 0, 'Reward should be 0');
    vm.stopPrank();

    uint256 bobRewardBalance = tokenReaward.balanceOf(bob);
    assertEq(bobRewardBalance, reward, 'Bob should have reward');
  }

  function testAliceRevertWithdrawReward() public {
    testAcceptRewardTokenOwnership();
    uint256 nftId = 1000;
    tokenNFT.mint{ value: 9999 gwei }(alice);

    vm.startPrank(alice);
    tokenNFT.approve(address(manager), nftId);
    manager.depositNFT(nftId);
    vm.warp(block.timestamp + 120 minutes);

    uint256 reward = manager.checkReward(nftId);
    assertEq(reward, 0, 'Reward should be 0');

    vm.expectRevert(abi.encodeWithSelector(NoReward.selector));
    manager.withdrawReward(nftId);
    vm.stopPrank();
  }

  function testBobRevertWithdrawReward() public {
    testAcceptRewardTokenOwnership();
    uint256 nftId = 1000;
    tokenNFT.mint{ value: 9999 gwei }(alice);

    vm.startPrank(alice);
    tokenNFT.approve(address(manager), nftId);
    manager.depositNFT(nftId);
    vm.stopPrank();

    vm.warp(block.timestamp + 2 days);

    vm.startPrank(bob);
    vm.expectRevert(abi.encodeWithSelector(NotOwner.selector));
    manager.withdrawReward(nftId);
    vm.stopPrank();
  }

  function testBobWithRewardWithdrawNFT() public {
    testAcceptRewardTokenOwnership();
    uint256 nftId = 1000;
    tokenNFT.mint{ value: 9999 gwei }(bob);

    vm.startPrank(bob);
    tokenNFT.approve(address(manager), nftId);
    manager.depositNFT(nftId);
    vm.warp(block.timestamp + 3 days);
    uint256 reward = manager.checkReward(nftId);
    assertEq(reward, REWARD_PER_DAY * 3, 'Reward should be 30000000000000000000');

    manager.withdrawNFT(nftId);
    vm.stopPrank();

    uint256 bobNftBalance = tokenNFT.balanceOf(bob);
    assertEq(bobNftBalance, 1, 'Bob should have 1 NFT');

    uint256 bobTokenRewardBalance = tokenReaward.balanceOf(bob);
    assertEq(bobTokenRewardBalance, reward, 'Bob should have reward');
  }

  function testAlicNoRewardWithdrawNFT() public {
    testAcceptRewardTokenOwnership();
    uint256 nftId = 1000;
    tokenNFT.mint{ value: 9999 gwei }(alice);

    vm.startPrank(alice);
    tokenNFT.approve(address(manager), nftId);
    manager.depositNFT(nftId);
    vm.warp(block.timestamp + 200 minutes);
    uint256 reward = manager.checkReward(nftId);
    assertEq(reward, 0, 'Reward should be 0');

    manager.withdrawNFT(nftId);
    vm.stopPrank();

    uint256 aliceNftBalance = tokenNFT.balanceOf(alice);
    assertEq(aliceNftBalance, 1, 'ALice should have 1 NFT');

    uint256 aliceTokenRewardBalance = tokenReaward.balanceOf(alice);
    assertEq(aliceTokenRewardBalance, 0, 'Alice should not have reward');
  }
}
