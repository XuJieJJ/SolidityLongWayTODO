pragma solidity =0.5.16;
import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';
contract UniswapV2Factory is IUniswapV2Factory{
        address public feeTo;//记录开发者团队的地址,用于切换开发团队手续费开关
        address public feeToSetter;//改变开发者团队的地址

        //前两个地址分别对应交易对中两种代币的地址，最后一个地址是交易对合约本身地址
        mapping (address => mapping (address =>address )) public getPair;
        address [] public  allPairs;//存放所有交易对合约地址信息

        //在创建币对时触发，保存交易对的信息(两个代币地址，交易对地址，创建交易对的数量)
        event PairCreated(address indexed  token0,address indexed  token1,address pair,uint);

        constructor(address _feeToSetter) public {
            feeToSetter = _feeToSetter;
        }

        function allPairsLength()external view returns (uint){
            return allPairs.length;
        }
        
        function setFeeTo(address _feeTo) external {
            require(msg.sender == feeToSetter,"UniswapV2:forbidden");
            feeTo = _feeTo;
        }
        function setFeeToSetter(address _feeToSetter) external {
            require(msg.sender == feeToSetter,"UniswapV2:forbidden");
            feeToSetter = _feeToSetter;
        }

        //创建交易对
        function createPair(address tokenA,address tokenB) external returns (address pair){
            require(tokenA !=tokenB,"Uniswap:token address same!!!!");
            (address token0,address token1) = tokenA < tokenB ? (tokenA,tokenB):(tokenB,tokenA);
            require(token0 != address(0),"UniswapV2:token is zero address!!!");
            require(getPair[token0][token1] == address(0),"UniswapV2:pair exists"); 


            //ceate2计算pair地址
            bytes memory bytecode = type(UniswapV2Pair).creationCode;
            bytes32 salt = keccak256(abi.encodePacked(token0,token1));
            assembly {
                pair := create2(0,add(bytecode,32),mload(bytecode),salt)
            } 
            IUniswapV2Pair(pair).initialize(token0,token1);
            getPair[token0][token1] = pair;
            getPair[token1][token0] = pair;
            allPairs.push(pair);
            emit PairCreated(token0, token1, pair,allPairs.length );
        }





}