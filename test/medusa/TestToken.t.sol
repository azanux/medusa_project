//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Token} from "../../src/Token.sol";
import {IHevm} from "../util/IHevm.sol";

contract TestToken {
    address admin = address(0x123);
    address attacker = address(0x124);

    IHevm constant vm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    Token token;

    constructor() {
        vm.prank(admin);
        token = new Token();

        vm.prank(admin);
        token.setBalance(attacker, 10000);

        console.log("Token address: ", token.owner());
        assert(token.owner() == admin);
    }

    function echidna_upause(uint256 amount) public {
        assert(token.is_paused() == false);
    }

    function echidna_balance() public {
        assert(token.balances(attacker) <= 10000);
    }
}
