pragma solidity ^0.6.0;

import "../../src/uni-v2/UniswapV2ERC20.sol";
import "../../src/uni-v2/UniswapV2Pair.sol";
import "../../src/uni-v2/UniswapV2Factory.sol";
import "../../src/libraries/UniswapV2Library.sol";

contract Users {
    function proxy(address target, bytes memory data) public returns (bool success, bytes memory retData) {
        return target.call(data);
    }
}

contract Setup {
    UniswapV2Factory factory;
    UniswapV2Pair pair;
    UniswapV2ERC20 testToken1;
    UniswapV2ERC20 testToken2;
    Users user;
    bool completed;

    constructor() public {
        testToken1 = new UniswapV2ERC20();
        testToken2 = new UniswapV2ERC20();
        factory = new UniswapV2Factory(address(this));
        pair = UniswapV2Pair(factory.createPair(address(testToken1), address(testToken2)));
        // Sort the test tokens we just created, for clarity when writing invariant tests later
        (address testTokenA, address testTokenB) = UniswapV2Library.sortTokens(address(testToken1), address(testToken2));
        testToken1 = UniswapV2ERC20(testTokenA);
        testToken2 = UniswapV2ERC20(testTokenB);
        user = new Users();
        user.proxy(address(testToken1), abi.encodeWithSelector(testToken1.approve.selector, address(pair), uint256(-1)));
        user.proxy(address(testToken2), abi.encodeWithSelector(testToken2.approve.selector, address(pair), uint256(-1)));
    }

    function _init(uint256 amount1, uint256 amount2) internal {
        testToken1.mint(address(user), amount1);
        testToken2.mint(address(user), amount2);
        completed = true;
    }

    function _between(uint256 val, uint256 low, uint256 high) internal pure returns (uint256) {
        return low + (val % (high - low + 1));
    }
}
