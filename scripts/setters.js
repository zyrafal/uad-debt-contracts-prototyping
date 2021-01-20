const { ethers } = require("hardhat"); //to be explicit
const configABI = require("../artifacts/contracts/StabilitasConfig.sol/StabilitasConfig.json")
  .abi;
const oracleABI = require("../artifacts/contracts/mocks/MockUniswapOracleAbove.sol/MockUniswapOracleAbove.json")
  .abi;

async function setOracle(configAddress, oracleAddress, account) {
  try {
    const configContract = new ethers.Contract(
      configAddress,
      configABI,
      account
    );
    await configContract.setTwapOracleAddress(oracleAddress);

    const oracleContract = new ethers.Contract(
      oracleAddress,
      oracleABI,
      account
    );

    //params dont matter as mock
    console.log(
      "New oracle price is " +
        (await oracleContract.consult(oracleAddress, 1, oracleAddress))
    );
  } catch (err) {
    console.log(err);
  }
}

async function setCouponCalculator(
  configAddress,
  couponCalculatorAddress,
  account
) {
  const configContract = new ethers.Contract(configAddress, configABI, account);
  await configContract.setCouponCalculatorAddress(couponCalculatorAddress);
}

module.exports = {
  setOracle,
  setCouponCalculator
};
