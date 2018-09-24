//solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./libs/IcaelumVoting.sol";

contract NewMemberProposal is IcaelumVoting {

    enum VOTE_TYPE {TOKEN, TEAM}
    VOTE_TYPE public contractType = VOTE_TYPE.TEAM;

    address memberAddress;
    uint totalMasternodes;
    uint votingDurationInDays;

    /**
     * @dev Create a new vote proposal for a team member.
     * @param _contract Future team member's address
     * @param _total How many masternodes do we want to give
     * @param _voteDuration How many days is this vote available
     */
    constructor(address _contract, uint _total, uint _voteDuration) public {
        require(_voteDuration >= 14 && _voteDuration <= 50, "Proposed voting duration does not meet requirements");
        memberAddress = _contract;
        totalMasternodes = _total;
        votingDurationInDays = _voteDuration;
    }

    /**
     * @dev Returns all details about this proposal
     */
    function getTokenProposalDetails() public view returns(address, uint, uint, uint) {
        return (memberAddress, totalMasternodes, 0, uint(contractType));
    }

    /**
     * @dev Displays the expiry date of contract
     * @return uint Days valid
     */
    function getExpiry() external view returns (uint) {
        return votingDurationInDays;
    }

    /**
     * @dev Displays the type of contract
     * @return uint Enum value {TOKEN, TEAM}
     */
    function getContractType () external view returns (uint){
        return uint(contractType);
    }
}
