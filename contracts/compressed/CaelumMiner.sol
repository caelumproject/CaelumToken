//solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./libs/SafeMath.sol";
import "./libs/StandardToken.sol";
import "./libs/ExtendedMath.sol";
import "./CaelumVotings.sol";
import "./CaelumMasternode.sol";


contract CaelumMiner is StandardToken, CaelumMasternode {
    using SafeMath for uint;
    using ExtendedMath for uint;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public totalSupply;

    uint public latestDifficultyPeriodStarted;
    uint public epochCount;
    uint public baseMiningReward = 50;
    uint public blocksPerReadjustment = 512;
    uint public _MINIMUM_TARGET = 2 ** 16;
    uint public _MAXIMUM_TARGET = 2 ** 234;
    uint public rewardEra = 0;

    uint public maxSupplyForEra;
    uint public MAX_REWARD_ERA = 39;
    uint public MINING_RATE_FACTOR = 60; //mint the token 60 times less often than ether
    //difficulty adjustment parameters- be careful modifying these
    uint public MAX_ADJUSTMENT_PERCENT = 100;
    uint public TARGET_DIVISOR = 2000;
    uint public QUOTIENT_LIMIT = TARGET_DIVISOR.div(2);
    mapping(bytes32 => bytes32) solutionForChallenge;
    mapping(address => mapping(address => uint)) allowed;

    bytes32 public challengeNumber;
    uint public difficulty;
    uint public tokensMinted;


    struct Statistics {
        address lastRewardTo;
        uint lastRewardAmount;
        uint lastRewardEthBlockNumber;
        uint lastRewardTimestamp;
    }

    Statistics public statistics;
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

    constructor() public {
        symbol = "CLM"; // Change before live; This is to prevent a flood of the real token name on ropsten.
        name = "Caelum Token"; // Change before live; This is to prevent a flood of the real token name on ropsten.
        decimals = 8;
        totalSupply = 2100000000000000;
        tokensMinted = 0;
        maxSupplyForEra = totalSupply.div(2);
        difficulty = _MAXIMUM_TARGET;
        latestDifficultyPeriodStarted = block.number;
        _newEpoch(0);

        balances[msg.sender] = balances[msg.sender].add(420000 * 1e8); // 2% Premine as determined by the community meeting.
        emit Transfer(this, msg.sender, 420000 * 1e8);
    }

    function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success) {
        // perform the hash function validation
        _hash(nonce, challenge_digest);

        _arrangeMasternodeFlow();

        uint rewardAmount = _reward();
        uint rewardMasternode = _reward_masternode();

        tokensMinted += rewardAmount.add(rewardMasternode);

        uint epochCounter = _newEpoch(nonce);

        _adjustDifficulty();

        statistics = Statistics(msg.sender, rewardAmount, block.number, now);

        emit Mint(msg.sender, rewardAmount, epochCounter, challengeNumber);

        return true;
    }

    function _newEpoch(uint256 nonce) internal returns(uint) {

        if (tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < MAX_REWARD_ERA) {
            rewardEra = rewardEra + 1;
        }
        maxSupplyForEra = totalSupply - totalSupply.div(2 ** (rewardEra + 1));
        epochCount = epochCount.add(1);
        challengeNumber = blockhash(block.number - 1);
    }

    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns(bytes32 digest) {
        digest = keccak256(challengeNumber, msg.sender, nonce);
        if (digest != challenge_digest) revert();
        if (uint256(digest) > difficulty) revert();
        bytes32 solution = solutionForChallenge[challengeNumber];
        solutionForChallenge[challengeNumber] = digest;
        if (solution != 0x0) revert(); //prevent the same answer from awarding twice
    }

    function _reward() internal returns(uint) {

        uint _pow = rewardsProofOfWork;

        balances[msg.sender] = balances[msg.sender].add(_pow);
        emit Transfer(this, msg.sender, _pow);

        return _pow;
    }

    function _reward_masternode() internal returns(uint) {

        uint _mnReward = rewardsMasternode;
        if (masternodeCounter == 0) return 0;

        address _mnCandidate = userByIndex[masternodeCandidate].accountOwner;
        if (_mnCandidate == 0x0) return 0;

        balances[_mnCandidate] = balances[_mnCandidate].add(_mnReward);
        emit Transfer(this, _mnCandidate, _mnReward);

        //emit RewardMasternode(_mnCandidate, _mnReward);

        return _mnReward;
    }


    //DO NOT manually edit this method unless you know EXACTLY what you are doing
    function _adjustDifficulty() internal returns(uint) {
        //every so often, readjust difficulty. Dont readjust when deploying
        if (epochCount % blocksPerReadjustment != 0) {
            return difficulty;
        }

        uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
        //assume 360 ethereum blocks per hour
        //we want miners to spend 10 minutes to mine each 'block', about 60 ethereum blocks = one 0xbitcoin epoch
        uint epochsMined = blocksPerReadjustment;
        uint targetEthBlocksPerDiffPeriod = epochsMined * MINING_RATE_FACTOR;
        //if there were less eth blocks passed in time than expected
        if (ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod) {
            uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div(ethBlocksSinceLastDifficultyPeriod);
            uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT);
            // If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined than expected then this is 100.
            //make it harder
            difficulty = difficulty.sub(difficulty.div(TARGET_DIVISOR).mul(excess_block_pct_extra)); //by up to 50 %
        } else {
            uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div(targetEthBlocksPerDiffPeriod);
            uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT); //always between 0 and 1000
            //make it easier
            difficulty = difficulty.add(difficulty.div(TARGET_DIVISOR).mul(shortage_block_pct_extra)); //by up to 50 %
        }
        latestDifficultyPeriodStarted = block.number;
        if (difficulty < _MINIMUM_TARGET) //very difficult
        {
            difficulty = _MINIMUM_TARGET;
        }
        if (difficulty > _MAXIMUM_TARGET) //very easy
        {
            difficulty = _MAXIMUM_TARGET;
        }
    }
    //this is a recent ethereum block hash, used to prevent pre-mining future blocks
    function getChallengeNumber() public view returns(bytes32) {
        return challengeNumber;
    }
    //the number of zeroes the digest of the PoW solution requires.  Auto adjusts
    function getMiningDifficulty() public view returns(uint) {
        return _MAXIMUM_TARGET.div(difficulty);
    }

    function getMiningTarget() public view returns(uint) {
        return difficulty;
    }

    function getMiningReward() public view returns(uint) {
        return (baseMiningReward * 1e8).div(2 ** rewardEra);
    }

    //help debug mining software
    function getMintDigest(
        uint256 nonce,
        bytes32 challenge_digest,
        bytes32 challenge_number
    )
    public view returns(bytes32 digesttest) {
        bytes32 digest = keccak256(challenge_number, msg.sender, nonce);
        return digest;
    }
    //help debug mining software
    function checkMintSolution(
        uint256 nonce,
        bytes32 challenge_digest,
        bytes32 challenge_number,
        uint testTarget
    )
    public view returns(bool success) {
        bytes32 digest = keccak256(challenge_number, msg.sender, nonce);
        if (uint256(digest) > testTarget) revert();
        return (digest == challenge_digest);
    }
}
