To deploy first compile:

```
npx hardhat compile
```

Once compiled, run the deploy script. Make sure the config values in the script are set correctly to the calculators you expect and not the mocks.

```
node scripts/deployAll.js
```

The result of that will be something like this:

```
{
  configAddress: "0x4458AcB1185aD869F982D51b5b0b87e23767A3A9",
  couponAddress: "0x8d375dE3D5DDde8d8caAaD6a4c31bD291756180b",
  couponManagerAddress: "0x721a1ecB9105f2335a8EA7505D343a5a09803A06",
  oracleAbove: "0x9852795dbb01913439f534b4984fBf74aC8AfA12",
  oracleBelow: "0x889D9A5AF83525a2275e41464FAECcCb3337fF60",
  oracleSettable: "0xf274De14171Ab928A5Ec19928cE35FaD91a42B64",
  stabilitasToken: "0xcb0A9835CDf63c84FE80Fcc59d91d7505871c98B",
  couponCalculator: "0xFD296cCDB97C605bfdE514e9810eA05f421DEBc2",
  dollarCalculator: "0x8b9d5A75328b5F3167b04B42AD00092E7d6c485c",
  dollarDistributor: "0x9BcA065E19b6d630032b53A8757fB093CbEAfC1d"
}
```

These are the addresses for the contracts that have been deployed. Next, update the scripts/contractAddresses file to these values like so:

```
const contractAddresses = {
  configAddress: "0x4458AcB1185aD869F982D51b5b0b87e23767A3A9",
  couponAddress: "0x8d375dE3D5DDde8d8caAaD6a4c31bD291756180b",
  couponManagerAddress: "0x721a1ecB9105f2335a8EA7505D343a5a09803A06",
  oracleAbove: "0x9852795dbb01913439f534b4984fBf74aC8AfA12",
  oracleBelow: "0x889D9A5AF83525a2275e41464FAECcCb3337fF60",
  oracleSettable: "0xf274De14171Ab928A5Ec19928cE35FaD91a42B64",
  stabilitasToken: "0xcb0A9835CDf63c84FE80Fcc59d91d7505871c98B",
  couponCalculator: "0xFD296cCDB97C605bfdE514e9810eA05f421DEBc2",
  dollarCalculator: "0x8b9d5A75328b5F3167b04B42AD00092E7d6c485c",
  dollarDistributor: "0x9BcA065E19b6d630032b53A8757fB093CbEAfC1d"
};

module.exports = contractAddresses;
```

These are used by the scenarios script. The scenarios script runs through a mock scenario where the price is above the peg and a user can redeem coupons and then below a peg where they can exchange their coupons back for dollars.

This uses mock oracles to fake the current peg - see oracleAbove and oracleBelow which are set in the config by the script.