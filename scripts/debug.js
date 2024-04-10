// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require('hardhat');
const { getConfigPath } = require('./private/_helpers.js');
const { getIbcApp } = require('./private/_vibc-helpers.js');

async function main() {
    const accounts = await hre.ethers.getSigners();
    const config = require(getConfigPath());
    const sendConfig = config.sendPacket;

    const networkName = hre.network.name;
    // Get the contract type from the config and get the contract
    const ibcApp = await getIbcApp(networkName);

    // Do logic to prepare the packet
    const channelId = sendConfig[`${networkName}`]["channelId"];
    const channelIdBytes = hre.ethers.encodeBytes32String(channelId);
    const timeoutSeconds = sendConfig[`${networkName}`]["timeout"];
    

    // await ibcApp.connect(accounts[0]).mintNFT1(
    //   accounts[0].address
    // );
    // NFT contract.

    console.log(await ibcApp.connect(accounts[0]).getUserOwnedTokenIds(accounts[0])) // > get token balance.

    console.log(await ibcApp.connect(accounts[0]).balanceOf(accounts[0])) // > get token balance.
    console.log(await ibcApp.connect(accounts[0]).tokenOfOwnerByIndex(accounts[0], 0)); // get tokenID by index. iter balance count.
    console.log(await ibcApp.connect(accounts[0]).tokenURI(1)); // get token URI by tokenID


    
    // console.log(await ibcApp.connect(accounts[0]).));
    // Send the packet
    // await ibcApp.connect(accounts[0]).sendPacket(
    //     channelIdBytes,
    //     timeoutSeconds,
    //     // Define and pass optionalArgs appropriately or remove if not needed    
    //     );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});