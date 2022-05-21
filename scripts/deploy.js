const {ethers} = require ("hardhat")

async function main (){
    const theChickenLabcontract = await ethers.getContractFactory ("TheChickenLab");

    const deployedTheChickenLabcontract = await theChickenLabcontract.deploy();

    await deployedTheChickenLabcontract.deployed();

    console.log("TheChickenLab deployed to:", deployedTheChickenLabcontract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });