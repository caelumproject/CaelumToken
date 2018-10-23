# improvements

All contracts are now seperated. This means that each contract has it's own specific tasks and storage purposes.

### CaelumToken

 - Base ERC20 token
 - Stores all monetary actions like collaterals
 - Will run forever on the ETH network

 Can be called from the **miner contract** for:

 - Token minting rewards

 Can be called from the **masternode contract** for:

 - Depositing collaterals
 - Withdrawing collaterals


### CaelumMasternode

  - Main masternode logic placeholder
  - Reward calculation between PoW and masternodes
  - Eternal storage container for masternode datastorage

### CaelumMiner

  - Main Proof of Work logic placeholder
  - Provides the miners with challenges to solve
  - Full EIP918 compatible

----

# Token swap procedure

The new masternode contract address is ``

Everyone must swap the old CLM tokens ( deployed at `0x7600bF5112945F9F006c216d5d6db0df2806eDc6`). This process is fully automated in a way that no human interaction is needed, thus can be considered a safe option to swap tokens.

Due to blockchain and platform limitations, it is impossible to simply clone all masternode data and award new tokens to the holders. By doing so, it would become impossible for the masternode holders to withdraw any of the new tokens, since an approval is needed and this can only be granted by the holder himself.

**If you have any masternodes:**

Use the `withdrawCollateral` function on the old contract to retrieve all your tokens.
It is recommended to withdraw all your CLM tokens in a single transaction. For example, if you have 2 masternodes, then you should call the `withdrawCollateral` function with value `1000000000000` to withdraw both masternodes. Follow the guide below to swap your tokens.

**General guidelines**

Step 1: On the old contract, call the `approve` function with the new contract address, and the amount of tokens you hold. Remember to add 8 decimals at the end. The best way to copy-paste your balance is to call the `balanceOf` function with your address. You can use the return value produced as value.

Step 2: After the approval function has confirmed, go to the new contract code.

Step 3: Choose the `upgradeTokens` function. Confirm this action. This will get your available tokens from the old contract and replace them with new tokens.

Step 4: After this transaction has been confirmed on the blockchain, you should see the new tokens in your wallet. To verify, you can use the `balanceOf` function to quickly check this.
