//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import {Token} from "../../src/Token.sol";
import {Test} from "forge-std/Test.sol";

contract TestTokenF is Test {
    Token token;

    address owner = address(0xabc123);
    address attacker = address(0xabc124);

    function setUp() public {
        vm.prank(owner);
        token = new Token();

        vm.prank(owner);
        token.setBalance(owner, 10000);

        vm.prank(owner);
        token.setBalance(attacker, 10000);
    }

    /**
     * This invariant assures that the contract is not paused
     */
    function invariant_is_pause() public view {
        assert(token.is_paused() == false);
    }

    /**
     * This invariant will assure that the balance of the attacker is less than or equal to 10000
     */
    function invariant_balance() public view {
        assert(token.balances(attacker) <= 10000);
    }
}
