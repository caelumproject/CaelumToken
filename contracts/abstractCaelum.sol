//solium-disable linebreak-style
pragma solidity ^0.4.24;

contract abstractCaelum {
    function isMasternodeOwner(address _candidate) public view returns(bool);
    function addToWhitelist(address _ad, uint _amount, uint daysAllowed) internal;
    function addMasternode(address _candidate) internal returns(uint);
    function deleteMasternode(uint entityAddress) internal returns(bool success);
    function getLastPerUser(address _candidate) public view returns (uint);
    function getMiningReward() public view returns(uint);
}
