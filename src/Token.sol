// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20("Token", "TK") {
    bool _hasMinted;

    function mint(address _recipient, uint256 _amount) external payable {
        require(_hasMinted == false);
        _hasMinted = true;
        _mint(_recipient, _amount);
    }
}
