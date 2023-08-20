// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "./SafeMath.sol";
library UniswapV2Library {
    using SafeMath for uint ;

    //对两个token进行拍排序
    function sortToken(address tokenA , address tokenB ) internal pure returns (address token0 ,address token1){
        require(tokenA != tokenB ,"Identical address");
        (token0,token1) = tokenA < tokenB ? (tokenA,tokenB) : (tokenB,tokenA);
        require(token0 != address(0) , "zero address");
    }
    
    //在不进行任何外部调用的情况下计算一对的CREATE2地址
    function pairFor(address factory , address tokenA ,address tokenB) internal  pure returns (address pires){
        (address token0,address token1) = sortToken(tokenA, tokenB);
        pires = address (uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token0,token1)),
            hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash

        ))));

    }
    

}
