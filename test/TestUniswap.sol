pragma solidity ^0.6.0;

import "./uniswap/Setup.sol";
import "../src/libraries/UniswapV2Library.sol";

contract TestUniswap is Setup {
    event AmountsIn(uint256 amount0, uint256 amount1);
    event AmountsOut(uint256 amount0, uint256 amount1);
    event BalancesBefore(uint256 balance0, uint256 balance1);
    event BalancesAfter(uint256 balance0, uint256 balance1);
    event ReservesBefore(uint256 reserve0, uint256 reserve1);
    event ReservesAfter(uint256 reserve0, uint256 reserve1);

    function testProvideLiquidity(uint256 amount0, uint256 amount1) public {
        // Preconditions:
        amount0 = _between(amount0, 1000, uint256(-1));
        amount1 = _between(amount1, 1000, uint256(-1));

        if (!completed) {
            _init(amount0, amount1);
        }
        //// State before
        uint256 lpTokenBalanceBefore = pair.balanceOf(address(user));
        (uint256 reserve0Before, uint256 reserve1Before,) = pair.getReserves();
        uint256 kBefore = reserve0Before * reserve1Before;
        //// Transfer tokens to UniswapV2Pair contract
        (bool success1,) = user.proxy(
            address(testToken1), abi.encodeWithSelector(testToken1.transfer.selector, address(pair), amount0)
        );
        (bool success2,) = user.proxy(
            address(testToken2), abi.encodeWithSelector(testToken2.transfer.selector, address(pair), amount1)
        );
        require(success1 && success2);

        // Action:
        (bool success3,) =
            user.proxy(address(pair), abi.encodeWithSelector(bytes4(keccak256("mint(address)")), address(user)));

        // Postconditions:
        if (success3) {
            uint256 lpTokenBalanceAfter = pair.balanceOf(address(user));
            (uint256 reserve0After, uint256 reserve1After,) = pair.getReserves();
            uint256 kAfter = reserve0After * reserve1After;
            assert(lpTokenBalanceBefore < lpTokenBalanceAfter);
            assert(kBefore < kAfter);
        }
    }
}
