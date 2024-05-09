//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../src/Staker.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GRYDL is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public override returns (bool) {
        _transfer(_from, _to, _amount);
        return true;
    }
}
