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
