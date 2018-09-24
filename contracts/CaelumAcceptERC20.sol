//solium-disable linebreak-style
pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "./abstractCaelum.sol";

contract CaelumAcceptERC20 is Ownable, abstractCaelum {
    using SafeMath for uint;

    address[] public tokensList;
    bool setOwnContract = true;

    struct _whitelistTokens {
        address tokenAddress;
        bool active;
        uint requiredAmount;
        uint validUntil;
        uint timestamp;
    }

    mapping(address => mapping(address => uint)) public tokens;
    mapping(address => _whitelistTokens) acceptedTokens;

    event Deposit(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);

    /**
     * @dev Return the base rewards. This should be overrided by the miner contract.
     * Return a base value for standalone usage ONLY.
     */
    function getMiningReward() public view returns(uint) {
        return 50 * 1e8;
    }


    /**
     * @notice Allow the dev to set it's own token as accepted payment.
     * @dev Can be hardcoded in the constructor. Given the contract size, we decided to separate it.
     * @return bool
     */
    function addOwnToken() onlyOwner public returns (bool) {
        require(setOwnContract);
        addToWhitelist(this, 5000 * 1e8, 36500);
        setOwnContract = false;
        return true;
    }

    // TODO: Set visibility
    /**
     * @notice Add a new token as accepted payment method.
     * @param _token Token contract address.
     * @param _amount Required amount of this Token as collateral
     * @param daysAllowed How many days will we accept this token?
     */
    function addToWhitelist(address _token, uint _amount, uint daysAllowed) internal {
        _whitelistTokens storage newToken = acceptedTokens[_token];
        newToken.tokenAddress = _token;
        newToken.requiredAmount = _amount;
        newToken.timestamp = now;
        newToken.validUntil = now + (daysAllowed * 1 days);
        newToken.active = true;

        tokensList.push(_token);
    }

    /**
     * @dev internal function to determine if we accept this token.
     * @param _ad Token contract address
     * @return bool
     */
    function isAcceptedToken(address _ad) internal view returns(bool) {
        return acceptedTokens[_ad].active;
    }

    /**
     * @dev internal function to determine the requiredAmount for a specific token.
     * @param _ad Token contract address
     * @return bool
     */
    function getAcceptedTokenAmount(address _ad) internal view returns(uint) {
        return acceptedTokens[_ad].requiredAmount;
    }

    /**
     * @dev internal function to determine if the token is still accepted timewise.
     * @param _ad Token contract address
     * @return bool
     */
    function isValid(address _ad) internal view returns(bool) {
        uint endTime = acceptedTokens[_ad].validUntil;
        if (block.timestamp < endTime) return true;
        return false;
    }

    /**
     * @notice Returns an array of all accepted token. You can get more details by calling getTokenDetails function with this address.
     * @return array Address
     */
    function listAcceptedTokens() public view returns(address[]) {
        return tokensList;
    }

    /**
     * @notice Returns a full list of the token details
     * @param token Token contract address
     */
    function getTokenDetails(address token) public view returns(address ad,uint required, bool active, uint valid) {
        return (acceptedTokens[token].tokenAddress, acceptedTokens[token].requiredAmount,acceptedTokens[token].active, acceptedTokens[token].validUntil);
    }

    /**
     * @notice Public function that allows any user to deposit accepted tokens as collateral to become a masternode.
     * @param token Token contract address
     * @param amount Amount to deposit
     */
    function depositCollateral(address token, uint amount) public {
        require(isAcceptedToken(token), "ERC20 not authorised");  // Should be a token from our list
        require(amount == getAcceptedTokenAmount(token));         // The amount needs to match our set amount
        require(isValid(token));                                  // It should be called within the setup timeframe

        tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);

        require(StandardToken(token).transferFrom(msg.sender, this, amount), "error with token");
        emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);

        addMasternode(msg.sender);
    }

    /**
     * @notice Public function that allows any user to withdraw deposited tokens and stop as masternode
     * @param token Token contract address
     * @param amount Amount to withdraw
     */
    function withdrawCollateral(address token, uint amount) public {
        require(token != 0); // token should be an actual address
        require(isAcceptedToken(token), "ERC20 not authorised"); // Should be a token from our list
        require(isMasternodeOwner(msg.sender)); // The sender must be a masternode prior to withdraw
        require(tokens[token][msg.sender] == amount); // The amount must be exactly whatever is deposited

        uint amountToWithdraw = tokens[token][msg.sender];
        tokens[token][msg.sender] = 0;

        deleteMasternode(getLastPerUser(msg.sender));

        if (!StandardToken(token).transfer(msg.sender, amountToWithdraw)) revert();
        emit Withdraw(token, msg.sender, amountToWithdraw, amountToWithdraw);
    }

}
