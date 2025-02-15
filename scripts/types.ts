import { BigNumber } from "ethers";

export type VestingType =
  | "Foundation"
  | "Seed"
  | "Private"
  | "Hypera2"
  | "KuCoin"
  | "Hashed"
  | "Hashed2"
  | "Laskarzewski"
  | "Parzynski";

export type Vesting = {
  end: number;
  address?: string;
  start?: number;
  ethFee?: BigNumber;
  allocations?: Allocations;
};

export type DefinedAllocation = {
  address: string;
  initialSupply: BigNumber;
  totalRemaining: BigNumber;
  frozen?: boolean;
};

export type Allocations =
  | DefinedAllocation[]
  | {
      pathToCsv: string;
    };
