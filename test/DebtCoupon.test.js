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
    it("Should set the right default admin role...", async function() {
      //console.log(mockConfig.address);
      //console.log(await deployedToken.DEFAULT_ADMIN_ROLE());
      //console.log(await deployedToken.hasRole(mockConfig.address, mockConfig.address));
    });
  });

  describe("Transactions", function() {
    /*
        it("Should not allow non-owner address to mint tokens to a recipient", async function () {
            const mintCouponCall = deployedToken.mintCoupons(
                addr1.address,
                50,
                1000
            );

            await expect(mintCouponCall).to.be.revertedWith('Caller is not a coupon minter');
        });

        it("Should not allow non-owner address to burn tokens", async function () {
            const burnCouponCall = deployedToken.burnCoupons(
                addr1.address,
                50,
                1000
            );

            await expect(burnCouponCall).to.be.revertedWith('Caller is not a coupon burner');
        });

        it("Should allow the owner to mint tokens to a recipient", async function () {
            await mockConfig.mock.couponLengthSeconds.returns(utils.parseEther('50'));

            console.log(mockConfig.address);
            console.log(await deployedToken.DEFAULT_ADMIN_ROLE());
            console.log(await deployedToken.address);

            const expiryTimestamp = await deployedToken.mintCoupons(
                addr1.address,
                50,
                1000
            );

            console.log(expiryTimestamp);
            //console.log(await deployedToken.balanceOf(owner, '1'));
        });

        it("Should allow multiple mints with the same expiry", async function () {

        });

        it("Should allow burner to burn", async function () {

        });
        */
  });
});
