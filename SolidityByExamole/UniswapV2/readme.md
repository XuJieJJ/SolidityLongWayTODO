# Uniswap-V2

Uniswap智能合约由两个GitHub项目组成 一个是core（核心合约）， 一个是periphery（周边合约）

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

Core核心合约由factory（UniswapV2Factory.sol）和交易对合约（UniswapV2Pair.sol）及接口和库合约组成

### 1.UniswapV2Factory.sol

