import { expect } from "chai";
import { ethers } from "hardhat";

describe("MyToken", function () {
  it("Test contract", async function () {
    const ContractFactory = await ethers.getContractFactory("MyToken");

    const initialOwner = (await ethers.getSigners())[0].address;
    const recipient = (await ethers.getSigners())[1].address;

    const instance = await ContractFactory.deploy(initialOwner, recipient);
    await instance.waitForDeployment();

    expect(await instance.name()).to.equal("MyToken");
  });
});
