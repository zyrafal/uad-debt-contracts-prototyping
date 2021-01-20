// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./../interfaces/ICouponsForDollarsCalculator.sol";
import "./../DollarConfig.sol";
import "./../external/UniswapOracle.sol";

/// @title A mock coupon calculator that always returns a constant
contract MockUniswapOracleAbove is UniswapOracle {
    using SafeMath for uint256;

    function update(address tokenA, address tokenB) external override {
        //do nothing
    }

    function consult(address tokenIn, uint256 amountIn, address tokenOut) external override view returns (uint amountOut) {
        return 2000001;
    }
}
