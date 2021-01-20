// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockDollarToken is ERC20 {
    constructor(uint256 initialSupply) public ERC20("STABILITAS", "STAB") {
        _mint(msg.sender, initialSupply);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}