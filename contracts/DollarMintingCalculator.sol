// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./DollarConfig.sol";
import "./interfaces/IDollarMintingCalculator.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./external/UniswapOracle.sol";

/// @title A mock coupon calculator that always returns a constant
contract DollarMintingCalculator is IDollarMintingCalculator {
    using SafeMath for uint256;

    DollarConfig public config;

    /// @param _config the address of the config contract so we can fetch variables
    constructor(
        address _config
    ) public {
        config = DollarConfig(_config);
    }

    function getDollarsToMint() external view override returns(uint256) {
        UniswapOracle oracle = UniswapOracle(config.twapOracleAddress());
        uint256 twapPrice = oracle.consult(
            config.comparisonTokenAddress(),
            1000000,
            config.dollarTokenAddress()
        );
        return twapPrice.sub(1000000).mul(IERC20(config.dollarTokenAddress()).totalSupply());
    }
}
