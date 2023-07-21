# Uniswap-V2死磕源码

Uniswap智能合约由两个GitHub项目组成 一个是[core](https://github.com/Uniswap/v2-core)（核心合约）， 一个是periphery（周边合约）

core偏核心逻辑，单个交易对swap的逻辑。periphery偏外围服务，在一个个swap的基础上构建服务。单个swap由两种代币形成的交易对，俗称“池子“。

每个交易对含有以下属性：

**reverse0/reverse1**:交易对的两种代币的存储量。

**totalsupply**：当前流动性代币的总量。每个交易对都对应一个流动性代币（LPT liquidity provider token）简单地说，LPT记录了所有流动性提供者（LP）的贡献，所有流动性代币的总和就是totalsupply；

uniswap核心逻辑:交易对的两种代币乘积为定值

```
reverse0*reverse1=k
```

## Core

核心合约实现了UniswapV2的完整功能：创建交易对 流动性补给 交易代币 价格语言机登

Core核心合约由factory（UniswapV2Factory.sol）和交易对合约（UniswapV2Pair.sol）和LP Token合约（UniswapV2ERC20.sol）及相关接口和库合约组成

---

### UniswapV2Pair.sol配对合约

管理流动性资金池，不同的币有不同的配对合约实例，eg.USDT-WETH这一个币对，对应着一个配对合约实例

#### 源码分析

**MINIMUM_LIQUIDITY** ： 定义最小流动性，在提供初始流动性时候会被燃烧掉

**SELECTOR** ：用于计算ERC20合约当中转移资产transfer对应的函数选择器

**factory** ： 用于存储factory合约地址，**token0**、**token1**分别表示两种代币的地址

**reserve0 reserve1** ： 记录两个代币的储备量，方便计算恒定乘积

**blockTimestampLast** ： 记录交易时的区块创建时间

**price0CumulativeLast、price1CumulativeLast** ： 记录交易中两个价格的累计值

**KLast** ： 记录恒定乘积k

**unlock = 1** ： 表示未被锁上的操作，在修饰器当中限制一些操作只能有一个同时运行

**modifier修饰器**：

```solidity
modifier lock(){
        require(unlocked==1,"LOCKED!!!");
        unlocked=0;
        _;
        unlocked=1;
    }
```



在UniswapV2中，配对合约由工厂合约创建，从配对合约的构造函数和初始化函数当中可以看出

```solidity
constructor() public {
        factory = msg.sender;
    }
//初始化
    function initialize(address _token0,address _token1)external {
        require(msg.sender==factory,"UniswapV2:FORBIDDEN");
        token0 = _token0;
        token1 = _token1;
    }
```

构造函数直接讲**msg.sender**设置为了**factory**，factory即为工厂合约地址，初始化函数又require调用者必须为工厂合约，所以工厂合约只会初始化一次

在配对合约当中，为什么要定义一个初始化函数来初始化token0和token1，而不在构造函数中作为入参继续初始化呢？这是因为在工厂合约当中，使用了**create2**来创建合约，这个方式限制了构造函数不能有参数

配对合约一共有三个mint(),burn(),swap(),分别对应添加流动性，移除流动性，兑换三种操作

在三个操作之前，合于还有_update()以及__mintFee()操作

---

##### update()

内部函数，仅合约内部可以调用

更新token价格累积值以及token储备量

**代码速览**：

```solidity
 function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

```

_update入参一共有4个，出参2个，对应的解释如下：

```solidity
function _update(
    uint balance0, // token0 的余额
    uint balance1, // token1 的余额
    uint112 _reserve0, // token0 的资金池库存数量
    uint112 _reserve1 // token1 的资金池库存数量
) private {
    ...
}
```

前两个为当前合约的token余额，后两个为两个token 的储备量，两个参数可以计算对应token 的可用余额。_update()对资金池的记录库存和实际余额进行匹配，保证库存和余额统一，具体实现如下：

```solidity
function _update(uint balance0,uint balance1,uint112 _reserve0,uint112 _reserve1)private {
       // 需要 balance0 和 blanace1 不超过 uint112 的上限
        require(balance0 <=uint112(-1) && balance1 <= uint112(-1), "UniswapV2:OVERFLOW" );
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);//只取后32位
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        if(timeElapsed > 0 && _reserve0!=0 && _reserve1 != 0){
            //记录价格累计值 两个价格用来计算swap
            // 对 _reserve1 / _reserve0 * timeElapsed 的结果在 price0CumulativeLast 上累加
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            // 对 _reserve0 / _reserve1 * timeElapsed 的结果在 price1CumulativeLast 上累加
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;

        }// reserve0 = balance0 ， reserve0 = balance0
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);

        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);// reserve0 = balance0
    }
```



---

##### _mintFee()

内部函数，仅合约内部可以调用

代码速览：

```solidity
  function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }
```

函数_mintFee的入参有2个，出参有1个，对应的解释如下：

```solidity
function _mintFee(
    uint112 _reserve0, // token0 的资金池库存数量
    uint112 _reserve1 // token1 的资金池库存数量
) private returns (
    bool feeOn // 是否开启手续费
) {
    ...
}
```

_mintFee()实现了添加和移除流动性的同时，向feeTo地址发送手续费的逻辑，具体实现如下：

```solidity
function _mintFee(uint112 _reserve0,uint112 _reserve1 )private  returns (bool feeOn){
        //获取手续费接收地址feeTo
        address feeTo = IUniswapV2Factory(factory).feeTo();
        //如果feeTo不是0地址，feeOn = true
        feeOn = feeTo != address(0);
        uint _kLast = kLast;
        if(feeOn){
            if(_kLast != 0){
                
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                     if(rootK > rootKLast){
                         uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                         //计算交易手续费的分子
                         uint denominator = rootK.mul(5).add(rootKLast);
                         //计算交易手续费的分母
                         uint liquidity = numerator / denominator;
                         if(liquidity > 0)  _mint(feeTo, liquidity);

                     }          
            }
        }else  if(_kLast != 0 ){
            kLast = 0;
        }

    }
```

注意：在_mintFee()当中实现了向feeTo地址发送手续费，但是截至到目前，feeTo地址全是0地址，也就是说没有收取任何手续费。

为什么计算liquidity中用的是(rootK - rootKLast)/(5倍rootK + 1倍rootKLast)

而不是(rootK - rootKLast)/6倍rootKLast 

为了得到新增财富的 1/6, 需要增发的 lp 应该满足:
lp/lp_supply = (∆/6) / [(∆*5/6) + rootKLast ], 这里 ∆ = rootK - rootKLast
解出 lp = lp_supply \* ∆ / (5*rootK + rootKLast),证实了 Uniswap 收取的协议手续费就是总手续费的1/6。

---

##### mint()

外部函数，仅合约外部可以调用

代码速览：

```solidity
 function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }
```

函数mint()的入参有1个，出参有1个，对应的解释如下：

```solidity
function mint(
    address to // LP 接收地址
) external lock returns (
    uint liquidity // LP 数量
) {
    ...
}
```

函数mint()的作用是用户存入流动性代币，提取LP。为什么参数里面没有两个代币投入的数量呢？其实，调用函数之前，periphery（周边合约）里的路由合约已经完成了将用户的代币数量划转到给该配对合约的操作。在如下的几行代码操作,通过获取两个代币的当前余额**balance0**和**balance1**，再分别减去**_reserve0**和**_reserve1**,即池子里两个代币原有的数量，就计算出了两个代币的投入数量**amount0**和**amount1**。

```
{
...
		(uint112 _reserve0,uint112 _reserve1,) = getReserves();
		uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);
...
}
```

在后面的代码中计算流动性**liquidity**，计算公式为

当_totalSupply==0

```
liquidity = √(amount0*amount1) - MINIMUM_LIQUIDITY
```

当_totalSupply!=0，取更小的值作为流动性

```
liquidity1 = amount0 * totalSupply / reserve0
liquidity2 = amount1 * totalSupply / reserve1
```

计算出用户流动性之后，就会调用**_mint**()函数铸造出**liquidity**数量的**LPToken**并发送给用户，并调用_update()函数更新相关的值。最后触发Mint事件，具体实现如下：

```solidity
function mint(address to ) external  lock returns (uint liquidity){
        (uint112 _reserve0,uint112 _reserve1,) = getReserves();//获取两个token的的储备量
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));//当前合约两个token余额
        uint amount0 = balance0.sub(_reserve0);//获取用户的质押余额
        uint amount1 = balance1.sub(_reserve1);//合约中两个token的可用余额，及未被锁定的资产数量
        //调用_mintFee(),发送手续费
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply;
        if(_totalSupply == 0 ){
            //如果_totalSupply为0，LP 代币数量 liquidity = ✔(amount0 * amount1) - MINIMUM_LIQUIDITY
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
```

---

##### burn()

外部函数，仅合约内部可以调用

代码速览：

```solidity
function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }
```

burn()的入参有1个，出参有2个，对应的解释如下：

```solidity
function burn(
    address to // 资产接收地址
) external lock returns (
    uint amount0, // 获得的 token0 数量
    uint amount1 // 获得的 token1 数量
) {
    ...
}
```

函数**burn()**的作用是用户销毁LP，从资金池中提取流动性代币。在函数中有如下代码。正常情况下，配对合约里是不会有流动性代币的，因为所有的流动性代币都是给到了流动性提供者的。而这里有值，是因为路由合约会先把用户的流动性划转到该配对合约里

```solidity
 uint liquidity = balanceOf[address(this)];
```

接着就是计算可以提取的代币数量了，计算公式如下：

```
amount = liquidity / totalSupply * balance
提取数量 = 用户流动性 / 总流动性 * 代币总余额
```

后面的逻辑便是**_burn()**销毁流动性代币，将两个代币资产计算所得的数量划转给用户，然后更新两个代币的reserve

---

##### swap()

外部函数，仅合约外部可以调用

代码速览：

```solidity
function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }
```

函数**swap()**的入参有4个，出参有0个，对应的解释如下：

```solidity
function swap(
    uint amount0Out, // 预期获得的 token0 数量
    uint amount1Out, // 预期获得的 token1 数量
    address to, // 资产接收地址
    bytes calldata data // 闪电贷调用数据
) external lock {
    ...
}
```

该函数swap的功能是执行代币交换，并支持闪电贷的功能，***amount0Out*** 和 ***amount1Out*** 表示兑换结果要转出的 token0 和 token1 的数量，这里个值通常是一个为0，一个不为0，但使用闪电贷时可能两个都不为0，to参数是接收者地址，最后的data是执行回调时的传递数据，通过路由合约兑换的话，该值为0

```solidity
        require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');
```

校验相关数值，第一步先校验兑换结果是否有一个大于0，然后读取两个代币的reserve，之后在校验兑换数量是否小于reserve。

```solidity
 { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
```

以上代码块中，运用{}为了限制_token{0,1}这两个临时变量的作用域，防止堆栈太深导致错误，这个代码实现了将代币划转到接收者地址，如果data大于0，则将to地址转为 *IUniswapV2Callee* 并调用其 *uniswapV2Call()* 函数，这其实就是一个回调函数，*to* 地址需要实现该接口。接着获取两个token的余额，这个余额时扣减出代币之后的余额。

```solidity
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
```

以上代码块中，计算实际转入的代币数量，实际转入的代币数量通常也是一个为0一个不为0.

之后的代码是继续扣减手续费之后的恒定乘积校验，公式成立则说明这个底层的兑换之前的确已经收过交易手续费了

函数具体实现如下：

```solidity
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
//在不做swap之前，balance应该和reserve相等的。通过balance和reserve的差值，可以反推出输入的代币数量：
        uint amount0In = balance0 > _reserve0-amount0Out ? balance0 - (_reserve0-amount0Out) : 0;
        uint amount1In = balance1 > _reserve1-amount1Out ? balance1 - (_reserve1-amount1Out) : 0;

        require(amount0In > 0 || amount1In > 0 ," inputAmount not enough!!!");
        {
            uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
            uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
            require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(reserve1));
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

```



---

### UniswapV2ERC20.sol

LP Token则是用户网资金池注入流动性的一种凭证，也称为流动性代币，相当于是在tokenA、tokenB的基础上铸造了tokenC。当用户往某个币对的配对合约里转入两种币，即添加流动性，就可以的得到配对合约返回的LP Token，享受手续费分成收益

### UniswapV2Factory.sol工厂合约·

