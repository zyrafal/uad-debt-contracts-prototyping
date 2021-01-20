// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";
import "./interfaces/IExcessDollarsDistributor.sol";
import "./DollarConfig.sol";
import "./mocks/MockDollarToken.sol";

/// @title An excess dollar distributor which sends dollars to treasury, lp rewards and inflation rewards
contract ExcessDollarsDistributor is IExcessDollarsDistributor {
    using SafeMath for uint256;
    DollarConfig public config;

    /// @param _config the address of the config contract so we can fetch variables
    constructor(
        address _config
    ) public {
        config = DollarConfig(_config);
    }

    function distributeDollars() external override {
        //the excess dollars which were sent to this contract by the coupon manager
        uint256 excessDollars = MockDollarToken(config.dollarTokenAddress()).balanceOf(address(this));

        //todo: put the real addresses in here when these bits are built. they should live in config...
        address treasuryAddress = address(0);
        address inflationRewardsAddress = address(0);
        address lpRewardsAddress = address(0);

        MockDollarToken(config.dollarTokenAddress()).transfer(
            treasuryAddress,
            excessDollars.div(10)
        );

        MockDollarToken(config.dollarTokenAddress()).transfer(
            inflationRewardsAddress,
            excessDollars.mul(55).div(100)
        );

        MockDollarToken(config.dollarTokenAddress()).transfer(
            lpRewardsAddress,
            excessDollars.mul(35).div(100)
        );
    }
}
