const { ethers, ContractFactory } = require("ethers"); //to be explicit
const configArtifact = require("../artifacts/contracts/StabilitasConfig.sol/StabilitasConfig.json");
const debtCouponArtifact = require("../artifacts/contracts/DebtCoupon.sol/DebtCoupon.json");
const debtCouponManager = require("../artifacts/contracts/DebtCouponManager.sol/DebtCouponManager.json");
const oracleAbove = require("../artifacts/contracts/mocks/MockUniswapOracleAbove.sol/MockUniswapOracleAbove.json");
const oracleBelow = require("../artifacts/contracts/mocks/MockUniswapOracleBelow.sol/MockUniswapOracleBelow.json");
const oracleSettable = require("../artifacts/contracts/mocks/MockUniswapOracleSettable.sol/MockUniswapOracleSettable.json");
const stabilitasToken = require("../artifacts/contracts/mocks/MockStabilitasToken.sol/MockStabilitasToken.json");
const couponCalculator = require("../artifacts/contracts/CouponsForDollarsCalculator.sol/CouponsForDollarsCalculator.json");
const mockCouponCalculator = require("../artifacts/contracts/mocks/MockCouponsForDollarsCalculator.sol/MockCouponsForDollarsCalculator.json");
const mockDollarCalculator = require("../artifacts/contracts/mocks/MockDollarMintingCalculator.sol/MockDollarMintingCalculator.json");
const mockExcessDollarDistributor = require("../artifacts/contracts/mocks/MockExcessDollarsDistributor.sol/MockExcessDollarsDistributor.json");

let configDeployed,
  debtCouponDeployed,
  debtCouponManagerDeployed,
  oracleAboveDeployed,
  oracleBelowDeployed,
  stabilitasTokenDeployed,
  couponCalculatorDeployed,
  mockCouponCalculatorDeployed,
  mockDollarCalculatorDeployed,
  mockExcessDollarDistributorDeployed,
  oracleSettableDeployed;

let owner = new ethers.Wallet(
  "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
).connect(new ethers.providers.JsonRpcProvider("http://localhost:8545"));

async function deployConfig(adminAddress) {
  const StabilitasConfig = new ContractFactory(
    configArtifact.abi,
    configArtifact.bytecode,
    owner
  );
  configDeployed = await StabilitasConfig.deploy(adminAddress);
  await configDeployed.deployed();
  return configDeployed.address;
}

async function deployCoupon(configAddress) {
  const DebtCoupon = new ContractFactory(
    debtCouponArtifact.abi,
    debtCouponArtifact.bytecode,
    owner
  );
  debtCouponDeployed = await DebtCoupon.deploy(configAddress);
  await debtCouponDeployed.deployed();
  return debtCouponDeployed.address;
}

async function deployCouponManager(configAddress, couponLengthSeconds) {
  const DebtCouponManager = new ContractFactory(
    debtCouponManager.abi,
    debtCouponManager.bytecode,
    owner
  );
  debtCouponManagerDeployed = await DebtCouponManager.deploy(
    configAddress,
    couponLengthSeconds
  );
  await debtCouponManagerDeployed.deployed();
  return debtCouponManagerDeployed.address;
}

async function deployOracleAbove() {
  const MockUniswapOracleAbove = new ContractFactory(
    oracleAbove.abi,
    oracleAbove.bytecode,
    owner
  );
  oracleAboveDeployed = await MockUniswapOracleAbove.deploy();
  await oracleAboveDeployed.deployed();
  return oracleAboveDeployed.address;
}

async function deployOracleBelow() {
  const MockUniswapOracleBelow = new ContractFactory(
    oracleBelow.abi,
    oracleBelow.bytecode,
    owner
  );
  oracleBelowDeployed = await MockUniswapOracleBelow.deploy();
  await oracleBelowDeployed.deployed();
  return oracleBelowDeployed.address;
}

async function deployOracleSettable() {
  const MockUniswapOracleSettable = new ContractFactory(
    oracleSettable.abi,
    oracleSettable.bytecode,
    owner
  );
  oracleSettableDeployed = await MockUniswapOracleSettable.deploy();
  await oracleSettableDeployed.deployed();
  return oracleSettableDeployed.address;
}

async function deployStabilitasToken(initialSupply) {
  const MockStabilitasToken = new ContractFactory(
    stabilitasToken.abi,
    stabilitasToken.bytecode,
    owner
  );
  stabilitasTokenDeployed = await MockStabilitasToken.deploy(initialSupply);
  await stabilitasTokenDeployed.deployed();
  return stabilitasTokenDeployed.address;
}

