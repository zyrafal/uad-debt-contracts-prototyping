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

    address public redemptionContractAddress = address(0);
    bool redemptionContractSet = false;

    uint256 totalOutstandingDebt; //not public as if called externally can give inaccurate value. see method
    mapping(uint256 => uint256) tokenSupplies; //represents tokenSupply of each expiry (since 1155 doesnt have this)
    uint256[] sortedExpiryTimes; //ordered list of coupon expiries

    //@dev URI param is if we want to add an off-chain meta data uri associated with this contract
    constructor(
        address _config
    ) public ERC1155("URI") {
        config = StabilitasConfig(_config);
        totalOutstandingDebt = 1; //TODO: Make this 0
    }

    /// @notice Mint an amount of coupons expiring at a certain time for a certain recipient
    /// @param amount amount of tokens to mint
    /// @param expiryTimestamp the timestamp of the coupons to mint
    function mintCoupons(
        address recipient,
        uint256 amount,
        uint256 expiryTimestamp
    ) public {
        //require(hasRole(config.COUPON_MANAGER_ROLE(), msg.sender), "Caller is not a coupon manager");
        _mint(recipient, expiryTimestamp, amount, "");
        emit MintedCoupons(recipient, expiryTimestamp, amount);

        //insert new relevant timestamp if it doesnt exist in our list
        //if(!sortedExpiryTimes.exists(expiryTimestamp)) {
        //    sortedExpiryTimes.insert(expiryTimestamp);
        //}

        //update the total supply for that expiry and total outstanding debt
        //tokenSupplies[expiryTimestamp] = tokenSupplies[expiryTimestamp].add(amount);
        //totalOutstandingDebt = totalOutstandingDebt.add(amount);
    }

    /// @notice Burn an amount of coupons expiring at a certain time from a certain holder's balance
    /// @param couponOwner the owner of those coupons
    /// @param amount amount of tokens to burn
    /// @param expiryTimestamp the timestamp of the coupons to burn
    function burnCoupons(
        address couponOwner,
        uint256 amount,
        uint256 expiryTimestamp
    ) public {
        //require(hasRole(config.COUPON_MANAGER_ROLE(), msg.sender), "Caller is not a coupon manager");
        require(balanceOf(couponOwner, expiryTimestamp) >= amount, "Coupon owner doesn't have enough coupons");
        _burn(couponOwner, expiryTimestamp, amount);
        emit BurnedCoupons(couponOwner, expiryTimestamp, amount);

        //update the total supply for that expiry and total outstanding debt
        //tokenSupplies[expiryTimestamp] = tokenSupplies[expiryTimestamp].sub(amount);
        //totalOutstandingDebt = totalOutstandingDebt.sub(amount);
    }

    /*
    function updateTotalDebt() public {
        bool reachedEndOfExpiredKeys = false;
        uint256 currentTimestamp = sortedExpiryTimes.first();

        while (!reachedEndOfExpiredKeys && currentTimestamp != 0) {
            uint256 currentKey = sortedExpiryTimes.first();
            if(sortedExpiryTimes.first() > block.timestamp) {
                reachedEndOfExpiredKeys = true;
            } else {
                //update tally and remove key from times and map
                totalOutstandingDebt = totalOutstandingDebt.sub(tokenSupplies[currentKey]);
                delete tokenSupplies[currentKey];
                sortedExpiryTimes.remove(currentKey);
            }
            currentTimestamp = sortedExpiryTimes.first();
        }
    }
    */

    //TODO: Replace with real one
    function updateTotalDebt() public {
    }

    function getTotalOutstandingDebt() public view returns(uint256) {
        //TODO: We also need to add on the pending expired debt
        return totalOutstandingDebt;
    }

    /// @notice This can only be done once, and should be done post-deployment!
    function setRedemptionContractAddress(address newAddress) external {
        //require(hasRole(config.COUPON_MANAGER_ROLE(), msg.sender), "Caller is not a coupon manager");
        //require(redemptionContractSet, "Redemption contract has already been set");
        redemptionContractSet = true;
        redemptionContractAddress = newAddress;
    }

    event MintedCoupons(address recipient, uint256 expiryTime, uint256 amount);

    event BurnedCoupons(address couponHolder, uint256 expiryTime, uint256 amount);
}
