// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract ExampleToken is ERC20, Ownable {
    constructor() ERC20("ExampleToken", "ETK") { }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
