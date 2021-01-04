// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title A central config for the stabilitas system. Also acts as a central access control manager.
/// @notice For storing constants. For storing variables and allowing them to be changed by the admin (governance)
/// @dev This should be used as a central access control manager which other contracts use to check permissions
contract StabilitasConfig is AccessControl {

    bytes32 public constant COUPON_MANAGER_ROLE = keccak256("COUPON_MANAGER");

    address public twapOracleAddress;
    address public debtCouponAddress;
    address public stabilitasTokenAddress;
    address public comparisonToken; //USDC
    uint256 public couponLengthSeconds;

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

    function setComparisonToken(address _comparisonToken)
    external {
        comparisonToken = _comparisonToken;
    }
}
