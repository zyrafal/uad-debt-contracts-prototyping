// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title A central config for the dollar system. Also acts as a central access control manager.
/// @notice For storing constants. For storing variables and allowing them to be changed by the admin (governance)
/// @dev This should be used as a central access control manager which other contracts use to check permissions
contract DollarConfig is AccessControl {

    bytes32 public constant COUPON_MANAGER_ROLE = keccak256("COUPON_MANAGER");

    address public twapOracleAddress;
    address public debtCouponAddress;
    address public dollarTokenAddress;
    address public comparisonTokenAddress; //USDC
    address public couponCalculatorAddress;
    address public dollarCalculatorAddress;

    //key = address of couponmanager, value = excessdollardistributor
    mapping(address => address) excessDollarDistributors;

    constructor(address _admin) public {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function setTwapOracleAddress(address _twapOracleAddress)
    external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        twapOracleAddress = _twapOracleAddress;
    }

    function setDebtCouponAddress(address _debtCouponAddress)
    external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        debtCouponAddress = _debtCouponAddress;
    }

    function setDollarTokenAddress(address _dollarTokenAddress)
    external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        dollarTokenAddress = _dollarTokenAddress;
    }

    function setComparisonTokenAddress(address _comparisonTokenAddress)
    external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        comparisonTokenAddress = _comparisonTokenAddress;
    }

    function setCouponCalculatorAddress(address _couponCalculatorAddress)
    external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        couponCalculatorAddress = _couponCalculatorAddress;
    }

    function setDollarCalculatorAddress(address _dollarCalculatorAddress)
    external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        dollarCalculatorAddress = _dollarCalculatorAddress;
    }

    function getExcessDollarsDistributor(address debtCouponManagerAddress)
    external view returns(address) {
        return excessDollarDistributors[debtCouponManagerAddress];
    }

    function setExcessDollarsDistributor(address debtCouponManagerAddress, address excessCouponDistributor)
    external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        excessDollarDistributors[debtCouponManagerAddress] = excessCouponDistributor;
    }
}
