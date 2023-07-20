pragma solidity =0.5.16;
import './interfaces/IUniswapV2Pair.sol';
import './UniswapV2ERC20.sol';
import './libraries/Math.sol';
import './libraries/UQ112x112.sol';
import './interfaces/IERC20.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Callee.sol';
/////////////////////////////////  配对合约    /////////////////////////////////////////////////////
contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    using  SafeMath for uint;
    using  UQ112x112 for uint224;


    uint  public  constant MINIMUM_LIQUIDITY = 10**3;//最小流动性
    bytes4 private constant SELECTOR = bytes4(keccak256(
        bytes('transfer(address,uint256')
    ));//ERC20转移资产中transfer对应的函数选择器

    address public  factory;
    address public  token0;
    address public  token1;//代币以及币对地址

    uint112 private reserve0;
    uint112 private reserve1;//两个变量用于记录恒定乘积 两个变量记录代币储备量
    uint32  private blockTimestampLast;//记录交易时的区块创建时间

    uint    public  price0CumulativeLast;
    uint    public  price1CumulativeLast;//记录交易对中两种价格的累计值
    uint    public  kLast;  //reserve0*reserve1 计算恒定乘积k，记录手续费

    uint    private unlocked = 1;//限制一些操作只能有一个同时运行
    
    modifier lock(){
        require(unlocked==1,"LOCKED!!!");
        unlocked=0;
        _;
        unlocked=1;
    }
    //////获取两种代币储备量
    function getReserves() public view returns (uint112 _reserve0,uint112 _reserve1,uint32 _blockTimestampLast){
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
        
    }
    //////转账 private/////
    function _safeTranfer(address token,address to ,uint value) private {
        (bool success,bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to,value));
        require(success&&  (data.length==0 ||abi.decode(data,(bool)) ),"UniswapV2:TRANSFER_FAILED");

    }

    ///////////////////////////////////////////////////////////////////////////
    //mint() burn() swap() 分别对应添加流动性、移除流动性、兑换三种操作的底层函数
    ////////////////以下三个事件在三种操作触发时候释放
    event Mint(address indexed sender,uint amount0,uint amount1);
    event Burn(address indexed sender,uint amount0,uint amoutn1,address indexed to);
    event Swap(
        address indexed  sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed  to 
    );
    event Sync(uint112 reserve0,uint112 reserve1);

    constructor() public {
        factory = msg.sender;
    }
//初始化
    function initialize(address _token0,address _token1)external {
        require(msg.sender==factory,"UniswapV2:FORBIDDEN");
        token0 = _token0;
        token1 = _token1;
    }
//更新操作，前两个为更新后的两个token储备量，后两个为更新前的储备量
    function _update(uint balance0,uint balance1,uint112 _reserve0,uint112 _reserve1)private {
        require(balance0 <=uint112(-1) && balance1 <= uint112(-1), "UniswapV2:OVERFLOW" );
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);//只取后32位
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        if(timeElapsed > 0 && _reserve0!=0 && _reserve1 != 0){
            //记录价格累计值 两个价格用来计算swap
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;

        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);

        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    function _mintFee(uint112 _reserve0,uint112 _reserve1 )private  returns (bool feeOn){
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast;
        if(feeOn){
            if(_kLast != 0){
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                     if(rootK > rootKLast){
                         uint numerator = totalSupply.mul(rootK.sub(rootKLast));//计算交易手续费的分子
                         uint denominator = rootK.mul(5).add(rootKLast);//计算交易手续费的分母
                         uint liquidity = numerator / denominator;
                         if(liquidity > 0)  _mint(feeTo, liquidity);

                     }          
            }
        }else  if(_kLast != 0 ){
            kLast = 0;
        }

    }

    function mint(address to ) external  lock returns (uint liquidity){
        (uint112 _reserve0,uint112 _reserve1,) = getReserves();//获取两个token的的储备量
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));//当前合约两个token余额
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);//合约中两个token的可用余额，及未被锁定的资产数量
        
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply;
        if(_totalSupply == 0 ){
            liquidity = Math.sqrt(amount0.mul(amount1).sub(MINIMUM_LIQUIDITY));//liquidity = √(amount0*amount1) - MINIMUM_LIQUIDITY
            _mint(address(0), MINIMUM_LIQUIDITY);
        }else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
            //liquidity1 = amount0 * totalSupply / reserve0
            //liquidity2 = amount1 * totalSupply / reserve1
            //✔
        }
        require(liquidity > 0 ,"UniswapV2: liquidity balance not enough");
        _mint(to,liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if(feeOn) kLast = uint(reserve0).mul(reserve1);
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to )external lock returns (uint amount0,uint amount1){
        (uint112 _reserve0,uint112 _reserve1,) = getReserves();
        address _token0 = token0;
        address _token1 = token1;
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply;
        amount0 = liquidity.mul(balance0) / _totalSupply;
        amount1 = liquidity.mul(balance1) / _totalSupply;

        require(amount0 > 0 && amount1 > 0,"UniswapV2: something wrong");
        _burn(to, liquidity);
        _safeTranfer(_token0, to, amount0);
        _safeTranfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if(feeOn) kLast = uint(reserve0).mul(reserve1);
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(uint amount0Out,uint amount1Out,address to,bytes calldata data)external lock{
        require(amount0Out > 0 || amount1Out > 0 , "UniswapV2: output amount!!!");
        (uint112 _reserve0,uint112 _reserve1 ,)= getReserves();
        require(amount0Out < _reserve0 && amount1Out < _reserve1,"liquidity not enough");

        uint balance0;
        uint balance1;
        //_token(0,1)的作用域，避免了堆栈过深的错误
        {
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to !=_token1 ,"INVALID_toAddress");
        if(amount0Out > 0) _safeTranfer(_token0, to, amount0Out);
        if(amount1Out > 0) _safeTranfer(_token1, to, amount1Out);
        if(data.length > 0 )IUniswapV2Callee(to).uniswapV2Call(msg.sender,amount0Out,amount1Out,data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }

        uint amount0In = balance0 > _reserve0-amount0Out ? balance0 - (_reserve0-amount0Out) : 0;
        uint amoutn1In = balance1 > _reserve1-amount1Out ? balance1 - (_reserve1-amount1Out) : 0;

        require(amount0In > 0 || amoutn1In > 0 ," inputAmount not enough!!!");
        {
            uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
            uint balance1Adjusted = balance1.mul(1000).sub(amoutn1In.mul(3));
            require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(reserve1));
        }


    }





}