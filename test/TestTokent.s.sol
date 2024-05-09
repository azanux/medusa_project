//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import {Token} from "../src/Token.sol";
import {Test, console} from "forge-std/Test.sol";

contract TestTokenFuzz is Test {
    Token private token;

    address user1 = 0x0000000000000000000000000000000000020000;
    address sender = 0x0000000000000000000000000000000000010000;

    uint256 public constant BALANCE = 10000;

    function setUp() public {
        token = new Token();
        token.transfer(sender, BALANCE);
    }

    function test_balance() public {
        vm.prank(sender);
        token.transfer(user1, 100);
        assertEq(token.balances(sender), BALANCE - 100);
    }

    function test_inf_balance() public {
        vm.prank(sender);
        token.transfer(user1, 100);
        assertTrue(token.balances(sender) < BALANCE);
    }

    function test_hack() public {
        vm.prank(sender);
        token.transfer(user1, 95844903195313462654964571662396384580925718010086413584460847595814912750739);

        console.log("Balance: ", token.balances(sender));

        assertTrue(token.balances(sender) < BALANCE);
    }
}
