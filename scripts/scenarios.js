const {ethers, BigNumber} = require("ethers"); //to be explicit
const configABI = require('../artifacts/contracts/StabilitasConfig.sol/StabilitasConfig.json').abi;
const couponABI = require('../artifacts/contracts/DebtCoupon.sol/DebtCoupon.json').abi;
const erc20ABI = require('../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json').abi;
const oracleABI = require('../artifacts/contracts/mocks/MockUniswapOracleAbove.sol/MockUniswapOracleAbove.json').abi;
const couponManagerABI = require('../artifacts/contracts/DebtCouponManager.sol/DebtCouponManager.json').abi;
const addresses = require('./contractAddresses');
const {setOracle, setCouponCalculator} = require('./setters');

let owner = new ethers.Wallet('ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80').connect(new ethers.providers.JsonRpcProvider('http://localhost:8545'));

async function listenToMintsAndBurns(mintEvents, burnEvents) {
    const tokenContract = new ethers.Contract(
        addresses.couponAddress,
        couponABI,
        owner,
    )

    tokenContract.on('MintedCoupons', (recipient, expiryTime, amount) => {
        console.log(`
            New Minted Coupons
            Recipient: ${recipient} ,
            Expiry Time: ${expiryTime},
            Amount: ${amount},
        `);

        mintEvents.push({
            recipient,
            expiryTime,
            amount
        });
    })

    tokenContract.on('BurnedCoupons', (holder, expiryTime, amount) => {
        console.log(`
            New Burned Coupons
            Coupon Holder: ${holder} ,
            Expiry Time: ${expiryTime},
            Amount: ${amount},
        `)

        burnEvents.push({
            holder,
            expiryTime,
            amount
        });
    })
}

async function getBalanceAndSupply(account, tokenAddress) {
    const accountAddress = await account.getAddress();
    const tokenContract = new ethers.Contract(tokenAddress, erc20ABI, account);
    const balance = await tokenContract.balanceOf(accountAddress);
    const totalSupply = await tokenContract.totalSupply();
    console.log(`Balance of user ${accountAddress} for token ${tokenAddress}: ${balance}`);
    console.log(`Total supply of token ${tokenAddress}: ${totalSupply}`);
}

async function burnDollarsForCoupons(account, amountToBurn) {
    try {
        const couponManagerContract = new ethers.Contract(addresses.couponManagerAddress, couponManagerABI, account);
        await couponManagerContract.exchangeDollarsForCoupons(BigNumber.from(amountToBurn), {gasLimit: 5000000});
    } catch (err) {
        console.log(err);
    }
}

async function approveCouponManageToSpend(account) {
    try {
        const couponManagerContract = new ethers.Contract(addresses.couponAddress, couponABI, account);
        await couponManagerContract.setApprovalForAll(addresses.couponManagerAddress, true, {gasLimit: 5000000});
    } catch (err) {
        console.log(err);
    }
}

async function redeemCouponsForDollars(account, couponExpiry, amountToRedeem) {
    try {
        const couponManagerContract = new ethers.Contract(addresses.couponManagerAddress, couponManagerABI, account);
        await couponManagerContract.redeemCoupons(BigNumber.from(couponExpiry), BigNumber.from(amountToRedeem), {gasLimit: 5000000});
    } catch (err) {
        console.log(err);
    }
}

async function getCouponsReturnedForDollars(account) {
    const couponManagerContract = new ethers.Contract(addresses.couponManagerAddress, couponManagerABI, account);
    const couponsReturned = await couponManagerContract.getCouponsReturnedForDollars(BigNumber.from('10'));
    console.log("coupons returned is " + JSON.stringify(couponsReturned.toString()));
}

async function runPriceBelowADollarScenario() {
    try {
        //set oracle to be below a price of 1
        await setOracle(addresses.configAddress, addresses.oracleBelow, owner);
        await setCouponCalculator(addresses.configAddress, addresses.couponCalculator, owner);

        //get the user's balance
        await getBalanceAndSupply(owner, addresses.stabilitasToken);

        //get the amount of coupon's that should be returned
        await getCouponsReturnedForDollars(owner);

        //burn some dollars for coupons
        await burnDollarsForCoupons(owner, '10');

        //get the user's balance
        await getBalanceAndSupply(owner, addresses.stabilitasToken);
    } catch (err) {
        console.log(err);
    }
}

async function getCouponBalance(expiryTimestamp, account) {
    console.log("Fetching coupon balance");

    const couponContract = new ethers.Contract(addresses.couponAddress, couponABI, account);
    const couponsReturned = await couponContract.balanceOf(account.getAddress(), BigNumber.from(expiryTimestamp));
    console.log("coupon balance is " + JSON.stringify(couponsReturned.toString()));
}

async function runPriceAboveADollarScenario(couponExpiry, amountToRedeem) {
    console.log("Price above a dollar");
    try {
        //set oracle to be above a price of 1
        await setOracle(addresses.configAddress, addresses.oracleAbove, owner);

        await approveCouponManageToSpend(owner);

        await getCouponBalance(couponExpiry, owner);

        await redeemCouponsForDollars(owner, couponExpiry, amountToRedeem);

        await getCouponBalance(couponExpiry, owner)
    } catch (err) {
        console.log(err);
    }
}

async function runWholeFlow() {
    try {
        let mintEvents = [];
        let burnEvents = [];

        await listenToMintsAndBurns(mintEvents, burnEvents);
        await runPriceBelowADollarScenario().then(
            async res => {
                while (mintEvents.length < 1) {
                    await new Promise(resolve => setTimeout(resolve, 500));
                }
                await runPriceAboveADollarScenario(mintEvents[0].expiryTime, mintEvents[0].amount);
            }
        );
    } catch (err) {
        console.error("An error occured " + JSON.stringify(err));
    }
}

runWholeFlow();