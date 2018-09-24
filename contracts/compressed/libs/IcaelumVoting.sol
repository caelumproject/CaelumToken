//solium-disable linebreak-style
pragma solidity ^0.4.24;

interface IcaelumVoting {
    function getTokenProposalDetails() external view returns(address, uint, uint, uint);
    function getExpiry() external view returns (uint);
    function getContractType () external view returns (uint);
}
