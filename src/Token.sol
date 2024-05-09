//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../test/util/lib.sol";

/**
 * @title Ownership
 * @author azanux
 * @notice This contract is used to manage ownership
 */
contract Ownership {
    address public owner = msg.sender;

    function Owner() public {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(owner == msg.sender);
        _;
    }
}

/**
 * @title Pausable
 * @author azanux
 * @notice This contract is used to manage pausing and resuming
 */
contract Pausable is Ownership {
    bool public is_paused;

    modifier ifNotPaused() {
        require(!is_paused);
        _;
    }

    function paused() public isOwner {
        is_paused = true;
    }

    function resume() public isOwner {
        is_paused = false;
    }
}

/**
 * @title Token
 * @author azanux
 * @notice This contract is used to manage token with tranfer and givin air drop
 */
contract Token is Pausable {
    mapping(address => uint256) public balances;

    function transfer(address to, uint256 value) public ifNotPaused {
        require(balances[msg.sender] >= value, "Insufficient balance.");
        balances[msg.sender] -= value;
        balances[to] += value;
    }

    function airDrop() public ifNotPaused {
        balances[msg.sender] += 10;
    }

    function setBalance(address account, uint256 value) public isOwner {
        balances[account] = value;
    }
}
