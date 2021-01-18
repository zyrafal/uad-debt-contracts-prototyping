// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

interface UniswapOracle {
    function update(address tokenA, address tokenB) external;
    function consult(address tokenIn, uint256 amountIn, address tokenOut) external view returns (uint amountOut);
}
