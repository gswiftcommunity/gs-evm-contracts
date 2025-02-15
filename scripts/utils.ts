import * as fs from "fs";
import { ethers } from "hardhat";
import { DefinedAllocation } from "./types";

export function parseCsvToDefinedAllocations(
  csvPath: string
): DefinedAllocation[] {
  const csv = fs.readFileSync(csvPath, "utf-8");
  const lines = csv.split("\n");
  const allocations: DefinedAllocation[] = [];

  for (let i = 1; i < lines.length; i++) {
    const line = lines[i];
    const lineSplit = line.split(",");
    const address = lineSplit[0];
    const initialSupply = lineSplit[3];
    const totalRemaining = lineSplit[4];
    const frozen = lineSplit[5];

    allocations.push({
      address,
      initialSupply: ethers.utils.parseEther(initialSupply),
      totalRemaining: ethers.utils.parseEther(totalRemaining),
      frozen: frozen === "1",
    });
  }
  return allocations;
}
