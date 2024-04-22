// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20("Token", "TK") {
    bool _hasMinted;

    function mint() external payable {
        require(_hasMinted == false);
        _hasMinted = true;
        _mint(msg.sender, 10000000000 * 10 ** 18);
    }
}