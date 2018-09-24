## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| BasicToken.sol | 191c87a1d2fd4d25a90dc582c8465c1cb52d6207 |
| CaelumAcceptERC20.sol | d2ab6cdf6b79618e6db3357941cb04a906d747b6 |
| CaelumFundraise.sol | 27e78df7f39ef750e6f6607db3bd1ba17731438f |
| CaelumMasternode.sol | 2322e3587e42c9ba5f0cb570773b9c453240ce27 |
| CaelumMiner.sol | 0e43e60bdb9643a3ab6b1e260aa3a270eee17ff2 |
| CaelumVotings.sol | 45c30208a8c7cbaa20184abdd93391e8f6da3918 |
| DeployedVersion.sol | da39a3ee5e6b4b0d3255bfef95601890afd80709 |
| ERC20Basic.sol | 56b1df898336fbe0792b6742a7d8ec77d4aa64bd |
| ERC20.sol | 81d0c1f4c8e6aa6cd45df30695a1853b3a23ae71 |
| ExtendedMath.sol | ce20d45788d4b026f10e95b11e2b5c9800a19a70 |
| NewMemberProposal.sol | 10beb4e282c55f8973cf8bd17eca5649df4c42dd |
| NewTokenProposal.sol | a5c1330819839a1d1d0e1ff79450479decf65ac4 |
| Ownable.sol | 7e21e1474b0eebb078ddf191df618df2ec762f1c |
| SafeMath.sol | 54cfb2460ff5fe93794214eb99729cda30b965e6 |
| StandardToken.sol | 585492b465ce2fb766534922a62f1e7bc0e2362c |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **BasicToken** | Implementation | ERC20Basic |||
| └ | totalSupply | Public ❗️ |   | |
| └ | transfer | Public ❗️ | 🛑  | |
| └ | balanceOf | Public ❗️ |   | |
||||||
| **CaelumAcceptERC20** | Implementation | Ownable, abstractCaelum |||
| └ | getMiningReward | Public ❗️ |   | |
| └ | addOwnToken | Public ❗️ | 🛑  | onlyOwner |
| └ | addToWhitelist | Internal 🔒 | 🛑  | |
| └ | isAcceptedToken | Internal 🔒 |   | |
| └ | getAcceptedTokenAmount | Internal 🔒 |   | |
| └ | isValid | Internal 🔒 |   | |
| └ | listAcceptedTokens | Public ❗️ |   | |
| └ | getTokenDetails | Public ❗️ |   | |
| └ | depositCollateral | Public ❗️ | 🛑  | |
| └ | withdrawCollateral | Public ❗️ | 🛑  | |
||||||
| **CaelumFundraise** | Implementation | Ownable, BasicToken, abstractCaelum |||
| └ | \<Fallback\> | Public ❗️ |  💵 | |
| └ | buyMasternode | Public ❗️ |  💵 | |
| └ | receivedFunds | Internal 🔒 | 🛑  | |
||||||
| **CaelumMasternode** | Implementation | Ownable, CaelumFundraise, CaelumVotings, CaelumAcceptERC20 |||
| └ | addGenesis | Public ❗️ | 🛑  | onlyOwner |
| └ | closeGenesis | Public ❗️ | 🛑  | onlyOwner |
| └ | addMasternode | Internal 🔒 | 🛑  | |
| └ | updateMasternode | Internal 🔒 | 🛑  | |
| └ | updateMasternodeAsTeamMember | Internal 🔒 | 🛑  | |
| └ | isTeamMember | Public ❗️ |   | |
| └ | deleteMasternode | Internal 🔒 | 🛑  | |
| └ | isPartOf | Public ❗️ |   | |
| └ | removeFromUserCounter | Internal 🔒 | 🛑  | |
| └ | setMasternodeCandidate | Internal 🔒 | 🛑  | |
| └ | getFollowingCandidate | Internal 🔒 |   | |
| └ | belongsToUser | Public ❗️ |   | |
| └ | isMasternodeOwner | Public ❗️ |   | |
| └ | getLastPerUser | Public ❗️ |   | |
| └ | calculateRewardStructures | Internal 🔒 | 🛑  | |
| └ | setBaseRewards | Internal 🔒 | 🛑  | |
| └ | _arrangeMasternodeFlow | Internal 🔒 | 🛑  | |
| └ | _emergencyLoop | Public ❗️ | 🛑  | onlyOwner |
| └ | masternodeInfo | Public ❗️ |   | |
| └ | contractProgress | Public ❗️ |   | |
||||||
| **CaelumMiner** | Implementation | StandardToken, CaelumMasternode |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | mint | Public ❗️ | 🛑  | |
| └ | _newEpoch | Internal 🔒 | 🛑  | |
| └ | _hash | Internal 🔒 | 🛑  | |
| └ | _reward | Internal 🔒 | 🛑  | |
| └ | _reward_masternode | Internal 🔒 | 🛑  | |
| └ | _adjustDifficulty | Internal 🔒 | 🛑  | |
| └ | getChallengeNumber | Public ❗️ |   | |
| └ | getMiningDifficulty | Public ❗️ |   | |
| └ | getMiningTarget | Public ❗️ |   | |
| └ | getMiningReward | Public ❗️ |   | |
| └ | getMintDigest | Public ❗️ |   | |
| └ | checkMintSolution | Public ❗️ |   | |
||||||
| **CaelumVotings** | Implementation | Ownable |||
| └ | isMasternodeOwner | Public ❗️ |   | |
| └ | addToWhitelist | Internal 🔒 | 🛑  | |
| └ | addMasternode | Internal 🔒 | 🛑  | |
| └ | updateMasternodeAsTeamMember | Internal 🔒 | 🛑  | |
| └ | isTeamMember | Public ❗️ |   | |
| └ | pushProposal | Public ❗️ | 🛑  | onlyOwner |
| └ | handleLastProposal | Internal 🔒 | 🛑  | |
| └ | discardRejectedProposal | Public ❗️ | 🛑  | onlyOwner |
| └ | LastProposalCanDiscard | Public ❗️ |   | |
| └ | getTokenProposalDetails | Public ❗️ |   | |
| └ | pastProposalTimeRules | Public ❗️ |   | |
| └ | becomeVoter | Public ❗️ | 🛑  | |
| └ | voteProposal | Public ❗️ | 🛑  | |
| └ | reachedMajority | Public ❗️ |   | |
| └ | majority | Internal 🔒 |   | |
| └ | reachedMajorityForTeam | Public ❗️ |   | |
| └ | majorityForTeam | Internal 🔒 |   | |
||||||
| **ERC20Basic** | Implementation |  |||
| └ | totalSupply | Public ❗️ |   | |
| └ | balanceOf | Public ❗️ |   | |
| └ | transfer | Public ❗️ | 🛑  | |
||||||
| **ERC20** | Implementation | ERC20Basic |||
| └ | allowance | Public ❗️ |   | |
| └ | transferFrom | Public ❗️ | 🛑  | |
| └ | approve | Public ❗️ | 🛑  | |
||||||
| **ExtendedMath** | Library |  |||
| └ | limitLessThan | Internal 🔒 |   | |
||||||
| **NewMemberProposal** | Implementation | IcaelumVoting |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | getTokenProposalDetails | Public ❗️ |   | |
| └ | getExpiry | External ❗️ |   | |
| └ | getContractType | External ❗️ |   | |
||||||
| **NewTokenProposal** | Implementation | IcaelumVoting |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | getTokenProposalDetails | Public ❗️ |   | |
| └ | getExpiry | External ❗️ |   | |
| └ | getContractType | External ❗️ |   | |
||||||
| **Ownable** | Implementation |  |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | renounceOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | transferOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | _transferOwnership | Internal 🔒 | 🛑  | |
||||||
| **SafeMath** | Library |  |||
| └ | mul | Internal 🔒 |   | |
| └ | div | Internal 🔒 |   | |
| └ | sub | Internal 🔒 |   | |
| └ | add | Internal 🔒 |   | |
| └ | mod | Internal 🔒 |   | |
||||||
| **StandardToken** | Implementation | ERC20, BasicToken |||
| └ | transferFrom | Public ❗️ | 🛑  | |
| └ | approve | Public ❗️ | 🛑  | |
| └ | allowance | Public ❗️ |   | |
| └ | increaseApproval | Public ❗️ | 🛑  | |
| └ | decreaseApproval | Public ❗️ | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
