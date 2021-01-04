// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./StabilitasConfig.sol";

/// @title A coupon redeemable for dollars with an expiry time
/// @notice An ERC1155 where the token ID is the expiry time
/// @dev Implements ERC1155 so receiving contracts must implement IERC1155Receiver
contract DebtCoupon is ERC1155 {
    using SafeMath for uint256;

    StabilitasConfig public config;

    //@dev URI param is if we want to add an off-chain meta data uri associated with this contract
    constructor(
        address _config
    ) public ERC1155("URI") {
        config = StabilitasConfig(_config);
    }

    /// @notice Mint an amount of coupons expiring at a certain time for a certain recipient
    /// @param amount amount of tokens to mint
    /// @param expiryTimestamp the timestamp of the coupons to mint
    function mintCoupons(
        address recipient,
        uint256 amount,
        uint256 expiryTimestamp
    ) external {
        //require(hasRole(config.COUPON_MANAGER_ROLE(), msg.sender), "Caller is not a coupon manager");
        _mint(recipient, expiryTimestamp, amount, "");
    }

    /// @notice Burn an amount of coupons expiring at a certain time from a certain holder's balance
    /// @param couponOwner the owner of those coupons
    /// @param amount amount of tokens to burn
    /// @param expiryTimestamp the timestamp of the coupons to burn
    function burnCoupons(
        address couponOwner,
        uint256 amount,
        uint256 expiryTimestamp
    ) external {
        //require(hasRole(config.COUPON_MANAGER_ROLE(), msg.sender), "Caller is not a coupon manager");
        require(balanceOf(couponOwner, expiryTimestamp) >= amount, "Coupon owner doesn't have enough coupons");
        _burn(couponOwner, expiryTimestamp, amount);
    }

    //just for testing. will be removed...
    function checkAdminRole() external returns (bool) {
        return config.hasRole(config.DEFAULT_ADMIN_ROLE(), msg.sender);
    }
}
