import { ethers, run } from "hardhat";
import { DEFAULT_ETH_FEE, GAMESWIFT_TOKEN } from "./constants";
import { Allocations } from "./types";
import { parseCsvToDefinedAllocations } from "./utils";
import { VESTINGS } from "./vestingConfigurations";

const START = 1739487600;
const END_DEFAULT = 1816120800;

function allocationIsCsvPah(
  allocation: Allocations
): allocation is { pathToCsv: string } {
  return (allocation as { pathToCsv: string }).pathToCsv !== undefined;
}

async function main() {
  const contractAddresses = [];

  for (const [vestingName, vesting] of Object.entries(VESTINGS)) {
    const MigratedVesting = await ethers.getContractFactory("MigratedVesting");
    const allocations = vesting.allocations
      ? allocationIsCsvPah(vesting.allocations)
        ? parseCsvToDefinedAllocations(vesting.allocations.pathToCsv)
        : vesting.allocations
      : [];

    console.log(`Deploying ${vestingName} vesting contract...`);

    const start = vesting.start ? vesting.start : START;
    const ethFee = vesting.ethFee ? vesting.ethFee : DEFAULT_ETH_FEE;
    const end = vesting.end ? vesting.end : END_DEFAULT;

    const vestingInstance = await MigratedVesting.deploy(
      GAMESWIFT_TOKEN,
      ethFee,
      START,
      end
    );

    console.log(`Vesting contract deployed to: ${vestingInstance.address}`);

    contractAddresses.push(`${vestingName}: ${vestingInstance.address}`);
    await vestingInstance.deployTransaction.wait(10);

    await run("verify:verify", {
      address: vestingInstance.address,
      constructorArguments: [GAMESWIFT_TOKEN, ethFee, START, end],
    });

    const batchSize = 20;
    console.log("Allocating users...");
    for (let i = 0; i < allocations.length; i += batchSize) {
      const batch = allocations.slice(i, i + batchSize);
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

    console.log("Setting frozen wallets...");

    const frozenAddresses = allocations
      .filter((allocation) => allocation.frozen)
      .map((allocation) => allocation.address);
    if (frozenAddresses.length === 0) {
      console.log("No frozen wallets to set");
      continue;
    }

    const tx = await vestingInstance.setWalletFrozen(
      frozenAddresses,
      frozenAddresses.map(() => true)
    );

    await tx.wait();

    console.log("Frozen wallets set");
  }

  console.log(contractAddresses);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
