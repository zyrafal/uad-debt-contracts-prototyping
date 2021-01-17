// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "hardhat/console.sol";

/// @title Example dollar distributor
contract MockExcessDollarsDistributor {
    function distributeDollars(uint256 excessDollars) external {
        console.log("Imagine this is distributing some dollars");
    }
}
