// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ICouponsForDollarsCalculator.sol";
import "./DollarConfig.sol";
import "./DebtCoupon.sol";
import "hardhat/console.sol";

/// @title Uses the following formula: (1 / (1 + R)^2) - 1
contract CouponsForDollarsCalculator is ICouponsForDollarsCalculator {
    using SafeMath for uint256;

    DollarConfig public config;

    /// @param _config the address of the config contract so we can fetch variables
    constructor(
        address _config
    ) {
        config = DollarConfig(_config);
    }

    function getCouponAmount(uint256 dollarsToBurn) external view override returns(uint256) {
        uint256 totalDebt = DebtCoupon(config.debtCouponAddress()).getTotalOutstandingDebt();
        uint256 r = totalDebt.div(IERC20(config.dollarTokenAddress()).totalSupply());
        uint256 onePlusRAllSquared = (r.add(1)).mul(r.add(1));

        //rewards per dollar is (1 / (1 + R)^2) - 1
        return ((dollarsToBurn).div(onePlusRAllSquared)).sub(1);
    }
}
