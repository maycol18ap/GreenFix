const { expect } = require("chai");
const hre = require("hardhat");
const { ethers } = hre;

describe("Funding Phase", function () {
  let factory;
  let usdc;
  let creator;
  let investor1;
  let investor2;
  
  const FUNDING_GOAL = ethers.parseUnits("1000", 6);
  const GUARANTEE = ethers.parseUnits("50", 6);

  beforeEach(async () => {
    const signers = await ethers.getSigners();
    creator = signers[0];
    investor1 = signers[1];
    investor2 = signers[2];

    const USDC = await ethers.getContractFactory("MockUSDC");
    usdc = await USDC.deploy();
    await usdc.mint(creator.address, ethers.parseUnits("100", 6));
    await usdc.mint(investor1.address, ethers.parseUnits("1000", 6));
    await usdc.mint(investor2.address, ethers.parseUnits("1000", 6));

    const Factory = await ethers.getContractFactory("GreenFixFactory");
    factory = await Factory.deploy(
      await usdc.getAddress(),
      1000,
      3 * 24 * 3600,
      1 * 24 * 3600,
      7 * 24 * 3600,
      creator.address
    );
  });

  async function createProject() {
    await usdc.connect(creator).approve(await factory.getAddress(), GUARANTEE);
    
    const tx = await factory.connect(creator).createProject(
      FUNDING_GOAL,
      600,
      30,
      7 * 24 * 3600,
      "ipfs://metadata"
    );
    
    const receipt = await tx.wait();
    const event = receipt.logs.find(
      (log) => log.fragment?.name === "ProjectCreated"
    );
    return await ethers.getContractAt("GreenFixProject", event?.args[2]);
  }

  async function expectRevert(promise) {
    try {
      await promise;
      expect.fail("Expected revert but transaction succeeded");
    } catch (error) {
      expect(error.message).to.satisfy(
        (msg) => msg.includes("revert") || msg.includes("reverted")
      );
    }
  }

  describe("depositGuarantee()", function () {
    it("should deposit guarantee successfully", async () => {
      const project = await createProject();
      
      await usdc.connect(creator).approve(await project.getAddress(), GUARANTEE);
      await project.connect(creator).depositGuarantee();
      
      expect(await project.guaranteeDeposited()).to.equal(true);
    });
  });

  describe("invest()", function () {
    it("should invest successfully", async () => {
      const project = await createProject();
      
      await usdc.connect(creator).approve(await project.getAddress(), GUARANTEE);
      await project.connect(creator).depositGuarantee();

      const amount = ethers.parseUnits("100", 6);
      await usdc.connect(investor1).approve(await project.getAddress(), amount);
      await project.connect(investor1).invest(amount);
      
      expect(await project.totalRaised()).to.equal(amount);
    });

    it("should revert if below minimum", async () => {
      const project = await createProject();
      
      await usdc.connect(creator).approve(await project.getAddress(), GUARANTEE);
      await project.connect(creator).depositGuarantee();

      const amount = ethers.parseUnits("5", 6);
      await usdc.connect(investor1).approve(await project.getAddress(), amount);
      
      await expectRevert(project.connect(investor1).invest(amount));
    });

    it("should revert if guarantee not deposited", async () => {
      const project = await createProject();

      const amount = ethers.parseUnits("100", 6);
      await usdc.connect(investor1).approve(await project.getAddress(), amount);
      
      await expectRevert(project.connect(investor1).invest(amount));
    });
  });

  describe("cancelFunding()", function () {
    it("should cancel and enter Refunding", async () => {
      const project = await createProject();
      
      await usdc.connect(creator).approve(await project.getAddress(), GUARANTEE);
      await project.connect(creator).depositGuarantee();

      const amount = ethers.parseUnits("100", 6);
      await usdc.connect(investor1).approve(await project.getAddress(), amount);
      await project.connect(investor1).invest(amount);

      await project.connect(creator).cancelFunding();
      
      expect(await project.state()).to.equal(3);
    });
  });

  describe("finalizeFunding()", function () {
    it("should finalize after reaching goal", async () => {
      const project = await createProject();
      
      await usdc.connect(creator).approve(await project.getAddress(), GUARANTEE);
      await project.connect(creator).depositGuarantee();

      await usdc.connect(investor1).approve(await project.getAddress(), FUNDING_GOAL);
      await project.connect(investor1).invest(FUNDING_GOAL);

      await project.finalizeFunding();
      
      expect(await project.state()).to.equal(1);
      expect(await project.getMilestoneCount()).to.equal(4);
    });

    it("should revert if goal not reached", async () => {
      const project = await createProject();
      
      await usdc.connect(creator).approve(await project.getAddress(), GUARANTEE);
      await project.connect(creator).depositGuarantee();

      const half = ethers.parseUnits("500", 6);
      await usdc.connect(investor1).approve(await project.getAddress(), half);
      await project.connect(investor1).invest(half);

      await expectRevert(project.finalizeFunding());
    });
  });
});