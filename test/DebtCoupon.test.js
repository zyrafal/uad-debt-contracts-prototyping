const { ethers } = require("hardhat"); //to be explicit
const { use, expect } = require("chai");
const { utils } = require("ethers");

const { MockProvider } = require("@ethereum-waffle/provider");
const { waffleChai } = require("@ethereum-waffle/chai");
const { deployMockContract } = require("@ethereum-waffle/mock-contract");

const CONFIG = require("../artifacts/contracts/StabilitasConfig.sol/StabilitasConfig.json");

use(waffleChai);

describe("Debt coupon contract", function() {
  let DebtCoupon;
  let deployedToken;
  let mockConfig;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  async function setupMocks() {
    const [sender, receiver] = new MockProvider().getWallets();
    mockConfig = await deployMockContract(sender, CONFIG.abi);
  }

  beforeEach(async function() {
    DebtCoupon = await ethers.getContractFactory("DebtCoupon");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    await setupMocks();

    deployedToken = await DebtCoupon.deploy(mockConfig.address);
    await deployedToken.deployed();
  });

  describe("Deployment", function() {
    it("Should deploy correctly", async function() {
    });
  });

  describe("Transactions", function() {
    it("Should allow a mint, and update total debt correctly", async function () {
      const expiryTime = Math.round((Date.now() / 1000) + 86400);

      const amountToMint = 50;

      //user should have 0 coupons to begin with. total debt should be 0
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(0);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(0);

      const mintCouponCall = deployedToken.mintCoupons(
          addr1.address,
          amountToMint,
          expiryTime
      );

      await mintCouponCall;

      //user should have amountToMint coupons to end. total debt should be amountToMint
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(amountToMint);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(amountToMint);
    });

    it("Should allow multiple mints, and update total debt correctly", async function () {
      const expiryTime = Math.round((Date.now() / 1000) + 86400);

      const amountToMint = 50;

      //user should have 0 coupons to begin with. total debt should be 0
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(0);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(0);

      const mintCouponCall = deployedToken.mintCoupons(
          addr1.address,
          amountToMint,
          expiryTime
      );

      await mintCouponCall;

      //user should have amountToMint coupons to end. total debt should be amountToMint
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(amountToMint);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(amountToMint);

      const mintCouponCall2 = deployedToken.mintCoupons(
          addr1.address,
          amountToMint,
          expiryTime
      );

      await mintCouponCall2;

      //user should have amountToMint * 2 coupons to end. total debt should be amountToMint * 2
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(amountToMint * 2);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(amountToMint * 2);
    });


    it("Should allow multiple mints across different expiries and update total debt correctly", async function () {
      const expiryTime = Math.round((Date.now() / 1000) + 86400);

      const amountToMint = 50;
      const amountToMint2 = 51;

      //user should have 0 coupons to begin with. total debt should be 0
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(0);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(0);

      const mintCouponCall = deployedToken.mintCoupons(
          addr1.address,
          amountToMint,
          expiryTime
      );

      await mintCouponCall;

      //user should have amountToMint coupons to end. total debt should be amountToMint
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(amountToMint);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(amountToMint);

      const mintCouponCall2 = deployedToken.mintCoupons(
          addr1.address,
          amountToMint2,
          expiryTime + 1
      );

      await mintCouponCall2;

      //user should have amountToMint + amountToMint2 coupons to end. total debt should be amountToMint + amountToMint2
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(amountToMint);
      expect(await deployedToken.balanceOf(addr1.address, expiryTime + 1)).to.equal(amountToMint2);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(amountToMint + amountToMint2);
    });

    it("Should allow a mint, and update total debt correctly", async function () {
      const expiryTime = Math.round((Date.now() / 1000) + 86400);

      const amountToMint = 50;
      const amountToBurn = 20;

      //user should have 0 coupons to begin with. total debt should be 0
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(0);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(0);

      const mintCouponCall = deployedToken.mintCoupons(
          addr1.address,
          amountToMint,
          expiryTime
      );

      await mintCouponCall;

      //user should have amountToMint coupons to end. total debt should be amountToMint
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(amountToMint);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(amountToMint);

      const burnCouponCall = deployedToken.burnCoupons(
          addr1.address,
          amountToBurn,
          expiryTime
      );

      await burnCouponCall;

      //user should have amountToMint - amountToBurn coupons to end. total debt should be amountToMint
      expect(await deployedToken.balanceOf(addr1.address, expiryTime)).to.equal(amountToMint - amountToBurn);
      expect(await deployedToken.getTotalOutstandingDebt()).to.equal(amountToMint - amountToBurn);
    });

    //todo
    it("Should restrict access to elevated methods", async function () {
      //mintCoupons();
      //burnCoupons();
      //setRedemptionContractAddress();
      //await expect(burnCouponCall).to.be.revertedWith('Caller is not a coupon burner');
    });
  });
});
