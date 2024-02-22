//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../src/Staker.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {GRYDL} from "./GRYDL.sol";

/**
 * contract GRYDL is ERC20 {
 *
 *     constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}
 *
 *     function mint(address _to, uint256 _amount) external {
 *         _mint(_to, _amount);
 *     }
 *
 *
 *     function transferFrom(address _from, address _to, uint256 _amount) public override returns (bool) {
 *         address _spender = msg.sender;
 *         _transfer(_from, _to, _amount);
 *         return true;
 *     }
 *
 *
 * }
 */
// We are using an external testing methodology
contract TestStaker {
    Staker stakerContract;
    GRYDL tokenToStake;

    event Debug(uint256 value);

    // setup
    constructor() {
        tokenToStake = new GRYDL("Token", "TOK");
        stakerContract = new Staker(address(tokenToStake));
        //tokenToStake.mint(address(this), 10000000000 * 1e18);
    }

    // function-level invariants
    function testStake(uint256 _amount) public {
        emit Debug(tokenToStake.balanceOf(address(this)));

        // Pre-condition
        require(tokenToStake.balanceOf(address(this)) > 0);

        // Optimization: amount is now bounded between [1, balanceOf(address(this))]
        uint256 amount = 1 + (_amount % (tokenToStake.balanceOf(address(this))));
        // State before the "action"
        uint256 preStakedBalance = stakerContract.stakedBalances(address(this));

        try stakerContract.stake(amount) returns (uint256 stakedAmount) {
            uint256 balanceStake = stakerContract.stakedBalances(address(this));
            uint256 balanceStake2 = preStakedBalance + stakedAmount;

            emit Debug(balanceStake);
            emit Debug(balanceStake2);

            //assert(false);
            // Post-condition
            assert(balanceStake == balanceStake2);
        } catch {
            assert(false);
        }
    }

    function testUnstake(uint256 _stakedAmount) public {
        // Pre-condition
        require(stakerContract.stakedBalances(address(this)) > 0);
        // Optimization: amount is now bounded between [1, stakedBalance[address(this)]]
        uint256 stakedAmount = 1 + (_stakedAmount % (stakerContract.stakedBalances(address(this))));
        // State before the "action"
        uint256 preTokenBalance = tokenToStake.balanceOf(address(this));
        // Action
        uint256 amount = stakerContract.unstake(stakedAmount);
        // Post-condition
        assert(tokenToStake.balanceOf(address(this)) == preTokenBalance + amount);
    }
}
