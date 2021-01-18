# Stabilitas Debt

This package covers the Debt ERC1155 coupons which are issued by the system and the issuance/redemption mechanism for those coupons.

# Notes

- If we change the expiry time of coupons, existing coupons wont have their expiries retroactively modified.

TODO:
- Auto replace contractAddresses on deploy.

TODO (Steve):
- Assuming you can change comparisonToken, change the 1000000 values so that regardless of what token is used it will work i.e. USDC has 6 decimals which is an exception - default is 18. 