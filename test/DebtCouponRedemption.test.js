//TODO: If more than is currently redeemable is sent, then send the remainder back...
//TODO: If multiple coupons are sent redeem greedily by earliest expiry and send remainder back
const { ethers } = require("hardhat"); //to be explicit
const { use, expect } = require("chai");

const {MockProvider} = require('@ethereum-waffle/provider');
const {waffleChai} = require('@ethereum-waffle/chai');
const {deployMockContract} = require('@ethereum-waffle/mock-contract');

const IERC20 = require('../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json');
const CONFIG = require('../artifacts/contracts/StabilitasConfig.sol/StabilitasConfig.json');

use(waffleChai);

describe("DebtCoupon Redemption Contract", function () {
    let DebtCoupon;
    let DebtCouponRedemption;
    let deployedDebtCoupon;
    let deployedRedemptionContract;
    let owner;
    let addr1;
    let addr2;
    let addrs;

    async function setupMocks() {
        const [sender, receiver] = new MockProvider().getWallets();
        const mockERC20 = await deployMockContract(sender, IERC20.abi);
        const mockCONFIG = await deployMockContract(sender, CONFIG.abi);
        return {sender, receiver, mockERC20, mockCONFIG};
    }

    beforeEach(async function () {
        const {sender, receiver, mockERC20, mockCONFIG} = await setupMocks();
        //await mockERC20.mock.balanceOf.returns(''utils.parseEther('999999')'');
        await mockCONFIG.mock.couponLengthSeconds.returns(50);

        DebtCoupon = await ethers.getContractFactory("DebtCoupon");
        DebtCouponRedemption = await ethers.getContractFactory("DebtCouponRedemption");

        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        deployedDebtCoupon = await DebtCoupon.deploy(mockCONFIG.address);
        deployedRedemptionContract = await DebtCouponRedemption.deploy(mockCONFIG.address);

        await Promise.all([
            deployedDebtCoupon.deployed(),
            deployedRedemptionContract.deployed()
        ]);
    });

    describe("Deployment", function () {
        it("Print relevant addresses", async function () {
            console.log(deployedDebtCoupon.address);
            console.log(deployedRedemptionContract.address);

            console.log("Balance of DebtCoupon " + await deployedDebtCoupon.balanceOf(owner.address, 123));

            const approval = await deployedDebtCoupon.setApprovalForAll(
                deployedRedemptionContract.address,
                true
            );

            console.log("Approval result " + approval);

            deployedRedemptionContract.send(
                deployedDebtCoupon.address,
                owner.address,
                deployedRedemptionContract.address,
                123,
                10,
            ).then(
                res => console.log("Transfer completed", res)
            ).catch(
                res => console.error("Transfer failed", res)
            );

            console.log("Balance of DebtCoupon " + await deployedDebtCoupon.balanceOf(owner.address, 123));
            console.log("Balance of DebtCoupon contract " + await deployedDebtCoupon.balanceOf(deployedRedemptionContract.address, 123));
        });
    });
});
