// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract LRLBTHT is ERC20, Ownable, ERC20Permit {
    constructor()
        ERC20("BerthoLar", "LRLBTHT")
        Ownable(msg.sender)
        ERC20Permit("BerthoLar")
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
