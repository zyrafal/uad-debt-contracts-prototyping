// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ICouponsForDollarsCalculator.sol";
import "./StabilitasConfig.sol";
import "./DebtCoupon.sol";
import "hardhat/console.sol";

/// @title Uses the following formula: ((1/(1-R)^2) - 1)
contract CouponsForDollarsCalculator is ICouponsForDollarsCalculator {
    using SafeMath for uint256;

    StabilitasConfig public config;

    /// @param _config the address of the config contract so we can fetch variables
    constructor(
        address _config
    ) public {
        config = StabilitasConfig(_config);
    }

    function getCouponAmount(uint256 dollarsToBurn) external view override returns(uint256) {
        uint256 ONE = 1;
        uint256 totalDebt = DebtCoupon(config.debtCouponAddress()).getTotalOutstandingDebt();
        uint256 r = totalDebt.div(IERC20(config.stabilitasTokenAddress()).totalSupply());
        uint256 oneMinusRAllSquared = ((ONE).sub(r)).mul((ONE).sub(r));

        //rewards per dollar is ( (1/(1-R)^2) - 1)
        return ((dollarsToBurn).div(oneMinusRAllSquared)).sub(ONE);
    }
}
