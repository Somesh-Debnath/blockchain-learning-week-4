// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const onlyAdministratorChecker = await hre.ethers.deployContract("OnlyAdministratorChecker", [], {});
  await onlyAdministratorChecker.waitForDeployment();

  console.log(
    `OnlyAdministratorChecker Contract Deployed as ${onlyAdministratorChecker.target}.`);

  const productSupplyChain = await hre.ethers.deployContract("ProductSupplyChain", [onlyAdministratorChecker.target], {});

  await productSupplyChain.waitForDeployment();

  console.log(
    `ProductSupplyChain Contract Deployed at ${productSupplyChain.target}.`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});