// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";

//TODO: All setters in this class needs hasRole restrictions
/// @title A central config for the stabilitas system. Also acts as a central access control manager.
/// @notice For storing constants. For storing variables and allowing them to be changed by the admin (governance)
/// @dev This should be used as a central access control manager which other contracts use to check permissions
contract StabilitasConfig is AccessControl {

    bytes32 public constant COUPON_MANAGER_ROLE = keccak256("COUPON_MANAGER");

    address public twapOracleAddress;
    address public debtCouponAddress;
    address public stabilitasTokenAddress;
    address public comparisonTokenAddress; //USDC
    address public couponCalculatorAddress;
    address public dollarCalculatorAddress;
    uint256 public couponLengthSeconds;

    //key = address of couponmanager, value = excessdollardistributor
    mapping(address => address) excessDollarDistributors;

    constructor(address _admin) public {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function setTwapOracleAddress(address _twapOracleAddress)
    external {
        twapOracleAddress = _twapOracleAddress;
    }

    function setCouponLengthSeconds(uint256 _couponLengthSeconds)
    external {
        couponLengthSeconds = _couponLengthSeconds;
    }

    function setDebtCouponAddress(address _debtCouponAddress)
    external {
        debtCouponAddress = _debtCouponAddress;
    }

    function setStabilitasTokenAddress(address _stabilitasTokenAddress)
    external {
        stabilitasTokenAddress = _stabilitasTokenAddress;
    }

    function setComparisonTokenAddress(address _comparisonTokenAddress)
    external {
        comparisonTokenAddress = _comparisonTokenAddress;
    }

    function setCouponCalculatorAddress(address _couponCalculatorAddress)
    external {
        couponCalculatorAddress = _couponCalculatorAddress;
    }

    function setDollarCalculatorAddress(address _dollarCalculatorAddress)
    external {
        dollarCalculatorAddress = _dollarCalculatorAddress;
    }

    function getExcessDollarsDistributor(address debtCouponManagerAddress)
    external view returns(address) {
        return excessDollarDistributors[debtCouponManagerAddress];
    }

    function setExcessDollarsDistributor(address debtCouponManagerAddress, address excessCouponDistributor)
    external {
        excessDollarDistributors[debtCouponManagerAddress] = excessCouponDistributor;
    }
}
