// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IDebtRedemption.sol";
import "./external/UniswapOracle.sol";
import "./StabilitasConfig.sol";
import "./DebtCoupon.sol";
import "hardhat/console.sol";

/// @title A basic debt issuing and redemption mechanism for coupon holders
/// @notice Allows users to burn their stabilitas in exchange for coupons redeemable in the future
/// @notice Allows users to redeem individual debt coupons or batch redeem coupons on a first-come first-serve basis
contract DebtCouponManager is ERC165, IERC1155Receiver {
    using SafeMath for uint256;

    StabilitasConfig public config;

    /// @param _config the address of the config contract so we can fetch variables
    constructor(
        address _config
    ) public {
        config = StabilitasConfig(_config);
    }

    function getTwapPrice() internal returns(uint256) {
        UniswapOracle oracle = UniswapOracle(config.twapOracleAddress());
        return oracle.consult(
            config.stabilitasTokenAddress(),
            1, //1 wei will get us the pool mid-price..?
            config.comparisonToken()
        );
    }

    /// @param id the timestamp of the coupon
    /// @param amount the amount of coupons to redeem
    /// @return amount of unredeemed coupons
    function redeemCoupons(
        uint256 id,
        uint256 amount
    ) public returns (uint256) {
        uint256 currentPrice = getTwapPrice();

        //TODO: price * decimals...
        require(currentPrice > 1, "Price must be above 1 to redeem coupons");

        DebtCoupon debtCoupon = DebtCoupon(config.debtCouponAddress());
        require(id > block.timestamp, "Coupon has expired");
        require(debtCoupon.balanceOf(msg.sender, id) >= amount, "User doesnt have enough coupons");

        uint256 maxRedeemableCoupons = 5; //TODO: How do we calculate this?
        uint256 couponsToRedeem = amount;

        if(amount > maxRedeemableCoupons) {
            couponsToRedeem = maxRedeemableCoupons;
        }

        IERC20 stabilitas = IERC20(config.stabilitasTokenAddress());
        require(stabilitas.balanceOf(address(this)) > 0, "There aren't any stabilitas to redeem currently");

        debtCoupon.safeTransferFrom(
            msg.sender,
            address(this),
            id,
            amount,
            ''
        );

        console.log("After transfer...", 1);

        debtCoupon.burnCoupons(address(this), amount, id);

        //TODO: Give the man his dollars

        return amount - couponsToRedeem;
    }

    /// @param amount the amount of dollars to exchange for coupons
    function exchangeDollarsForCoupons(uint256 amount) external {
        uint256 currentPrice = getTwapPrice();

        //TODO: price * decimals...
        require(currentPrice < 1, "Price must be above 1 to redeem coupons");

        //TODO: how do we know max amount of coupons that are mintable?

        //burn the stabilitas and provide user with coupons
        DebtCoupon debtCoupon = DebtCoupon(config.debtCouponAddress());
        uint256 expiryTimestamp = block.timestamp.add(config.couponLengthSeconds());
        debtCoupon.mintCoupons(msg.sender, amount, expiryTimestamp);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
    external
    override
    returns(bytes4) {
        console.log("In burn method...", 1);

        if(config.hasRole(config.COUPON_MANAGER_ROLE(), operator)) {
            //allow the transfer since it originated from this contract
            return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
        } else {
            //reject the transfer
            return '';
        }
    }

    /// @dev this method is never called by the contract so if called was called by someone else -> revert.
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
    external
    override
    returns(bytes4) {
        //reject the transfer
        return '';
    }
}
