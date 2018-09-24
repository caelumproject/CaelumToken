//solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./libs/SafeMath.sol";
import "./libs/Ownable.sol";
import "./CaelumFundraise.sol";
import "./CaelumVotings.sol";
import "./CaelumAcceptERC20.sol";

contract CaelumMasternode is Ownable, CaelumFundraise, CaelumVotings, CaelumAcceptERC20{
    using SafeMath for uint;

    bool onTestnet = false;
    bool genesisAdded = false;

    uint  masternodeRound;
    uint  masternodeCandidate;
    uint  masternodeCounter;
    uint  masternodeEpoch;
    uint  miningEpoch;

    uint rewardsProofOfWork;
    uint rewardsMasternode;
    uint rewardsGlobal = 50 * 1e8;

    uint MINING_PHASE_DURATION_BLOCKS = 4500;

    struct MasterNode {
        address accountOwner;
        bool isActive;
        bool isTeamMember;
        uint storedIndex;
        uint startingRound;
        uint[] indexcounter;
    }

    uint[] userArray;
    address[] userAddressArray;

    mapping(uint => MasterNode) userByIndex; // UINT masterMapping
    mapping(address => MasterNode) userByAddress; //masterMapping
    mapping(address => uint) userAddressIndex;

    event Deposit(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);

    event NewMasternode(address candidateAddress, uint timeStamp);
    event RemovedMasternode(address candidateAddress, uint timeStamp);

    /**
     * @dev Add the genesis accounts
     */
    function addGenesis(address _genesis, bool _team) onlyOwner public {
        require(!genesisAdded);

        addMasternode(_genesis);

        if (_team) {
            updateMasternodeAsTeamMember(msg.sender);
        }

        genesisAdded = true; // Forever lock this.
    }

    /**
     * @dev Close the genesis accounts
     */
    function closeGenesis() onlyOwner public {
        genesisAdded = true; // Forever lock this.
    }

    /**
     * @dev Add a user as masternode. Called as internal since we only add masternodes by depositing collateral or by voting.
     * @param _candidate Candidate address
     * @return uint Masternode index
     */
    function addMasternode(address _candidate) internal returns(uint) {
        userByIndex[masternodeCounter].accountOwner = _candidate;
        userByIndex[masternodeCounter].isActive = true;
        userByIndex[masternodeCounter].startingRound = masternodeRound + 1;
        userByIndex[masternodeCounter].storedIndex = masternodeCounter;

        userByAddress[_candidate].accountOwner = _candidate;
        userByAddress[_candidate].indexcounter.push(masternodeCounter);

        userArray.push(userArray.length);
        masternodeCounter++;

        emit NewMasternode(_candidate, now);
        return masternodeCounter - 1; //
    }

    /**
     * @dev Allow us to update a masternode's round to keep progress
     * @param _candidate ID of masternode
     */
    function updateMasternode(uint _candidate) internal returns(bool) {
        userByIndex[_candidate].startingRound++;
        return true;
    }

    /**
     * @dev Allow us to update a masternode to team member status
     * @param _member address
     */
    function updateMasternodeAsTeamMember(address _member) internal returns (bool) {
        userByAddress[_member].isTeamMember = true;
        return (true);
    }

    /**
     * @dev Let us know if an address is part of the team.
     * @param _member address
     */
    function isTeamMember (address _member) public view returns (bool) {
        if (userByAddress[_member].isTeamMember)
        return true;
    }

    /**
     * @dev Remove a specific masternode
     * @param _masternodeID ID of the masternode to remove
     */
    function deleteMasternode(uint _masternodeID) internal returns(bool success) {

        uint rowToDelete = userByIndex[_masternodeID].storedIndex;
        uint keyToMove = userArray[userArray.length - 1];

        userByIndex[_masternodeID].isActive = userByIndex[_masternodeID].isActive = (false);
        userArray[rowToDelete] = keyToMove;
        userByIndex[keyToMove].storedIndex = rowToDelete;
        userArray.length = userArray.length - 1;

        removeFromUserCounter(_masternodeID);

        emit RemovedMasternode(userByIndex[_masternodeID].accountOwner, now);

        return true;
    }

    /**
     * @dev returns what account belongs to a masternode
     */
    function isPartOf(uint mnid) public view returns (address) {
        return userByIndex[mnid].accountOwner;
    }

    /**
     * @dev Internal function to remove a masternode from a user address if this address holds multpile masternodes
     * @param index MasternodeID
     */
    function removeFromUserCounter(uint index)  internal returns(uint[]) {
        address belong = isPartOf(index);

        if (index >= userByAddress[belong].indexcounter.length) return;

        for (uint i = index; i<userByAddress[belong].indexcounter.length-1; i++){
            userByAddress[belong].indexcounter[i] = userByAddress[belong].indexcounter[i+1];
        }

        delete userByAddress[belong].indexcounter[userByAddress[belong].indexcounter.length-1];
        userByAddress[belong].indexcounter.length--;
        return userByAddress[belong].indexcounter;
    }

    /**
     * @dev Primary contract function to update the current user and prepare the next one.
     * A number of steps have been token to ensure the contract can never run out of gas when looping over our masternodes.
     */
    function setMasternodeCandidate() internal returns(address) {

        uint hardlimitCounter = 0;

        while (getFollowingCandidate() == 0x0) {
            // We must return a value not to break the contract. Require is a secondary killswitch now.
            require(hardlimitCounter < 6, "Failsafe switched on");
            // Choose if loop over revert/require to terminate the loop and return a 0 address.
            if (hardlimitCounter == 5) return (0);
            masternodeRound = masternodeRound + 1;
            masternodeCandidate = 0;
            hardlimitCounter++;
        }

        if (masternodeCandidate == masternodeCounter - 1) {
            masternodeRound = masternodeRound + 1;
            masternodeCandidate = 0;
        }

        for (uint i = masternodeCandidate; i < masternodeCounter; i++) {
            if (userByIndex[i].isActive) {
                if (userByIndex[i].startingRound == masternodeRound) {
                    updateMasternode(i);
                    masternodeCandidate = i;
                    return (userByIndex[i].accountOwner);
                }
            }
        }

        masternodeRound = masternodeRound + 1;
        return (0);

    }

    /**
     * @dev Helper function to loop through our masternodes at start and return the correct round
     */
    function getFollowingCandidate() internal view returns(address _address) {
        uint tmpRound = masternodeRound;
        uint tmpCandidate = masternodeCandidate;

        if (tmpCandidate == masternodeCounter - 1) {
            tmpRound = tmpRound + 1;
            tmpCandidate = 0;
        }

        for (uint i = masternodeCandidate; i < masternodeCounter; i++) {
            if (userByIndex[i].isActive) {
                if (userByIndex[i].startingRound == tmpRound) {
                    tmpCandidate = i;
                    return (userByIndex[i].accountOwner);
                }
            }
        }

        tmpRound = tmpRound + 1;
        return (0);
    }

    /**
     * @dev Displays all masternodes belonging to a user address.
     */
    function belongsToUser(address userAddress) public view returns(uint[]) {
        return (userByAddress[userAddress].indexcounter);
    }

    /**
     * @dev Helper function to know if an address owns masternodes
     */
    function isMasternodeOwner(address _candidate) public view returns(bool) {
        if(userByAddress[_candidate].indexcounter.length <= 0) return false;
        if (userByAddress[_candidate].accountOwner == _candidate)
        return true;
    }

    /**
     * @dev Helper function to get the last masternode belonging to a user
     */
    function getLastPerUser(address _candidate) public view returns (uint) {
        return userByAddress[_candidate].indexcounter[userByAddress[_candidate].indexcounter.length - 1];
    }


    /**
     * @dev Calculate and set the reward schema for Caelum.
     * Each mining phase is decided by multiplying the MINING_PHASE_DURATION_BLOCKS with factor 10.
     * Depending on the outcome (solidity always rounds), we can detect the current stage of mining.
     * First stage we cut the rewards to 5% to prevent instamining.
     * Last stage we leave 2% for miners to incentivize keeping miners running.
     */
    function calculateRewardStructures() internal {
        //ToDo: Set
        uint _global_reward_amount = getMiningReward(); //reward();
        uint getStageOfMining = miningEpoch / MINING_PHASE_DURATION_BLOCKS * 10;

        if (getStageOfMining < 10) {
            rewardsProofOfWork = _global_reward_amount / 100 * 5;
            rewardsMasternode = 0;
            return;
        }

        if (getStageOfMining > 90) {
            rewardsProofOfWork = _global_reward_amount / 100 * 2;
            rewardsMasternode = _global_reward_amount / 100 * 98;
            return;
        }

        uint _mnreward = (_global_reward_amount / 100) * getStageOfMining;
        uint _powreward = (_global_reward_amount - _mnreward);

        setBaseRewards(_powreward, _mnreward);
    }

    function setBaseRewards(uint _pow, uint _mn) internal {
        rewardsMasternode = _mn;
        rewardsProofOfWork = _pow;
    }

    /**
     * @dev Executes the masternode flow. Should be called after mining a block.
     */
    function _arrangeMasternodeFlow() internal {
        calculateRewardStructures();
        setMasternodeCandidate();
        miningEpoch++;
    }

    /**
     * @dev Executes the masternode flow. Should be called after mining a block.
     * This is an emergency manual loop method.
     */
    function _emergencyLoop() onlyOwner public {
        calculateRewardStructures();
        setMasternodeCandidate();
        miningEpoch++;
    }

    function masternodeInfo(uint index) public view returns
    (
        address,
        bool,
        uint,
        uint
    )
    {
        return (
            userByIndex[index].accountOwner,
            userByIndex[index].isActive,
            userByIndex[index].storedIndex,
            userByIndex[index].startingRound
        );
    }

    function contractProgress() public view returns
    (
        uint epoch,
        uint candidate,
        uint round,
        uint miningepoch,
        uint globalreward,
        uint powreward,
        uint masternodereward,
        uint usercounter
    )
    {
        return (
            masternodeEpoch,
            masternodeCandidate,
            masternodeRound,
            miningEpoch,
            getMiningReward(),
            rewardsProofOfWork,
            rewardsMasternode,
            masternodeCounter
        );
    }

}
