# CaelumToken
Home of the CaelumProject

**Docs and readme under construction!**

# Caelum project Token (CLM)

This guide is a quickstart tutorial. A more technical setup will depend on the mining software of your choice.

Mining instructions
---

CLM Token details:

- Contract address:   **0x7600bf5112945f9f006c216d5d6db0df2806edc6**
- Total supply:       21,000,000 tokens
- Decimals:           8 Decimals

Contract address:  https://etherscan.io/address/0x7600bf5112945f9f006c216d5d6db0df2806edc6

Token tracker:     https://etherscan.io/token/0x7600bf5112945f9f006c216d5d6db0df2806edc6

### Step 1: Prepare your Ethereum account ###
- Go to [**MyEtherWallet**](https://www.myetherwallet.com) (MEW).
- In the top right hand corner select **ETH (myetherwallet.com)** (a green bar at the bottom will appear telling you you have succesfully connected).
- If not already there, click **New Wallet**
- Enter a password you can remember and click 'Create New Wallet'
- Download & save your Keystore file in a safe space and click 'I Understand. Continue'
- Save your Private Key in a safe space.
- Get your wallet address by clicking on 'View Wallet Info'
- Select 'Private Key' and then enter the private key previously saved then click 'unlock'.
- Alternatively, use the keystore file.

### Step 2: Download 0xbtc mining software
It's important to use mining software that supports solo mining for the testnet version. While great performance improvements have been made to the 0xbtc mining software, most latest versions have excluded solo mining due to high difficulty.

Suggested mining software:

 - Mining-Visualizer (MVis)' TokenMiner (AMD/OpenCL): [https://github.com/mining-visualizer/MVis-tokenminer](https://github.com/mining-visualizer/MVis-tokenminer)
 - COSMiC v3.4 (nVidia/CUDA): [https://bitbucket.org/LieutenantTofu/cosmic-v3/](https://bitbucket.org/LieutenantTofu/cosmic-v3/)
- Original 0xbitcoin miner (CPU) https://github.com/0xbitcoin/0xbitcoin-gpuminer/tree/master/dist/windows

**Carefully read and follow the installation instructions for the  software you have chosen to get started.**

### Step 3: Configure the mining software

This depends on the version you downloaded. All needed parameters are listed below (depending on the software version, you might need to change `config web3provider` with the host and port):

- (MINER) account: your ethereum address generated in step 1
- (MINER) private key: the private key generated in step 1
- (TOKEN) contract/address: **0x7600bf5112945f9f006c216d5d6db0df2806edc6**
- gasprice: 5 gwei

### Step 4: Start the mining software

If you could not change the miner account/private key (depending of software), you might need to enter `accounts list` in the miner terminal. If no account exists, use `accounts new`. Fund the selected Ethereum account.

You should now be mining CLM tokens!

![Alt text](https://monosnap.com/image/cwV7mFtb5Wf167TuUDdnsK8RH9uyuQ.png)

Depending on the software, you will see a bunch of transactions appearing on the terminal, along with success messages. This means you successfuly minted a block.


# Distribution and rewards

# Caelum project token (CLM)

CLM is an entirely new token distribution model for the Ethereum network. Caelum project is the first to successfuly implement a Proof of Work mining distribution combined with Masternode reward structure.

CLM will be the primary token for using any Caelum related project.

## Deployment
In order to deploy the entire project, a few steps are needed. Since CLM uses abstract contracts, all contract must be deployed seperated. This approach has the benefit that the contract can be updated in the future, eliminating the need to fork or redeploy a new token should any issue occur.

- Deploy `DataStorage.sol`, `Masternode.sol`, and `SCITokenBase.sol` on the network.
- On the `Masternode` contract, call the `setDataStorage` function with the `DataStorage` contract's deployed address.
- On the `SCI59TokenBase` contract, call the setDataStorage function with the `Masternode` contract's deployed address.

The `SCI59TokenBase` contract is now ready to start minting using 0xbitcoin mining software of your choice.
Input the `SCI59TokenBase` address in the mining software to start mining CLM tokens.

## Distribution of CLM explained

Before we understand why a masternode reward system matters, and what advantages it offers, we need to understand how the entire supply will be distributed over the cours of multiple years.



### Masternode rewards

The usage of masternode rewards has proven to be an easy distribution method, gaining a passive amount of tokens in return for a collateral amount of tokens. This system, first introduced in Dash, has gained a lot of popularity over regular Proof of Work mining methods.

While many tokens and dapps exists on the Ethereum network, none has been innovative enough to try and create a Proof of Work + masternode reward system. Most projects choose to distribute their tokens during ICO events, given the fact that this is a perfect way to raise large capitals in a short period of time. The major drawback in this approach is that most of those ICO projects have no further intention on  innovation or producing a product once the funds are transferred in their personal wallets.

Tough the concept of raising large capitals may be tempting, the Caelum Project team decided to launch the project without an ICO event. We created and developed the code in our own time, choosing innovation and technology over quick cash.

### Reward structure

Caelum Project will use what's known as a fair reward structure. This simply means that anyone can join the project and have an equal chance to earn CLM tokens.

Each mining phase will last approximatly 1 month. +/- 6 blocks will be produced per hour. Every mining epoch will last 4500 blocks.

Calculation method: `4500 / (6 blocks*24hours)` gives an average of 32 days.

### Reward calculation

To calculate the rewards, we must determine the current mining phase. The calculation method is therefore multiplied by 10.
Ethereum will always round numbers, meaning having a multification by factor 10 is a valid way of determing the phase.

   function calculateRewardStructures() public {
           uint getStageOfMining = mining_epoch / 4500 * 10;

           if(onTestnet) {
               getStageOfMining = mining_epoch / 25 * 10;
           }

           // Set first month full PoW and after 9 months full MASTERNODE (small % for miners to incentivize keeping mining)
           if (getStageOfMining < 10) {rewards_ProofOfWork = rewards_globalReward ; rewards_Masternodes = 0; return;}
           if (getStageOfMining > 90) {rewards_ProofOfWork = rewards_globalReward / 100 * 2 ; rewards_Masternodes = rewards_globalReward / 100 * 98;return;}


           uint _rew = (rewards_globalReward / 100) * getStageOfMining;
           uint remain = (rewards_globalReward - _rew);

           setBaseRewards(remain, _rew);
       }

Let's dive in detail of what's happening here.

First off, we calculate the current mining stage.  Ethereum will always round numbers, meaning having a multification by factor 10 is a valid way of determing the phase. Our first 4500 blocks will return `1`, the next 4500 `2` , and so on.

Next we check if we are on a testnet. During testnet runs, we can lower the amount of needed blocks before switching to the next mining stage. Without this parameter, it would take years to fully debug and run the contract on a testnet.

Now things are getting intresting.

**During launch**

`if (getStageOfMining < 10) {rewards_ProofOfWork = rewards_globalReward ; rewards_Masternodes = 0; return;}`

This means that during the first month, the mining reward is very low. This is to prevent the `instant mining attack`. During such attack, powerfull miners race to mine the first hundreds of blocks, leaving out small scale miners. While this hurts the fair distribution methodology, it also hurts the financial future of a token once it's listed on exchanges since those attackers are more then likely to dump all instamined tokens at once. Using this protection, everyone has a fair chance of preparing mining software until we reached the second month of the mining phase.

**After PoW phase**

`if (getStageOfMining > 90) {rewards_ProofOfWork = rewards_globalReward / 100 * 2 ; rewards_Masternodes = rewards_globalReward / 100 * 98;return;}`

Equally, we takes measures that prevent our userbase to stop mining once the PoW method is over, and CLM is fully masternode controled. PoW miners will always receive a minimum of 2% once the mining phase is over.

**Proportional reward structure**

   uint _rew = (rewards_globalReward / 100) * getStageOfMining;
   uint remain = (rewards_globalReward - _rew);

This function calculates the reward in relation to the mining stage. If we would be in stage 4, the reward is calculated as 40%.
The remaining reward then goes towards the masternodes. The reward structure is always 100% of the initial `reward` amount, divided between the PoW and Masternodes in relation to the mining stage as percentage. This means that CLM launches as 100% Proof of Work and 0% Masternode, and with each mining phase (4500 blocks), 10% will be decreased from the PoW and increased at Masternode rewards until we reached 100% masternode rewards (98% masternode, 2% miners as explained above)

**Graphical overview of reward distributions during first year**

![Alt text](https://s8.postimg.cc/9dlpx1wmt/Plot_4.jpg)


**Graphical overview of reward distributions on longer term**

![Alt text](https://s8.postimg.cc/9dlpx1h79/Plot_2.png)

### Conclusion

Masternodes are a good way to distribute tokens, where only a small amount of input is required to obtain enough tokens to use as collateral for setting up the masternode.

In our 144 week example, only 7% of the total rewards will be distributed to miners, where 78% will be distributed amongst masternodes. The biggest cavaet for the holders is that mining is required to obtain enought tokens to enjoy the masternode distribution method; This trivial approach ensures a durable solution where CLM tokens will have an intrestic value because of the mining fees.

When taking these calculations in consideration, it's important that the user is aware that every masternode will receive a block reward in turn, just like any other masternode system. Once every masternode holder has been payed, a new round opens and the payout starts from the first address in line.
