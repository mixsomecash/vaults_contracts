const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

describe("VaultFactory", function () {
  let vaultFactory;

  beforeEach(async function () {
    const Factory = await ethers.getContractFactory("VaultFactory");
    vaultFactory = await upgrades.deployProxy(Factory, [], { initializer: "initialize" });
  });

  it("should create a vault", async function () {
    await expect(vaultFactory.createChild(
      "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512", 
      "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512", 
      "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
      1, 
      2, 
      20
    )).to.emit(vaultFactory, "VaultCreated").withArgs(anyValue);
  });

  it.skip("should create a vault", async function () {
    await expect(vaultFactory.createChild(
      "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512", 
      "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
    )).to.emit(vaultFactory, "VaultCreated").withArgs(anyValue);
  });
});