// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IDollarMintingCalculator.sol";

/// @title A mock dollar minting calculator that always returns a constant
contract MockDollarMintingCalculator is IDollarMintingCalculator {
    function getDollarsToMint() external view override returns(uint256) {
        return 5;
    }
}
