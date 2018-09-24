//solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./compressed/libs/SafeMath.sol";
import "./compressed/libs/Ownable.sol";
import "./IcaelumVoting.sol";

contract CaelumVotings is Ownable {
    using SafeMath for uint;

    enum VOTE_TYPE {TOKEN, TEAM}

    struct Proposals {
        address tokenContract;
        uint totalVotes;
        uint proposedOn;
        uint acceptedOn;
        VOTE_TYPE proposalType;
    }

    struct Voters {
        bool isVoter;
        address owner;
        uint[] votedFor;
    }

    uint MAJORITY_PERCENTAGE_NEEDED = 60;
    uint MINIMUM_VOTERS_NEEDED = 10;
    bool public proposalPending;

    mapping(uint => Proposals) public proposalList;
    mapping (address => Voters) public voterMap;
    mapping(uint => address) public voterProposals;
    uint public proposalCounter;
    uint public votersCount;
    uint public votersCountTeam;

    /**
     * @notice Define abstract functions for later user
     */
    function isMasternodeOwner(address _candidate) public view returns(bool);
    function addToWhitelist(address _ad, uint _amount, uint daysAllowed) internal;
    function addMasternode(address _candidate) internal returns(uint);
    function updateMasternodeAsTeamMember(address _member) internal returns (bool);
    function isTeamMember (address _candidate) public view returns (bool);

    event NewProposal(uint ProposalID);
    event ProposalAccepted(uint ProposalID);

    /**
     * @dev Create a new proposal.
     * @param _contract Proposal contract address
     * @return uint ProposalID
     */
    function pushProposal(address _contract) onlyOwner public returns (uint) {
        if(proposalCounter != 0)
        require (pastProposalTimeRules (), "You need to wait 90 days before submitting a new proposal.");
        require (!proposalPending, "Another proposal is pending.");

        uint _contractType = IcaelumVoting(_contract).getContractType();
        proposalList[proposalCounter] = Proposals(_contract, 0, now, 0, VOTE_TYPE(_contractType));

        emit NewProposal(proposalCounter);

        proposalCounter++;
        proposalPending = true;

        return proposalCounter.sub(1);
    }

    /**
     * @dev Internal function that handles the proposal after it got accepted.
     * This function determines if the proposal is a token or team member proposal and executes the corresponding functions.
     * @return uint Returns the proposal ID.
     */
    function handleLastProposal () internal returns (uint) {
        uint _ID = proposalCounter.sub(1);

        proposalList[_ID].acceptedOn = now;
        proposalPending = false;

        address _address;
        uint _required;
        uint _valid;
        uint _type;
        (_address, _required, _valid, _type) = getTokenProposalDetails(_ID);

        if(_type == uint(VOTE_TYPE.TOKEN)) {
            addToWhitelist(_address,_required,_valid);
        }

        if(_type == uint(VOTE_TYPE.TEAM)) {
            if(_required != 0) {
                for (uint i = 0; i < _required; i++) {
                    addMasternode(_address);
                }
            } else {
                addMasternode(_address);
            }
            updateMasternodeAsTeamMember(_address);
        }

        emit ProposalAccepted(_ID);

        return _ID;
    }

    /**
     * @dev Rejects the last proposal after the allowed voting time has expired and it's not accepted.
     */
    function discardRejectedProposal() onlyOwner public returns (bool) {
        require(proposalPending);
        require (LastProposalCanDiscard());
        proposalPending = false;
        return (true);
    }

    /**
     * @dev Checks if the last proposal allowed voting time has expired and it's not accepted.
     * @return bool
     */
    function LastProposalCanDiscard () public view returns (bool) {

        uint daysBeforeDiscard = IcaelumVoting(proposalList[proposalCounter - 1].tokenContract).getExpiry();
        uint entryDate = proposalList[proposalCounter - 1].proposedOn;
        uint expiryDate = entryDate + (daysBeforeDiscard * 1 days);

        if (now >= expiryDate)
        return true;
    }

    /**
     * @dev Returns all details about a proposal
     */
    function getTokenProposalDetails(uint proposalID) public view returns(address, uint, uint, uint) {
        return IcaelumVoting(proposalList[proposalID].tokenContract).getTokenProposalDetails();
    }

    /**
     * @dev Returns if our 90 day cooldown has passed
     * @return bool
     */
    function pastProposalTimeRules() public view returns (bool) {
        uint lastProposal = proposalList[proposalCounter - 1].proposedOn;
        if (now >= lastProposal + 90 days)
        return true;
    }


    /**
     * @dev Allow any masternode user to become a voter.
     */
    function becomeVoter() public  {
        require (isMasternodeOwner(msg.sender), "User has no masternodes");
        require (!voterMap[msg.sender].isVoter, "User Already voted for this proposal");

        voterMap[msg.sender].owner = msg.sender;
        voterMap[msg.sender].isVoter = true;
        votersCount = votersCount + 1;

        if (isTeamMember(msg.sender))
        votersCountTeam = votersCountTeam + 1;
    }

    /**
     * @dev Allow voters to submit their vote on a proposal. Voters can only cast 1 vote per proposal.
     * If the proposed vote is about adding Team members, only Team members are able to vote.
     * A proposal can only be published if the total of votes is greater then MINIMUM_VOTERS_NEEDED.
     * @param proposalID proposalID
     */
    function voteProposal(uint proposalID) public returns (bool success) {
        require(voterMap[msg.sender].isVoter, "Sender not listed as voter");
        require(proposalID >= 0, "No proposal was selected.");
        require(proposalID <= proposalCounter, "Proposal out of limits.");
        require(voterProposals[proposalID] != msg.sender, "Already voted.");


        if(proposalList[proposalID].proposalType == VOTE_TYPE.TEAM) {
            require (isTeamMember(msg.sender), "Restricted for team members");
            voterProposals[proposalID] = msg.sender;
            proposalList[proposalID].totalVotes++;

            if(reachedMajorityForTeam(proposalID)) {
                // This is the prefered way of handling vote results. It costs more gas but prevents tampering.
                // If gas is an issue, you can comment handleLastProposal out and call it manually as onlyOwner.
                handleLastProposal();
                return true;
            }
        } else {
            require(votersCount >= MINIMUM_VOTERS_NEEDED, "Not enough voters in existence to push a proposal");
            voterProposals[proposalID] = msg.sender;
            proposalList[proposalID].totalVotes++;

            if(reachedMajority(proposalID)) {
                // This is the prefered way of handling vote results. It costs more gas but prevents tampering.
                // If gas is an issue, you can comment handleLastProposal out and call it manually as onlyOwner.
                handleLastProposal();
                return true;
            }
        }


    }

    /**
     * @dev Check if a proposal has reached the majority vote
     * @param proposalID Token ID
     * @return bool
     */
    function reachedMajority (uint proposalID) public view returns (bool) {
        uint getProposalVotes = proposalList[proposalID].totalVotes;
        if (getProposalVotes >= majority())
        return true;
    }

    /**
     * @dev Internal function that calculates the majority
     * @return uint Total of votes needed for majority
     */
    function majority () internal view returns (uint) {
        uint a = (votersCount * MAJORITY_PERCENTAGE_NEEDED );
        return a / 100;
    }

    /**
     * @dev Check if a proposal has reached the majority vote for a team member
     * @param proposalID Token ID
     * @return bool
     */
    function reachedMajorityForTeam (uint proposalID) public view returns (bool) {
        uint getProposalVotes = proposalList[proposalID].totalVotes;
        if (getProposalVotes >= majorityForTeam())
        return true;
    }

    /**
     * @dev Internal function that calculates the majority
     * @return uint Total of votes needed for majority
     */
    function majorityForTeam () internal view returns (uint) {
        uint a = (votersCountTeam * MAJORITY_PERCENTAGE_NEEDED );
        return a / 100;
    }

}
