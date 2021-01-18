// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./../interfaces/ICouponsForDollarsCalculator.sol";

/// @title A mock coupon calculator that always returns a constant
contract MockCouponsForDollarsCalculator is ICouponsForDollarsCalculator {
    function getCouponAmount(uint256 dollarsToBurn) external view override returns(uint256) {
        return 5;
    }
}
