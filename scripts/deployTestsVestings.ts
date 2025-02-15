import { ethers, run } from "hardhat";
import { TEST_ETH_FEE, TEST_START, TEST_TOKEN } from "./constants";
import { DefinedAllocation } from "./types";
import { TEST_VESTINGS } from "./vestingConfigurations";

async function main() {
  for (const [
    vestingName,
    { end, start, ethFee, allocations },
  ] of Object.entries(TEST_VESTINGS)) {
    const MigratedVesting = await ethers.getContractFactory("MigratedVesting");
    const vestingStart = start ? start : TEST_START;
    const vestingEthFee = ethFee ? ethFee : TEST_ETH_FEE;
    const vestingAllocations = (
      allocations ? allocations : []
    ) as DefinedAllocation[];

    console.log(`Deploying ${vestingName} vesting contract...`);

    const vestingInstance = await MigratedVesting.deploy(
      TEST_TOKEN,
      vestingEthFee,
      vestingStart,
      end
    );

    console.log(`Vesting contract deployed to: ${vestingInstance.address}`);

    await vestingInstance.deployTransaction.wait(10);

    await run("verify:verify", {
      address: vestingInstance.address,
      constructorArguments: [TEST_TOKEN, vestingEthFee, vestingStart, end],
    });

    const batchSize = 20;
    console.log("Allocating users...");
    for (let i = 0; i < vestingAllocations.length; i += batchSize) {
      const batch = vestingAllocations.slice(i, i + batchSize);
      const wallets = batch.map((allocation) => allocation.address);
      const initialSupplies = batch.map(
        (allocation) => allocation.initialSupply
      );
      const totalRemaining = batch.map(
        (allocation) => allocation.totalRemaining
      );

      const tx = await vestingInstance.setUserAllocation(
        wallets,
        initialSupplies,
        totalRemaining
      );

      await tx.wait();
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
