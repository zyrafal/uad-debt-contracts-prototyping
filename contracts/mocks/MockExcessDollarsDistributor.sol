// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../interfaces/IExcessDollarsDistributor.sol";
import "hardhat/console.sol";

/// @title Example dollar distributor
contract MockExcessDollarsDistributor is IExcessDollarsDistributor {
    function distributeDollars() external override {
        console.log("Imagine this is distributing some dollars");
    }
}
