import { time } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

describe("Vesting", async function () {
  let start: number;
  let end: number;
  let token: Contract;
  let signer: SignerWithAddress;
  let instance: Contract;
  let allocationOwner: SignerWithAddress;
  let notAllocationOwner: SignerWithAddress;
  let frozenAddress: SignerWithAddress;
  let ethFee: BigNumber;

  beforeEach(async () => {
    const now = await time.latest();
    start = time.duration.days(1) + now;
    end = start + time.duration.days(90);
    ethFee = ethers.utils.parseEther("0.0005");
    [signer, allocationOwner, notAllocationOwner, frozenAddress] =
      await ethers.getSigners();
    const GameSwift = await ethers.getContractFactory("GameSwift");
    token = await GameSwift.deploy();

    const MigratedVesting = await ethers.getContractFactory("MigratedVesting");
    instance = await MigratedVesting.deploy(token.address, ethFee, start, end);
  });

  async function setAllocations(
    wallets: string[],
    initialSupplies: BigNumber[],
    totalRemaining: BigNumber[]
  ) {
    const batchSize = 20;
    let total: BigNumber = BigNumber.from(0);
    for (let i = 0; i < wallets.length; i += batchSize) {
      const batchWallets = wallets.slice(i, i + batchSize);
      const batchInitialSupplies = initialSupplies.slice(i, i + batchSize);
      const batchTotalRemaining = totalRemaining.slice(i, i + batchSize);

      total = total.add(initialSupplies[i]).add(totalRemaining[i]);

      const tx = await instance.setUserAllocation(
        batchWallets,
        batchInitialSupplies,
        batchTotalRemaining
      );

      await tx.wait();
    }

    await token.transfer(instance.address, total);
  }

  async function freezeWallets(wallets: string[], values: boolean[]) {
    const batchSize = 20;
    for (let i = 0; i < wallets.length; i += batchSize) {
      const batchWallets = wallets.slice(i, i + batchSize);

      const tx = await instance.setWalletFrozen(batchWallets, values);

      await tx.wait();
    }
  }

  it("should allow user to set user allocation", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address],
      [initialSupply],
      [totalRemaining]
    );

    expect(
      await instance.initialDistribution(allocationOwner.address)
    ).to.equal(initialSupply);

    expect(await instance.userTotal(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    expect(await instance.vestedAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await instance.vestedAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await instance.releasedAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await instance.releasableAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await instance.isWalletFrozen(allocationOwner.address)).to.equal(
      false
    );

    expect(await instance.unvestedAmount(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );
  });

  it("should revert when not allocation owner tries to set user allocation", async function () {
    await expect(
      instance
        .connect(notAllocationOwner)
        .setUserAllocation(
          [notAllocationOwner.address],
          [ethers.utils.parseEther("100")],
          [ethers.utils.parseEther("500")]
        )
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("should allow allocation owner to freeze wallets", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address, frozenAddress.address],
      [initialSupply, initialSupply],
      [totalRemaining, totalRemaining]
    );

    await freezeWallets([frozenAddress.address], [true]);

    expect(await instance.isWalletFrozen(frozenAddress.address)).to.equal(true);
  });

  it("should revert when not allocation owner tries to freeze wallets", async function () {
    await expect(
      instance
        .connect(notAllocationOwner)
        .setWalletFrozen([notAllocationOwner.address], [true])
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("should allow allocation owner to unfreeze wallets", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address, frozenAddress.address],
      [initialSupply, initialSupply],
      [totalRemaining, totalRemaining]
    );

    await freezeWallets([frozenAddress.address], [true]);

    expect(await instance.isWalletFrozen(frozenAddress.address)).to.equal(true);

    await freezeWallets([frozenAddress.address], [false]);

    expect(await instance.isWalletFrozen(frozenAddress.address)).to.equal(
      false
    );
  });

  it("should allow allocation owner to release vested tokens", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address],
      [initialSupply],
      [totalRemaining]
    );

    await time.increase(end);

    await instance.connect(allocationOwner).release({
      value: ethFee,
    });

    expect(await instance.releasableAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await instance.unvestedAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await token.balanceOf(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    expect(await instance.vestedAmount(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    expect(await instance.releasedAmount(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    await expect(
      instance.connect(allocationOwner).release({ value: ethFee })
    ).to.revertedWithCustomError(instance, "NothingToRelease");
  });

  it("should allow owner to withdraw eth fee", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address],
      [initialSupply],
      [totalRemaining]
    );

    await time.increase(end);

    await instance.connect(allocationOwner).release({
      value: ethFee,
    });

    const balanceBefore = await frozenAddress.getBalance();
    await instance.withdrawNative(frozenAddress.address, ethFee);
    const balanceAfter = await frozenAddress.getBalance();

    expect(balanceAfter).to.equal(balanceBefore.add(ethFee));
  });

  it("should revert when not owner tries to withdraw eth fee", async function () {
    await expect(
      instance
        .connect(notAllocationOwner)
        .withdrawNative(notAllocationOwner.address, ethFee)
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("should revert when user tries to withdraw allocation without fee", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address],
      [initialSupply],
      [totalRemaining]
    );

    await time.increase(end);

    await expect(
      instance.connect(allocationOwner).release()
    ).to.be.revertedWithCustomError(instance, "InsufficientAmount");
  });

  it("should allow allocation owner to release initial distribution at the beginning", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address],
      [initialSupply],
      [totalRemaining]
    );

    await time.setNextBlockTimestamp(start);

    await instance.connect(allocationOwner).release({
      value: ethFee,
    });

    expect(await instance.releasableAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await instance.unvestedAmount(allocationOwner.address)).to.equal(
      totalRemaining
    );

    expect(await token.balanceOf(allocationOwner.address)).to.equal(
      initialSupply
    );

    expect(await instance.vestedAmount(allocationOwner.address)).to.equal(
      initialSupply
    );

    expect(await instance.releasedAmount(allocationOwner.address)).to.equal(
      initialSupply
    );
  });

  it("should allow allocation owner to release  vested tokens linearly", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address],
      [initialSupply],
      [totalRemaining]
    );

    const duration = end - start;

    const releaseDuration = time.duration.days(30);
    const linearVested = totalRemaining.mul(releaseDuration).div(duration);
    const totalReleasable = linearVested.add(initialSupply);
    let nextBlockTimestamp = start + releaseDuration;
    await time.setNextBlockTimestamp(nextBlockTimestamp);

    await instance.connect(allocationOwner).release({
      value: ethFee,
    });

    expect(await instance.unvestedAmount(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining).sub(totalReleasable)
    );

    expect(await token.balanceOf(allocationOwner.address)).to.equal(
      totalReleasable
    );

    expect(await instance.vestedAmount(allocationOwner.address)).to.equal(
      totalReleasable
    );

    expect(await instance.releasedAmount(allocationOwner.address)).to.equal(
      totalReleasable
    );

    await time.setNextBlockTimestamp(end);

    await instance.connect(allocationOwner).release({
      value: ethFee,
    });

    expect(await instance.unvestedAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await token.balanceOf(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    expect(await instance.vestedAmount(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    expect(await instance.releasedAmount(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    await expect(
      instance.connect(allocationOwner).release({ value: ethFee })
    ).to.revertedWithCustomError(instance, "NothingToRelease");
  });

  it("should revert if allocation owner tries to release before start", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address],
      [initialSupply],
      [totalRemaining]
    );

    await time.setNextBlockTimestamp(start - 1);

    await expect(
      instance.connect(allocationOwner).release({ value: ethFee })
    ).to.be.revertedWithCustomError(instance, "NothingToRelease");
  });

  it("should withdraw total allocation after vesting end", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address],
      [initialSupply],
      [totalRemaining]
    );

    await time.setNextBlockTimestamp(end + time.duration.years(1));

    await instance.connect(allocationOwner).release({
      value: ethFee,
    });

    expect(await instance.releasableAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await instance.unvestedAmount(allocationOwner.address)).to.equal(
      BigNumber.from(0)
    );

    expect(await token.balanceOf(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    expect(await instance.vestedAmount(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    expect(await instance.releasedAmount(allocationOwner.address)).to.equal(
      initialSupply.add(totalRemaining)
    );

    await expect(
      instance.connect(allocationOwner).release({ value: ethFee })
    ).to.revertedWithCustomError(instance, "NothingToRelease");
  });

  it("should allow owner token from contract", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [allocationOwner.address],
      [initialSupply],
      [totalRemaining]
    );

    const balanceBefore = await token.balanceOf(signer.address);
    await instance.withdrawToken(
      token.address,
      signer.address,
      initialSupply.add(totalRemaining)
    );

    const balanceAfter = await token.balanceOf(signer.address);

    expect(balanceAfter).to.equal(
      balanceBefore.add(initialSupply).add(totalRemaining)
    );
  });

  it("should revert when not owner tries to withdraw token from contract", async function () {
    await expect(
      instance
        .connect(notAllocationOwner)
        .withdrawToken(token.address, notAllocationOwner.address, 0)
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("should revert when allocation owner tries to withdraw tokens and is frozen", async function () {
    const initialSupply = ethers.utils.parseEther("100");
    const totalRemaining = ethers.utils.parseEther("500");

    await setAllocations(
      [frozenAddress.address],
      [initialSupply],
      [totalRemaining]
    );

    await freezeWallets([frozenAddress.address], [true]);

    await expect(
      instance.connect(frozenAddress).release({ value: ethFee })
    ).to.be.revertedWithCustomError(instance, "NothingToRelease");
  });
});
