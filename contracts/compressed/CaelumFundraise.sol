//solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./libs/Ownable.sol";
import "./libs/BasicToken.sol";
import "./libs/abstractCaelum.sol";

contract CaelumFundraise is Ownable, BasicToken, abstractCaelum {

    /**
     * In no way is Caelum intended to raise funds. We leave this code to demonstrate the potential and functionality.
     * Should you decide to buy a masternode instead of mining, you can by using this function. Feel free to consider this a tipping jar for our dev team.
     * We strongly advice to use the `buyMasternode`function, but simply sending Ether to the contract should work as well.
     */

    uint AMOUNT_FOR_MASTERNODE = 50 ether;
    uint SPOTS_RESERVED = 10;
    uint COUNTER;
    bool fundraiseClosed = false;

    /**
     * @dev Not recommended way to accept Ether. Can be safely used if no storage operations are called
     * The contract may revert all the gas because of the gas limitions on the fallback operator.
     * We leave it in as template for other projects, however, for Caelum the function deposit should be adviced.
     */
    function() payable public {
        require(msg.value == AMOUNT_FOR_MASTERNODE && msg.value != 0);
        receivedFunds();
    }

    /** @dev This is the recommended way for users to deposit Ether in return of a masternode.
     * Users should be encouraged to use this approach as there is not gas risk involved.
     */
    function buyMasternode () payable public {
        require(msg.value == AMOUNT_FOR_MASTERNODE && msg.value != 0);
        receivedFunds();
    }

    /**
     * @dev Forward funds to owner before making any action. owner.transfer will revert if fail.
     */
    function receivedFunds() internal {
        require(!fundraiseClosed);
        require (COUNTER <= SPOTS_RESERVED);
        owner.transfer(msg.value);
        addMasternode(msg.sender);
    }

}
