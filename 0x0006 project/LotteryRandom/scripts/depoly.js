const {ethers} = require("hardhat");
require("dotenv").config({ path:".env" });
require("@nomiclabs/hardhat-etherscan");
const { FEE, VAR_CORDINATOR, LINK_TOKEN, KEY_HASH, VRF_COORDINATOR} = require("../constants");

async function main(){
    const lotteryRandom = await ethers.getContractFactory("LotteryRandom");
    const deployLotterRandomContract = await lotteryRandom.deploy(
        VRF_COORDINATOR,
        LINK_TOKEN,
        KEY_HASH,
        FEE
    );

    await deployLotterRandomContract.deploy();
    
    console.log(
        "Verify Contrat Address: ",
        deployLotterRandomContract.getAddress()
    );

    console.log("Sleeping.....");

    await sleep(30000);

    //await hre

    function sleep(ms){
        return new Promise((resolve) => setTimeout(resolve, ms));
    }
}

    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });

