const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  
  describe("DaoLiquidity", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deploy() {
      // Contracts are deployed using the first signer/account by default
      const [owner, otherAccount] = await ethers.getSigners();
  
      const DaoLiquidity = await ethers.getContractFactory("DaoLiquidity");
      const daoLiquidity = await DaoLiquidity.deploy();
  
      return { owner, otherAccount, daoLiquidity};
    }
  
    describe("Deployment", function () {
      it("test deploy", async function () {
        const { owner, otherAccount, daoLiquidity } = await loadFixture(deploy);//getFactory
  
        expect(await daoLiquidity.getFactory()).to.equal(owner.address);
      });
  
    
    });
  });
  