**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [incorrect-exp](#incorrect-exp) (1 results) (High)
 - [divide-before-multiply](#divide-before-multiply) (9 results) (Medium)
 - [incorrect-equality](#incorrect-equality) (1 results) (Medium)
 - [pess-nft-approve-warning](#pess-nft-approve-warning) (1 results) (Medium)
 - [pess-dubious-typecast](#pess-dubious-typecast) (2 results) (Medium)
 - [missing-zero-check](#missing-zero-check) (2 results) (Low)
 - [reentrancy-events](#reentrancy-events) (2 results) (Low)
 - [timestamp](#timestamp) (5 results) (Low)
 - [pess-public-vs-external](#pess-public-vs-external) (1 results) (Low)
 - [assembly](#assembly) (6 results) (Informational)
 - [pragma](#pragma) (1 results) (Informational)
 - [solc-version](#solc-version) (2 results) (Informational)
 - [low-level-calls](#low-level-calls) (1 results) (Informational)
 - [immutable-states](#immutable-states) (1 results) (Optimization)
## incorrect-exp
Impact: High
Confidence: Medium
 - [ ] ID-0
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) has bitwise-xor operator ^ instead of the exponentiation operator **: 
	 - [inverse = (3 * denominator) ^ 2](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L184)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


## divide-before-multiply
Impact: Medium
Confidence: Medium
 - [ ] ID-1
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L169)
	- [inverse *= 2 - denominator * inverse](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L190)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


 - [ ] ID-2
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L169)
	- [inverse *= 2 - denominator * inverse](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L193)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


 - [ ] ID-3
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L169)
	- [inverse *= 2 - denominator * inverse](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L188)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


 - [ ] ID-4
[StakingManager.checkReward(uint256)](.src/StakingManager.sol#L102-L112) performs a multiplication on the result of a division:
	- [rewardPerSecond = (REWARD_PER_DAY * 1e18) / 86400](.src/StakingManager.sol#L107)
	- [(stakedTime * rewardPerSecond) / 1e18](.src/StakingManager.sol#L108)

.src/StakingManager.sol#L102-L112


 - [ ] ID-5
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L169)
	- [inverse = (3 * denominator) ^ 2](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L184)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


 - [ ] ID-6
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) performs a multiplication on the result of a division:
	- [prod0 = prod0 / twos](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L172)
	- [result = prod0 * inverse](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L199)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


 - [ ] ID-7
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L169)
	- [inverse *= 2 - denominator * inverse](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L192)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


 - [ ] ID-8
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L169)
	- [inverse *= 2 - denominator * inverse](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L191)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


 - [ ] ID-9
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L169)
	- [inverse *= 2 - denominator * inverse](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L189)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-10
[StakingManager.withdrawReward(uint256)](.src/StakingManager.sol#L77-L83) uses a dangerous strict equality:
	- [reward == 0](.src/StakingManager.sol#L79)

.src/StakingManager.sol#L77-L83


## pess-nft-approve-warning
Impact: Medium
Confidence: Low
 - [ ] ID-11
StakingManager withdrawNFT parameter from is not related to msg.sender [nftContract.safeTransferFrom(address(this),user,tokenId)](.src/StakingManager.sol#L95)

.src/StakingManager.sol#L95


## pess-dubious-typecast
Impact: Medium
Confidence: High
 - [ ] ID-12
Dubious typecast in [StakingManager.checkReward(uint256)](.src/StakingManager.sol#L102-L112):
	uint256 => uint96 casting occurs in [timestamp = uint256(uint96(stakings[tokenId]))](.src/StakingManager.sol#L103)

.src/StakingManager.sol#L102-L112


 - [ ] ID-13
Dubious typecast in [StakingManager.getStakUser(uint256)](.src/StakingManager.sol#L137-L139):
	uint256 => uint160 casting occurs in [address(uint160(data >> 96))](.src/StakingManager.sol#L138)

.src/StakingManager.sol#L137-L139


## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-14
[LimitedEditionNFT.withdraw(address,uint256).to](.src/LimitedEditionNFT.sol#L86) lacks a zero-check on :
		- [(success,None) = to.call{value: amount}()](.src/LimitedEditionNFT.sol#L87)

.src/LimitedEditionNFT.sol#L86


 - [ ] ID-15
[Ownable2Step.transferOwnership(address).newOwner](.lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#L35) lacks a zero-check on :
		- [_pendingOwner = newOwner](.lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#L36)

.lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#L35


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-16
Reentrancy in [StakingManager.depositNFT(uint256)](.src/StakingManager.sol#L65-L73):
	External calls:
	- [nftContract.transferFrom(sender,address(this),tokenId)](.src/StakingManager.sol#L71)
	Event emitted after the call(s):
	- [Staked(sender,tokenId)](.src/StakingManager.sol#L72)

.src/StakingManager.sol#L65-L73


 - [ ] ID-17
Reentrancy in [StakingManager.withdrawNFT(uint256)](.src/StakingManager.sol#L87-L97):
	External calls:
	- [rewardToken.mint(user,reward)](.src/StakingManager.sol#L92)
	- [nftContract.safeTransferFrom(address(this),user,tokenId)](.src/StakingManager.sol#L95)
	Event emitted after the call(s):
	- [UnStaked(user,tokenId)](.src/StakingManager.sol#L96)

.src/StakingManager.sol#L87-L97


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-18
[StakingManager.depositNFT(uint256)](.src/StakingManager.sol#L65-L73) uses timestamp for comparisons
	Dangerous comparisons:
	- [stakings[tokenId] != 0](.src/StakingManager.sol#L66)

.src/StakingManager.sol#L65-L73


 - [ ] ID-19
[StakingManager.handleWithdraw(uint256)](.src/StakingManager.sol#L119-L124) uses timestamp for comparisons
	Dangerous comparisons:
	- [msg.sender != user](.src/StakingManager.sol#L121)

.src/StakingManager.sol#L119-L124


 - [ ] ID-20
[StakingManager.withdrawReward(uint256)](.src/StakingManager.sol#L77-L83) uses timestamp for comparisons
	Dangerous comparisons:
	- [reward == 0](.src/StakingManager.sol#L79)

.src/StakingManager.sol#L77-L83


 - [ ] ID-21
[StakingManager.withdrawNFT(uint256)](.src/StakingManager.sol#L87-L97) uses timestamp for comparisons
	Dangerous comparisons:
	- [reward > 0](.src/StakingManager.sol#L91)

.src/StakingManager.sol#L87-L97


 - [ ] ID-22
[StakingManager.checkReward(uint256)](.src/StakingManager.sol#L102-L112) uses timestamp for comparisons
	Dangerous comparisons:
	- [timestamp > 0](.src/StakingManager.sol#L105)

.src/StakingManager.sol#L102-L112


## pess-public-vs-external
Impact: Low
Confidence: Medium
 - [ ] ID-23
The following public functions could be turned into external in [Merkle](.src/Merkle.sol#L6-L178) contract:
	[Merkle.getRoot(bytes32[])](.src/Merkle.sol#L54-L60)
	[Merkle.getProof(bytes32[],uint256)](.src/Merkle.sol#L66-L86)
	[Merkle.log2ceil(uint256)](.src/Merkle.sol#L114-L128)

.src/Merkle.sol#L6-L178


## assembly
Impact: Informational
Confidence: High
 - [ ] ID-24
[Merkle.log2ceil(uint256)](.src/Merkle.sol#L114-L128) uses assembly
	- [INLINE ASM](.src/Merkle.sol#L117-L119)

.src/Merkle.sol#L114-L128


 - [ ] ID-25
[Strings.toString(uint256)](.lib/openzeppelin-contracts/contracts/utils/Strings.sol#L24-L44) uses assembly
	- [INLINE ASM](.lib/openzeppelin-contracts/contracts/utils/Strings.sol#L30-L32)
	- [INLINE ASM](.lib/openzeppelin-contracts/contracts/utils/Strings.sol#L36-L38)

.lib/openzeppelin-contracts/contracts/utils/Strings.sol#L24-L44


 - [ ] ID-26
[Merkle.hashLeafPairs(bytes32,bytes32)](.src/Merkle.sol#L36-L49) uses assembly
	- [INLINE ASM](.src/Merkle.sol#L37-L48)

.src/Merkle.sol#L36-L49


 - [ ] ID-27
[Math.mulDiv(uint256,uint256,uint256)](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202) uses assembly
	- [INLINE ASM](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L130-L133)
	- [INLINE ASM](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L154-L161)
	- [INLINE ASM](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L167-L176)

.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L123-L202


 - [ ] ID-28
[MerkleProof._efficientHash(bytes32,bytes32)](.lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#L224-L231) uses assembly
	- [INLINE ASM](.lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#L226-L230)

.lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#L224-L231


 - [ ] ID-29
[ERC721._checkOnERC721Received(address,address,uint256,bytes)](.lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L465-L482) uses assembly
	- [INLINE ASM](.lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L476-L478)

.lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L465-L482


## pragma
Impact: Informational
Confidence: High
 - [ ] ID-30
2 different versions of Solidity are used:
	- Version constraint ^0.8.20 is used by:
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/interfaces/IERC2981.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#L3)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/utils/Context.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/utils/Strings.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L4)
		-[^0.8.20](.lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#L4)
	- Version constraint 0.8.20 is used by:
		-[0.8.20](.src/LimitedEditionNFT.sol#L2)
		-[0.8.20](.src/Merkle.sol#L2)
		-[0.8.20](.src/RewardToken.sol#L2)
		-[0.8.20](.src/StakingManager.sol#L2)

.lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-31
Version constraint 0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- [0.8.20](.src/LimitedEditionNFT.sol#L2)
	- [0.8.20](.src/Merkle.sol#L2)
	- [0.8.20](.src/RewardToken.sol#L2)
	- [0.8.20](.src/StakingManager.sol#L2)

.src/LimitedEditionNFT.sol#L2


 - [ ] ID-32
Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/interfaces/IERC2981.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#L3)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/utils/Context.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/utils/Strings.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L4)
	- [^0.8.20](.lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#L4)

.lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4


## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-33
Low level call in [LimitedEditionNFT.withdraw(address,uint256)](.src/LimitedEditionNFT.sol#L86-L89):
	- [(success,None) = to.call{value: amount}()](.src/LimitedEditionNFT.sol#L87)

.src/LimitedEditionNFT.sol#L86-L89


## immutable-states
Impact: Optimization
Confidence: High
 - [ ] ID-34
[LimitedEditionNFT.merkleRoot](.src/LimitedEditionNFT.sol#L20) should be immutable 

.src/LimitedEditionNFT.sol#L20


