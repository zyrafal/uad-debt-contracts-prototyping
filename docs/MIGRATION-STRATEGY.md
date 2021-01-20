The coupons have been designed to only be used by a redemption contract which issued them. This means that they should not be redeemable by another contract. The reason for this is so that if a migration is to ever occur, we just create a new debt coupon, a new debt redemption contract and stop issuing the old coupon. Old coupons will still be redeemable by the old redemption contract and when all those coupons expire, that contract is naturally phased out. In parallel, new coupons can be issued and redeemed by the new contract.

If at any point we want to change the coupon expiry time, we must follow the following procedure:

1. Create new debt coupon (v2)
2. Create new debt redemption contract married to coupon v2
3. Give the new debt redemption contract access to mint dollar token using DollarConfig
4. Create a new IExcessDollarsDistributor which distributes 100% of dollar to new redemption contract. Since both contracts are unaware of eachothers state, this excess from v1 may not actually be excess i.e. there will probably be v2 coupons in circulation. By forwarding them to the second redemption contract, they are available for redemption. If they are truly excess, the v2 contract can distribute these using its own ExcessDollarsDistributor. By using this forwarding mechanism, we avoid any dollars being misclassified as excess and unfairly distributed.
5. Call couponMintingEnabled(false) on the old contract so it can't mint any more coupons.
6. On the frontend, check coupon address before routing to correct redemption contract. You can call redemptionContractAddress() on the coupon itself to get the address.
7. Redirect any old burnCoupon calls on the frontend to the new contract as burns should only occur on the new contract. Remove burn access from the old contract.

Note: Since totalOutstandingDebt() is kept track of in the DebtCoupon contract, when we switch Coupon contract, each coupon will only keep track of its own balance. This means for some period of time:
```
totalOutstandingDebt() = oldCouponDebt() + newCouponDebt().
```

Eventually, since oldCouponDebt() will become 0
```
totalOutstandingDebt() = newCouponDebt()
```

However, in the migration period, if totalDebt() is used in the system, we must replace it to account for old debt too. Take for example the following code in DebtCouponManager.sol
```
contract CouponsForDollarsCalculator is ICouponsForDollarsCalculator {
    function getCouponAmount(uint256 dollarsToBurn) external view override returns(uint256) {
        uint256 totalDebt = DebtCoupon(debtCouponAddress).totalOutstandingDebt();
        uint256 r = totalDebt.div(IERC20(config.dollarTokenAddress()).totalSupply());
        uint256 onePlusRAllSquared = (r.add(1)).mul(r.add(1));

        //rewards per dollar is (1 / (1 + R)^2) - 1
        return ((dollarsToBurn).div(onePlusRAllSquared)).sub(1);
    }
}
```

When we release the new DebtCouponManager, this calculator will not take into account old debt. Assuming we want to use the same formula, we must introduce a revised calculator which looks like this:
```
contract CouponsForDollarsCalculator is ICouponsForDollarsCalculator {
    function getCouponAmount(uint256 dollarsToBurn) external view override returns(uint256) {
        uint256 totalDebt = DebtCoupon(oldDebtCouponAddress).totalOutstandingDebt().add(DebtCouponV2(newDebtCouponAddress).totalOutstandingDebt());
        uint256 r = totalDebt.div(IERC20(config.dollarTokenAddress()).totalSupply());
        uint256 onePlusRAllSquared = (r.add(1)).mul(r.add(1));

        //rewards per dollar is (1 / (1 + R)^2) - 1
        return ((dollarsToBurn).div(onePlusRAllSquared)).sub(1);
    }
}
```

This calculator will remain valid after the migration period so there will be no need to change it after all old coupons are expired