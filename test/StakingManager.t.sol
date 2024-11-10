// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StakingManager} from "../src/StakingManager.sol";
import {LimitedEditionNFT} from "../src/LimitedEditionNFT.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {Merkle} from "../src/Merkle.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC1967} from "@openzeppelin/contracts/interfaces/IERC1967.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract StakingManagerTest is Test {
    bytes32 public merkleRoot;
    bytes32[] public leaves;
    StakingManager public manager;
    LimitedEditionNFT public nft;
    RewardToken public rewardToken;
    Merkle public merkle;

    address alice = address(0x1);
    address bob = address(0x2);
    address jo = address(0x55);
    address zeroAddress = address(0x0);

    uint256 private constant BASE_PRICE = 9999 gwei;
    uint256 private constant DISCOUNT_PRICE = 7777 gwei;
    uint256 public constant REWARD_PER_SECOND = 115_740_000_000_000;

    event Staked(address indexed user, uint256 indexed tokenId);
    event UnStaked(address indexed user, uint256 indexed tokenId);

    function setUp() public {
        merkle = new Merkle();
        leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(jo));

        merkleRoot = merkle.getRoot(leaves);

        nft = new LimitedEditionNFT(BASE_PRICE, DISCOUNT_PRICE, merkleRoot);
        rewardToken = new RewardToken();
        manager = new StakingManager(nft, rewardToken);

        vm.deal(alice, 100 ether);
        vm.deal(bob, 10 ether);
    }

    function testConstructor() public {
        StakingManager managerTest = new StakingManager(nft, rewardToken);
        assertEq(address(managerTest.nftContract()), address(nft), "NftContract should be initialized");
        assertEq(address(managerTest.rewardToken()), address(rewardToken), "RewardToken should be initialized");
    }

    function logAddress() private {
        console.log("manager", address(manager));
        console.log("nft", address(nft));
        console.log("rewardToken", address(rewardToken));
        console.log("address(this)", address(this));
    }

    function testOwnerCanMintTokens() public {
        logAddress();
        uint256 amount = 100 * 10 ** rewardToken.decimals();
        rewardToken.mint(alice, amount);

        assertEq(rewardToken.balanceOf(alice), amount, "Alice should have 1000 tokens");
    }

    function testNonOwnerCannotMintTokens() public {
        uint256 amount = 100 * 10 ** rewardToken.decimals();

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", address(bob)));
        rewardToken.mint(bob, amount);
        vm.stopPrank();
    }

    function testConstructorInitializesNftContract() public {
        assertEq(address(manager.nftContract()), address(nft), "NftContract should be initialized");
    }

    function testConstructorInitializesRewardToken() public {
        assertEq(address(manager.rewardToken()), address(rewardToken), "RewardToken should be initialized");
    }

    function testConstructorInitializesBasePrice() public {
        assertEq(nft.basePrice(), BASE_PRICE, "Base price should be initialized");
        assertNotEq(nft.basePrice(), 0, "Base price should not be 0");
    }

    function testConstructorInitializesDiscountPrice() public {
        assertEq(nft.discountPrice(), DISCOUNT_PRICE, "Discount price should be initialized");
        assertNotEq(nft.discountPrice(), 0, "Discount price should not be 0");
    }

    function testConstructorInitializesMerkleRoot() public {
        assertEq(nft.merkleRoot(), merkleRoot, "Merkle root should be initialized");
    }

    function testInit() public {
        assertEq(nft.merkleRoot(), merkleRoot, "Merkle root should be the same");
        assertEq(nft.basePrice(), BASE_PRICE, "Base price should be the same");
        assertEq(nft.discountPrice(), DISCOUNT_PRICE, "Discount price should be the same");
    }

    function testDefaultRoyalty() public {
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(alice);

        (address receiver, uint256 royalty) = nft.royaltyInfo(nftId, BASE_PRICE);
        assertEq(receiver, address(this), "Receiver should be nft");
        assertGt(royalty, 0, "Royalty should be greater then 0");
    }

    function testMerkleProof() public {
        bytes32[] memory proofAlice = merkle.getProof(leaves, 0);
        bytes32[] memory proofBob = merkle.getProof(leaves, 1);
        bytes32[] memory proofJo = merkle.getProof(leaves, 2);

        bool isValidAlice = merkle.verifyProof(merkleRoot, proofAlice, leaves[0]);
        bool isValidBob = merkle.verifyProof(merkleRoot, proofBob, leaves[1]);
        bool isValidJo = merkle.verifyProof(merkleRoot, proofJo, leaves[2]);

        assertTrue(isValidAlice, "Merkle Proof for Alice is not valid");
        assertTrue(isValidBob, "Merkle Proof for Bob is not valid");
        assertTrue(isValidJo, "Merkle Proof for Jo is not valid");
    }

    function testMintNFTWithMerkleProof() public {
        bytes32[] memory proofEmpty;

        vm.expectRevert(abi.encodeWithSignature("InvalidProofParams()"));
        nft.mint{value: DISCOUNT_PRICE}(alice, proofEmpty);

        bytes32[] memory proofAlice = merkle.getProof(leaves, 0);
        nft.mint{value: DISCOUNT_PRICE}(alice, proofAlice);

        uint256 aliceNftBalanceAfter = nft.balanceOf(alice);
        assertEq(aliceNftBalanceAfter, 1, "Alice should have 1 NFT");

        bytes32[] memory proofBob = merkle.getProof(leaves, 1);

        vm.expectRevert(abi.encodeWithSignature("InsufficientFunds()"));
        nft.mint{value: DISCOUNT_PRICE - 1}(bob, proofBob);
        nft.mint{value: DISCOUNT_PRICE}(bob, proofBob);
        vm.expectRevert(abi.encodeWithSignature("AlreadyMinted()"));
        nft.mint{value: DISCOUNT_PRICE}(bob, proofBob);

        uint256 bobNftBalanceAfter = nft.balanceOf(bob);
        assertEq(bobNftBalanceAfter, 1, "Bob should have 1 NFT");

        vm.expectRevert(abi.encodeWithSignature("AlreadyMinted()"));
        nft.mint{value: DISCOUNT_PRICE}(alice, proofAlice);

        vm.expectRevert(abi.encodeWithSignature("InvalidProofCheck()"));
        nft.mint{value: DISCOUNT_PRICE}(alice, proofBob);

        vm.expectRevert();
        nft.mint{value: DISCOUNT_PRICE}(zeroAddress, proofBob);
    }

    function testSupportsInterface() public {
        assertTrue(nft.supportsInterface(type(IERC721).interfaceId));
        assertTrue(nft.supportsInterface(type(IERC2981).interfaceId));
        assertTrue(nft.supportsInterface(type(IERC165).interfaceId));
        assertFalse(nft.supportsInterface(type(IERC1967).interfaceId));
    }

    function testAcceptRewardTokenOwnership() public {
        rewardToken.transferOwnership(address(manager));
        manager.acceptRewardTokenOwnership();

        address newOwner = rewardToken.owner();
        assertEq(newOwner, address(manager), "StakingManager should be the new owner of RewardToken");

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        manager.acceptRewardTokenOwnership();
        vm.stopPrank();
    }

    function testAliceSuccessMintNFT() public {
        nft.mint{value: BASE_PRICE}(alice);
        uint256 aliceNftBalanceAfter = nft.balanceOf(alice);
        assertEq(aliceNftBalanceAfter, 1, "Alice should have 1 NFT");

        uint256 remainingSupply = nft.remainingSupply();
        assertEq(remainingSupply, 999, "Remaining supply should be 999");
    }

    function testAliceAndBobSuccessMintNFT() public {
        nft.mint{value: BASE_PRICE}(alice);
        uint256 aliceNftBalanceAfter = nft.balanceOf(alice);

        assertEq(aliceNftBalanceAfter, 1, "Alice should have 1 NFT");
        assertEq(nft.remainingSupply(), 999, "Remaining supply should be 998");

        nft.mint{value: BASE_PRICE}(bob);
        nft.mint{value: BASE_PRICE}(bob);
        uint256 bobNftBalanceAfter = nft.balanceOf(bob);
        assertEq(bobNftBalanceAfter, 2, "Bob should have 1 NFT");
        assertEq(nft.remainingSupply(), 997, "Remaining supply should be 996");
    }

    function testBobSuccessMercleMintNFT() public {
        uint256 aliceNftBalanceBefore = nft.balanceOf(alice);
        nft.mint{value: BASE_PRICE}(alice);
        uint256 aliceNftBalanceAfter = nft.balanceOf(alice);
        assertEq(aliceNftBalanceAfter, 1, "Alice should have 1 NFT");
    }

    function testMaxSupplyReachedMintNFT() public {
        for (uint256 i = 0; i < 1000; i++) {
            nft.mint{value: BASE_PRICE}(alice);
        }

        uint256 aliceNftBalanceAfter = nft.balanceOf(alice);
        assertEq(aliceNftBalanceAfter, 1000, "Alice should have 1000 NFT");

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSignature("MaxSupplyReached()"));
        nft.mint{value: BASE_PRICE}(bob);
        vm.stopPrank();
    }

    function testInvalidAddressRevert() public {
        vm.expectRevert(abi.encodeWithSignature("InvalidAddress(address)", address(0)));
        nft.mint{value: BASE_PRICE}(address(0));
    }

    function testInsufficientFundsMintNFT() public {
        vm.expectRevert(abi.encodeWithSignature("InsufficientFunds()"));
        nft.mint{value: 1 gwei}(alice);
    }

    function testWithdraw() public {
        uint256 initBal = address(this).balance;
        uint256 initNFTBal = address(nft).balance;

        assertEq(initNFTBal, 0, "Init NFT ether balance should be 0");

        nft.mint{value: BASE_PRICE}(alice);
        nft.mint{value: BASE_PRICE}(bob);
        nft.mint{value: BASE_PRICE}(bob);

        uint256 finalNFTBal = address(nft).balance;
        assertEq(finalNFTBal, BASE_PRICE * 3, "Final NFT ether balance should be greater than init");

        address payable payableAddr = payable(address(0x789));
        nft.withdraw(payableAddr, BASE_PRICE);

        assertEq(address(nft).balance, finalNFTBal - BASE_PRICE, "Balance should be less than final");
        assertEq(address(payableAddr).balance, BASE_PRICE, "Balance should be 9999 gwei");

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        nft.withdraw(payableAddr, BASE_PRICE);
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSignature("WithdrawFailed(address)", payableAddr));
        nft.withdraw(payableAddr, finalNFTBal + 1);
    }

    function testBobSuccessDepositTwoNFT() public {
        uint256 nftId_1 = 1000;
        uint256 nftId_2 = 999;

        nft.mint{value: BASE_PRICE}(bob);
        nft.mint{value: BASE_PRICE}(bob);

        vm.startPrank(bob);
        nft.approve(address(manager), nftId_1);
        vm.expectEmit(address(manager));
        emit Staked(bob, nftId_1);
        manager.depositNFT(nftId_1);

        nft.approve(address(manager), nftId_2);
        vm.expectEmit(address(manager));
        emit Staked(bob, nftId_2);
        manager.depositNFT(nftId_2);
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSignature("TokenAlreadyStaked(uint256)", nftId_1));
        manager.depositNFT(nftId_1);
        vm.stopPrank();

        uint256 stak_1 = manager.stakings(nftId_1);
        uint256 stak_2 = manager.stakings(nftId_2);
        uint256 bobNftBalance = nft.balanceOf(bob);

        assertNotEq(stak_1, 0, "Stak should not be 0");
        assertNotEq(stak_2, 0, "Stak should not be 0");
        assertEq(bobNftBalance, 0, "Bob should not have NFT");
    }

    function testAliceSuccessDepositNFT() public {
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(alice);

        vm.startPrank(alice);
        nft.approve(address(manager), nftId);

        manager.depositNFT(nftId);
        vm.stopPrank();

        uint256 stak = manager.stakings(nftId);
        uint256 aliceNftBalance = nft.balanceOf(alice);

        assertNotEq(stak, 0, "Stak should not be 0");
        assertEq(aliceNftBalance, 0, "Alice should not have NFT");
    }

    function testAliceCheckReward() public {
        uint256 nftId_1 = 1000;
        uint256 nftId_2 = 999;

        nft.mint{value: BASE_PRICE}(alice);
        nft.mint{value: BASE_PRICE}(alice);

        vm.startPrank(alice);
        nft.approve(address(manager), nftId_1);
        nft.approve(address(manager), nftId_2);
        manager.depositNFT(nftId_1);
        manager.depositNFT(nftId_2);
        vm.stopPrank();

        uint256 reward1 = manager.checkReward(nftId_1);
        assertEq(reward1, 0, "Reward1 should e 0");

        vm.warp(block.timestamp + 3 days);

        uint256 reward2 = manager.checkReward(nftId_1);
        assertNotEq(reward2, 0, "Reward should not be 0");

        uint256 reward3 = manager.checkReward(1234);
        assertEq(reward3, 0, "Reward should be 0");
    }

    function testAliceZeroCheckReward() public {
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(alice);
        vm.startPrank(alice);
        uint256 reward = manager.checkReward(nftId);
        assertEq(reward, 0, "Reward should be 0");
        vm.stopPrank();
    }

    function testBobWithdrawReward() public {
        testAcceptRewardTokenOwnership();
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(bob);

        vm.startPrank(bob);
        nft.approve(address(manager), nftId);
        manager.depositNFT(nftId);
        vm.warp(block.timestamp + 3 days);

        uint256 reward = manager.checkReward(nftId);
        assertEq(reward, REWARD_PER_SECOND * 3600 * 72, "Reward should be 29999808000000000000");

        manager.withdrawReward(nftId);
        uint256 rewardAfter = manager.checkReward(nftId);
        assertEq(rewardAfter, 0, "Reward should be 0");
        vm.stopPrank();

        uint256 bobRewardBalance = rewardToken.balanceOf(bob);
        assertEq(bobRewardBalance, reward, "Bob should have reward");

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSignature("NoReward(uint256)", 0));
        manager.withdrawReward(nftId);
        vm.stopPrank();
    }

    function testWithdrawWithZeroReward() public {
        testAcceptRewardTokenOwnership();
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(alice);

        vm.startPrank(alice);
        nft.approve(address(manager), nftId);
        manager.depositNFT(nftId);

        uint256 reward = manager.checkReward(nftId);
        assertEq(reward, 0, "Reward should be 0 before withdrawal");

        vm.expectRevert(abi.encodeWithSignature("NoReward(uint256)", 0));
        manager.withdrawReward(nftId);
        vm.stopPrank();
    }

    function testBobCanDepositNewNFT() public {
        uint256 nftId = 1000;

        nft.mint{value: BASE_PRICE}(bob);

        vm.startPrank(bob);
        nft.approve(address(manager), nftId);
        vm.expectEmit(address(manager));
        emit Staked(bob, nftId);
        manager.depositNFT(nftId);
        vm.stopPrank();

        uint256 stak = manager.stakings(nftId);
        uint256 bobNftBalance = nft.balanceOf(bob);

        assertNotEq(stak, 0, "Stak should not be 0");
        assertEq(bobNftBalance, 0, "Bob should not have NFT");
    }

    function testAlice1HourWithdraw() public {
        testAcceptRewardTokenOwnership();
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(alice);

        vm.startPrank(alice);
        nft.approve(address(manager), nftId);
        manager.depositNFT(nftId);
        vm.warp(block.timestamp + 60 minutes);

        uint256 reward = manager.checkReward(nftId);
        assertNotEq(reward, 0, "Reward should not be 0");

        manager.withdrawReward(nftId);
        uint256 rewardAfter = manager.checkReward(nftId);
        assertEq(rewardAfter, 0, "Reward should be 0");
        vm.stopPrank();
    }

    function testBobRevertWithdrawReward() public {
        testAcceptRewardTokenOwnership();
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(alice);

        vm.startPrank(alice);
        nft.approve(address(manager), nftId);
        manager.depositNFT(nftId);
        vm.stopPrank();

        vm.warp(block.timestamp + 2 days);

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSignature("NotOwner(address,address)", bob, alice));
        manager.withdrawReward(nftId);
        vm.stopPrank();
    }

    function testBobWithRewardWithdrawNFT() public {
        testAcceptRewardTokenOwnership();
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(bob);

        vm.startPrank(bob);
        nft.approve(address(manager), nftId);
        manager.depositNFT(nftId);
        vm.warp(block.timestamp + 3 days);
        uint256 reward = manager.checkReward(nftId);
        assertEq(reward, REWARD_PER_SECOND * 3600 * 72, "Reward should be 29999808000000000000");

        vm.expectEmit(address(manager));
        emit UnStaked(bob, nftId);

        manager.withdrawNFT(nftId);
        vm.stopPrank();

        uint256 data = manager.stakings(nftId);
        assertEq(data, 0, "Data should be 0");

        uint256 bobNftBalance = nft.balanceOf(bob);
        assertEq(bobNftBalance, 1, "Bob should have 1 NFT");

        uint256 bobTokenRewardBalance = rewardToken.balanceOf(bob);
        assertEq(bobTokenRewardBalance, reward, "Bob should have reward");
    }

    function testAlicNoRewardWithdrawNFT() public {
        testAcceptRewardTokenOwnership();
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(alice);

        vm.startPrank(alice);
        nft.approve(address(manager), nftId);
        manager.depositNFT(nftId);

        // Проверяем, что reward равен 0
        uint256 reward = manager.checkReward(nftId);
        assertEq(reward, 0, "Reward should be 0");

        // Фиксируем начальный баланс reward токенов у Alice
        uint256 initialRewardBalance = rewardToken.balanceOf(alice);

        // Ожидаем событие UnStaked
        vm.expectEmit(true, true, false, false, address(manager));
        emit UnStaked(alice, nftId);

        // Вызываем withdrawNFT и проверяем, что токены не начисляются
        manager.withdrawNFT(nftId);

        // Завершаем Prank
        vm.stopPrank();

        // Проверяем, что баланс Alice по NFT увеличился на 1
        uint256 aliceNftBalance = nft.balanceOf(alice);
        assertEq(aliceNftBalance, 1, "Alice should have 1 NFT");

        // Проверяем, что баланс RewardToken не изменился
        uint256 finalRewardBalance = rewardToken.balanceOf(alice);
        assertEq(
            finalRewardBalance, initialRewardBalance, "Alice's reward balance should not change when reward is zero"
        );
    }

    function testValidateMint() public {
        uint256 nftId = 1000;

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSignature("InsufficientFunds()"));
        nft.mint{value: 199 gwei}(alice);
        vm.stopPrank();

        for (uint256 i = 0; i < 1000; i++) {
            nft.mint{value: BASE_PRICE}(alice);
        }

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSignature("MaxSupplyReached()"));
        nft.mint{value: BASE_PRICE}(bob);
        vm.stopPrank();
    }

    function testOnERC721Received() public {
        uint256 nftId = 1000;
        nft.mint{value: BASE_PRICE}(alice);

        vm.startPrank(alice);
        nft.approve(address(manager), nftId);
        manager.depositNFT(nftId);

        vm.expectRevert(abi.encodeWithSignature("WrongNftContract(address,uint256)", alice, nftId));
        manager.onERC721Received(address(nft), alice, nftId, "");
        vm.stopPrank();

        vm.startPrank(address(nft));
        vm.expectEmit(address(manager));
        emit Staked(alice, nftId);
        bytes4 data = manager.onERC721Received(address(nft), alice, nftId, "");
        assertEq(data, manager.onERC721Received.selector, "Selector should be the same");
        vm.stopPrank();
    }
}
