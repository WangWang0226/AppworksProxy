
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");
  
  describe("Appworks", function () {
    async function myFixture() {
  
      const price = ethers.utils.parseUnits("0.01", "ether");
      const maxSupply = 100;
      const [owner] = await ethers.getSigners();
      const AppWorks = await ethers.getContractFactory("AppWorksProxyV1");
      const appworks = await AppWorks.deploy();
  
      return { price, appworks, owner, maxSupply };
    }
  
    describe("intialize", function () {
      it("Should set the right price after intialize", async function () {
        const { appworks } = await loadFixture(myFixture);
  
        expect(await appworks.price()).to.equal(ethers.utils.parseUnits("0.01", "ether"));
      });
    });
  
    describe("totalSupply", function () {
      it("should return 0", async function () {
        const { appworks } = await loadFixture(myFixture);
  
        expect(await appworks.totalSupply()).to.equal(0);
      });
    });
  
    describe("mint", function () {
  
      it("should revert if mintActive is not true", async function () {
        const { appworks } = await loadFixture(myFixture);
  
        expect(await appworks.mintActive()).to.equal(false);
        expect(await appworks.totalSupply()).to.equal(0);
        expect(await appworks.maxSupply()).to.equal(100);
        await expect(appworks.mint(1, { value: ethers.utils.parseEther("0.01")}))
          .to.be.revertedWith('mint is not available');
      });
    });
  });