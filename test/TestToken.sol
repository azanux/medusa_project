//SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import {Token} from "../src/token.sol";

contract TestToken is Token {
    address echidna_caller = msg.sender;

    constructor() {
        balances[echidna_caller] = 10000;
    }
    // add the property

    function fuzz_test_balance() public view returns (bool) {
        return balances[echidna_caller] <= 10000;
    }
}

contract TestTokenPause is Token {
    address echidna_caller = msg.sender;

    constructor() {
        balances[echidna_caller] = 10000;
        paused();
        owner = address(0);
    }
    // add the property

/** 
    function fuzz_test_upause() public view returns (bool) {
        return is_paused == true;
    }

    */

    function testPausable(uint256 amount) public  {
        assert(is_paused== true);
    }
}