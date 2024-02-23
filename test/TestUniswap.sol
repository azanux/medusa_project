pragma solidity ^0.6.0;

import "./uniswap/Setup.sol";
import "../src/libraries/UniswapV2Library.sol";

contract TestUniswap is Setup {
    event AmountsIn(uint amount0, uint amount1);
    event AmountsOut(uint amount0, uint amount1);
    event BalancesBefore(uint balance0, uint balance1);
    event BalancesAfter(uint balance0, uint balance1);
    event ReservesBefore(uint reserve0, uint reserve1);
    event ReservesAfter(uint reserve0, uint reserve1);

    function testProvideLiquidity(uint amount0, uint amount1) public {
        // Preconditions:
        amount0 = _between(amount0, 1000, uint(-1));
        amount1 = _between(amount1, 1000, uint(-1));

        if (!completed) {
            _init(amount0, amount1);
        }
        //// State before
        uint lpTokenBalanceBefore = pair.balanceOf(address(user));
        (uint reserve0Before, uint reserve1Before,) = pair.getReserves();
        uint kBefore = reserve0Before * reserve1Before;
        //// Transfer tokens to UniswapV2Pair contract
        (bool success1,) = user.proxy(address(testToken1), abi.encodeWithSelector(testToken1.transfer.selector, address(pair), amount0));
        (bool success2,) = user.proxy(address(testToken2), abi.encodeWithSelector(testToken2.transfer.selector, address(pair), amount1));
        require(success1 && success2);

        // Action:
        (bool success3,) = user.proxy(address(pair), abi.encodeWithSelector(bytes4(keccak256("mint(address)")), address(user)));

        // Postconditions:
        if (success3) {
            uint lpTokenBalanceAfter = pair.balanceOf(address(user));
            (uint reserve0After, uint reserve1After,) = pair.getReserves();
            uint kAfter = reserve0After * reserve1After;
            assert(lpTokenBalanceBefore < lpTokenBalanceAfter);
            assert(kBefore < kAfter);
        }
    }

}
