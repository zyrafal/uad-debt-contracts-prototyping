// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IDebtRedemption.sol";
import "./interfaces/ICouponsForDollarsCalculator.sol";
import "./interfaces/IDollarMintingCalculator.sol";
import "./interfaces/IExcessDollarsDistributor.sol";
import "./external/UniswapOracle.sol";
import "./mocks/MockStabilitasToken.sol";
import "./StabilitasConfig.sol";
import "./DebtCoupon.sol";

/// @title A basic debt issuing and redemption mechanism for coupon holders
/// @notice Allows users to burn their stabilitas in exchange for coupons redeemable in the future
/// @notice Allows users to redeem individual debt coupons or batch redeem coupons on a first-come first-serve basis
contract DebtCouponManager is ERC165, IERC1155Receiver {
    using SafeMath for uint256;

    StabilitasConfig public config;

    //the amount of dollars we minted this cycle, so we can calculate delta. should be reset to 0 when cycle ends
    uint256 public dollarsMintedThisCycle;
    uint256 public couponLengthSeconds;

    /// @param _config the address of the config contract so we can fetch variables
    /// @param _couponLengthSeconds how long coupons last in seconds. can't be changed once set (unless migrated)
    constructor(
        address _config,
        uint256 _couponLengthSeconds
    ) public {
        config = StabilitasConfig(_config);
        couponLengthSeconds = _couponLengthSeconds;
    }

    function getTwapPrice() internal view returns(uint256) {
        UniswapOracle oracle = UniswapOracle(config.twapOracleAddress());
        return oracle.consult(
            config.comparisonTokenAddress(),
            1000000,
            config.stabilitasTokenAddress()
        );
    }

    /// @param id the timestamp of the coupon
    /// @param amount the amount of coupons to redeem
    /// @return amount of unredeemed coupons
    function redeemCoupons(
        uint256 id,
        uint256 amount
    ) public returns (uint256) {
        UniswapOracle oracle = UniswapOracle(config.twapOracleAddress());
        oracle.update(config.stabilitasTokenAddress(), config.comparisonTokenAddress());

        uint256 twapPrice = getTwapPrice();

        require(twapPrice > 1000000, "Price must be above 1 to redeem coupons");

        DebtCoupon debtCoupon = DebtCoupon(config.debtCouponAddress());

        require(id > block.timestamp, "Coupon has expired");
        require(debtCoupon.balanceOf(msg.sender, id) >= amount, "User doesnt have enough coupons");

        _mintClaimableDollars();

        uint256 maxRedeemableCoupons = MockStabilitasToken(config.stabilitasTokenAddress()).balanceOf(address(this));
        uint256 couponsToRedeem = amount;

        if(amount > maxRedeemableCoupons) {
            couponsToRedeem = maxRedeemableCoupons;
        }

        MockStabilitasToken stabilitas = MockStabilitasToken(config.stabilitasTokenAddress());
        require(stabilitas.balanceOf(address(this)) > 0, "There aren't any stabilitas to redeem currently");

        debtCoupon.safeTransferFrom(
            msg.sender,
            address(this),
            id,
            amount,
            ''
        );

        debtCoupon.burnCoupons(address(this), amount, id);

        stabilitas.transfer(msg.sender, amount);

        return amount.sub(couponsToRedeem);
    }

    function mintClaimableDollars() external {
        UniswapOracle oracle = UniswapOracle(config.twapOracleAddress());
        oracle.update(config.stabilitasTokenAddress(), config.comparisonTokenAddress());
        _mintClaimableDollars();
    }

    function _mintClaimableDollars() internal {
        DebtCoupon debtCoupon = DebtCoupon(config.debtCouponAddress());
        debtCoupon.updateTotalDebt();

        uint256 twapPrice = getTwapPrice();
        uint256 totalMintableDollars = IDollarMintingCalculator(config.dollarCalculatorAddress()).getDollarsToMint();
        uint256 dollarsToMint = totalMintableDollars.sub(dollarsMintedThisCycle);

        //update the dollars for this cycle
        dollarsMintedThisCycle = totalMintableDollars;

        //TODO: @Steve to call mint on stabilitas contract here. dollars should be minted to address(this)
        MockStabilitasToken(config.stabilitasTokenAddress()).mint(address(this), dollarsToMint);

        uint256 currentRedeemableBalance = MockStabilitasToken(config.stabilitasTokenAddress()).balanceOf(address(this));

        if(currentRedeemableBalance > debtCoupon.getTotalOutstandingDebt()) {
            uint256 excessDollars = currentRedeemableBalance.sub(debtCoupon.getTotalOutstandingDebt());

            IExcessDollarsDistributor dollarsDistributor = IExcessDollarsDistributor(
                config.getExcessDollarsDistributor(address(this))
            );

            //transfer excess dollars to the distributor and tell it to distribute
            MockStabilitasToken(config.stabilitasTokenAddress()).transfer(
                config.getExcessDollarsDistributor(address(this)),
                excessDollars
            );
            dollarsDistributor.distributeDollars();
        }
    }

    /// @dev called when a user wants to redeem. should only be called when oracle is below a dollar
    /// @param amount the amount of dollars to exchange for coupons
    function exchangeDollarsForCoupons(uint256 amount) external returns(uint256) {
        UniswapOracle oracle = UniswapOracle(config.twapOracleAddress());
        oracle.update(config.stabilitasTokenAddress(), config.comparisonTokenAddress());

        uint256 twapPrice = getTwapPrice();

        require(twapPrice < 1000000, "Price must be below 1 to mint coupons");

        DebtCoupon debtCoupon = DebtCoupon(config.debtCouponAddress());
        debtCoupon.updateTotalDebt();

        //we are in a down cycle so reset the cycle counter
        dollarsMintedThisCycle = 0;

        ICouponsForDollarsCalculator couponCalculator = ICouponsForDollarsCalculator(config.couponCalculatorAddress());
        uint256 couponsToMint = couponCalculator.getCouponAmount(amount);

        //TODO: @Steve to call burn on stabilitas contract here
        MockStabilitasToken(config.stabilitasTokenAddress()).burn(msg.sender, amount);

        uint256 expiryTimestamp = block.timestamp.add(couponLengthSeconds);
        debtCoupon.mintCoupons(msg.sender, couponsToMint, expiryTimestamp);

        //give the caller timestamp of minted nft
        return expiryTimestamp;
    }

    /// @dev uses the current coupons for dollars calculation to get coupons for dollars
    /// @param amount the amount of dollars to exchange for coupons
    function getCouponsReturnedForDollars(uint256 amount) view external returns(uint256) {
        ICouponsForDollarsCalculator couponCalculator = ICouponsForDollarsCalculator(config.couponCalculatorAddress());
        return couponCalculator.getCouponAmount(amount);
    }

    /// @dev should be called by this contract only when getting coupons to be burnt
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
        //TODO: Change this to hasrole. remove ! as was for testing...
        if(!config.hasRole(config.COUPON_MANAGER_ROLE(), operator)) {
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
