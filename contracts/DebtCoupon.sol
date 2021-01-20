// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "solidity-linked-list/contracts/StructuredLinkedList.sol";
import "./DollarConfig.sol";

/// @title A coupon redeemable for dollars with an expiry time
/// @notice An ERC1155 where the token ID is the expiry time
/// @dev Implements ERC1155 so receiving contracts must implement IERC1155Receiver
contract DebtCoupon is ERC1155 {
    using SafeMath for uint256;
    using StructuredLinkedList for StructuredLinkedList.List;

    DollarConfig public config;

    address public redemptionContractAddress = address(0);
    bool redemptionContractSet = false;

    uint256 totalOutstandingDebt; //not public as if called externally can give inaccurate value. see method
    mapping(uint256 => uint256) tokenSupplies; //represents tokenSupply of each expiry (since 1155 doesnt have this)
    StructuredLinkedList.List sortedExpiryTimes; //ordered list of coupon expiries

    //@dev URI param is if we want to add an off-chain meta data uri associated with this contract
    constructor(
        address _config
    ) ERC1155("URI") { // FIXME: can this be blank or do we need to figure some URI
        config = DollarConfig(_config);
        totalOutstandingDebt = 0;
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

        //insert new relevant timestamp if it doesnt exist in our list (linkedlist implementation wont insert if dupe)
        sortedExpiryTimes.pushBack(expiryTimestamp);

        //update the total supply for that expiry and total outstanding debt
        tokenSupplies[expiryTimestamp] = tokenSupplies[expiryTimestamp].add(amount);
        totalOutstandingDebt = totalOutstandingDebt.add(amount);
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
        tokenSupplies[expiryTimestamp] = tokenSupplies[expiryTimestamp].sub(amount);
        totalOutstandingDebt = totalOutstandingDebt.sub(amount);
    }

    /// @notice Should be called prior to any state changing functions. Updates debt according to current block time
    function updateTotalDebt() public {
        bool reachedEndOfExpiredKeys = false;
        uint256 currentTimestamp = sortedExpiryTimes.popFront();

        //if list is empty, currentTimestamp will be 0
        while(!reachedEndOfExpiredKeys && currentTimestamp != 0) {
            if(currentTimestamp > block.timestamp) {
                //put the key back in since we popped, and end loop
                sortedExpiryTimes.pushFront(currentTimestamp);
                reachedEndOfExpiredKeys = true;
            } else {
                //update tally and remove key from times and map
                totalOutstandingDebt = totalOutstandingDebt.sub(tokenSupplies[currentTimestamp]);
                delete tokenSupplies[currentTimestamp];
                sortedExpiryTimes.remove(currentTimestamp);
            }
            currentTimestamp = sortedExpiryTimes.popFront();
        }
    }

    /// @notice Returns outstanding debt by fetching current tally and removing any expired debt
    function getTotalOutstandingDebt() public view returns(uint256) {
        uint256 outstandingDebt = totalOutstandingDebt;
        bool reachedEndOfExpiredKeys = false;
        (, uint256 currentTimestamp) = sortedExpiryTimes.getNextNode(0);

        while(!reachedEndOfExpiredKeys && currentTimestamp != 0) {
            if(currentTimestamp > block.timestamp) {
                reachedEndOfExpiredKeys = true;
            } else {
                outstandingDebt = outstandingDebt.sub(tokenSupplies[currentTimestamp]);
            }
            (,currentTimestamp) = sortedExpiryTimes.getNextNode(currentTimestamp);
        }

        return outstandingDebt;
    }

    /// @notice This can only be done once, and should be done post-deployment!
    function setRedemptionContractAddress(address newAddress) external {
        //require(config.hasRole(config.COUPON_MANAGER_ROLE(), msg.sender), "Caller is not a coupon manager");
        require(!redemptionContractSet, "Redemption contract has already been set");
        redemptionContractSet = true;
        redemptionContractAddress = newAddress;
    }

    event MintedCoupons(address recipient, uint256 expiryTime, uint256 amount);

    event BurnedCoupons(address couponHolder, uint256 expiryTime, uint256 amount);
}