async function deployCouponCalculator(configAddress) {
  const CouponsForDollarsCalculator = new ContractFactory(
    couponCalculator.abi,
    couponCalculator.bytecode,
    owner
  );
  couponCalculatorDeployed = await CouponsForDollarsCalculator.deploy(
    configAddress
  );
  await couponCalculatorDeployed.deployed();
  return couponCalculatorDeployed.address;
}

async function deployMockCouponsForDollarsCalculator() {
  const MockCouponsForDollarsCalculator = new ContractFactory(
    mockCouponCalculator.abi,
    mockCouponCalculator.bytecode,
    owner
  );
  mockCouponCalculatorDeployed = await MockCouponsForDollarsCalculator.deploy();
  await mockCouponCalculatorDeployed.deployed();
  return mockCouponCalculatorDeployed.address;
}

async function deployMockDollarMintingCalculator() {
  const MockDollarMintingCalculator = new ContractFactory(
    mockDollarCalculator.abi,
    mockDollarCalculator.bytecode,
    owner
  );
  mockDollarCalculatorDeployed = await MockDollarMintingCalculator.deploy();
  await mockDollarCalculatorDeployed.deployed();
  return mockDollarCalculatorDeployed.address;
}

async function deployMockExcessDollarDistributor() {
  const MockExcessDollarDistributor = new ContractFactory(
    mockExcessDollarDistributor.abi,
    mockExcessDollarDistributor.bytecode,
    owner
  );
  mockExcessDollarDistributorDeployed = await MockExcessDollarDistributor.deploy();
  await mockExcessDollarDistributorDeployed.deployed();
  return mockExcessDollarDistributorDeployed.address;
}

async function doDeployment() {
  const couponLengthSeconds = "2592000"; //30 days in seconds

  //zero address as this doesnt matter
  const configAddress = await deployConfig(owner.getAddress());
  const couponAddress = await deployCoupon(configAddress);
  const couponManagerAddress = await deployCouponManager(
    configAddress,
    couponLengthSeconds
  );
  const oracleAbove = await deployOracleAbove();
  const oracleBelow = await deployOracleBelow();
  const oracleSettable = await deployOracleSettable();
  const stabilitasToken = await deployStabilitasToken("1000");
  //const couponCalculator = await deployCouponCalculator(configAddress);
  //const dollarCalculator = await deployMockDollarMintingCalculator(configAddress);

  //mocks
  const couponCalculator = await deployMockCouponsForDollarsCalculator(
    configAddress
  );
  const dollarCalculator = await deployMockDollarMintingCalculator(
    configAddress
  );
  const dollarDistributor = await deployMockExcessDollarDistributor();

  await configDeployed.grantRole(await configDeployed.COUPON_MANAGER_ROLE(), couponManagerAddress);

  //set the coupon redemption address to the coupon manager
  await debtCouponDeployed.setRedemptionContractAddress(couponManagerAddress);

  let comparisonToken; //TODO: Should be mock USDC...

  await configDeployed.setTwapOracleAddress(oracleAbove);
  await configDeployed.setDebtCouponAddress(couponAddress);
  await configDeployed.setStabilitasTokenAddress(stabilitasToken);

  //set to coupon, this is never used since we're using mocks
  await configDeployed.setComparisonTokenAddress(couponAddress);
  await configDeployed.setCouponCalculatorAddress(couponCalculator);
  await configDeployed.setDollarCalculatorAddress(dollarCalculator);
  await configDeployed.setExcessDollarsDistributor(
    couponManagerAddress,
    dollarDistributor
  );

  return {
    configAddress,
    couponAddress,
    couponManagerAddress,
    oracleAbove,
    oracleBelow,
    oracleSettable,
    stabilitasToken,
    couponCalculator,
    dollarCalculator,
    dollarDistributor
  };
}

async function getAllContractSettings() {
  const twapOracleAddress = await configDeployed.twapOracleAddress();
  const debtCouponAddress = await configDeployed.debtCouponAddress();
  const stabilitasTokenAddress = await configDeployed.stabilitasTokenAddress();
  const comparisonTokenAddress = await configDeployed.comparisonTokenAddress();
  const couponCalculatorAddress = await configDeployed.couponCalculatorAddress();
  const dollarCalculatorAddress = await configDeployed.dollarCalculatorAddress();

  return {
    twapOracleAddress,
    debtCouponAddress,
    stabilitasTokenAddress,
    comparisonTokenAddress,
    couponCalculatorAddress,
    dollarCalculatorAddress
  };
}

doDeployment()
  .then(async result => {
    console.log(result);
    console.log(await getAllContractSettings());
    process.exit(0);
  })
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
