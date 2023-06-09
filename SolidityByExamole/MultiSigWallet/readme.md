# 多签钱包-MultiSigWallet

## 什么是多签钱包？

多签钱包常被缩写成"MultiSig wallet"，与多签钱包相对应的是单签钱包（如metamask），当我们要在区块链上发送一笔转账交易，需要用钱包去做一个签名，当签好名把交易发出去，交易再进行执行成功转账，一次完整的交易便成功了。这就是典型的单签钱包，也是我们平时使用最多的钱包，通常成为外部账户（EOA）。这些账户使用私钥进行保护，私钥可以转换为用户12个单词的“助记词”。如果该私钥以任何方式被泄露，则钱包里的资金则可能会被盗。

使用多签钱包，顾名思义，就是需要多个人去签名某个操作的钱包，使用多签钱包可以进行转账，往往需要>=1个人签名交易，转账操作才能完成。使用多签钱包时，我们可以指定m/n个签名模式，就是n个人里面要有m个人签名即可完成操作。

## 多签钱包应用场景

#### 1.资金安全

资金的安全也可理解为私钥的安全，有一些常见的方案如使用硬件钱包来防止私钥泄露，使用助记词密盒来防止私钥遗忘等等，但依然存在“单点故障”的问题。在单签钱包中，加密资产的所有权在单人手中，一旦私钥泄露或者遗忘那便失去了对钱包的掌控，而多签钱包的存在，在很大程度上降低了资产损失的风险，以2/3多签模式为例，只要有2个私钥完成签名授权就能完成加密资产的转移

### 2.资金共管

很多Defi协议和DAO组织其实都有自己的金库，但是金库的资产又不能由一个理事掌管，所以每次动用都要经过多数人的同意或者社区投票。这时使用多签钱包来保存金库是再合适不过的了。

### 3.多签操作

在目前这个web3发展阶段，很多去中心化协议其实都是有个管理员权限的，这个管理员权限往往可以更改协议的某些关键参数。行业普遍做法是把这个管理员权限交给一个多签钱包或者时间锁，当需要更改参数时，需要多个人共同签署相关操作

## 代码实现

### 数据结构

```solidity
event Depozit(address indexed sender,uint amount,uint balance);
    
    event SubmitTransaction(
        address indexed from,
        uint indexed txindex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner,uint indexed txIndex);//
    event RevokeConfirmation(address indexed owner,uint indexed txIndex);//
    event ExecuteTransaciton(address indexed owner,uint indexed txIndex);//

    address[]public owners;
    mapping (address => bool) public isOwner;
    uint public numConfirmationsRequired;
//定义交易结构体
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }
    mapping (uint => mapping (address => bool))public isConfirmed;
    Transaction [ ]public transactions;
```

在数据结构中，分别定义了SubmitTransaction、ConfirmTransaction、RevokeConfirmation、ExecuteTransaciton四个事件，在交易创建，确认交易、撤销确认、执行交易时触发，同时，owners地址数组中存储了签名所有者的地址，并在isOwner中记录了地址是否为所有者的映射，numConfirmationsRequired定义有多少人签名确认即可完成多签，在代码中，定义了交易结构体中需要的参数，executed记录交易是否执行，numConfirmations记录了此次交易确定的数量。

### modifier

```solidity
 //仅允许所有者调用
    modifier onlyOwner(){
        require(isOwner[msg.sender],"not owner!");
        _;
    }
    //确保交易存在
    modifier txExists(uint _txIndex){
        require(_txIndex < transactions.length,"tx not exist!");
        _;
    }
    //确保交易尚未执行
    modifier notExecuted(uint _txIndex){
        require(!transactions[_txIndex].executed , "tx already excuted");
        _;
    }
    //确保交易未被确认
    modifier notConfirmations(uint _txIndex){
        require(!isConfirmed[_txIndex][msg.sender],"tx already confirm1");
        _;
    }
```

### 合约实例化

```solidity
//接收所有者数组和所需确认数作为参数
    constructor(address[]memory _owners,uint  _numConfirmationsRequired)payable {
        require(_owners.length > 0,"owner required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
                "invalid numer of required confirmation"
        );
        //初始化交易owner列表并设置isOwner映射
        for(uint i =0;i < _owners.length;i++){
            address owner = _owners[i];
            require(owner!=address(0),"invalid owner");
            require(!isOwner[owner],"owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        emit Depozit(msg.sender, msg.value, address(0).balance);
    }
```

### 方法

#### 1.创建交易

```solidity
function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    )public onlyOwner{
        uint txIndex = transactions.length;
        transactions.push(
            Transaction(
                {
                    to :_to,
                    value : _value,
                    data : _data ,
                    executed:false,
                    numConfirmations:0
                }
            )
        );
        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);

    }
```

在submiTransaction中，在将交易提交到交易数组之前，

```solidity
uint txIndex = transactions.length;
```

此时交易的txIndex即为其在数组中的序列。完成交易推送后，emit确认交易事件

#### 2.确认交易

```solidity
function confirmTransaction(
        uint _txIndex
    )public onlyOwner txExists(_txIndex) notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations +=1 ;//增加交易确认数
        isConfirmed[_txIndex][msg.sender] = true;
        
        emit ConfirmTransaction(msg.sender, _txIndex);
    }
```

此方法为多签钱包核心，即调用交易的EOA确认这笔交易，并交易确认数++

，同时更改相关交易状态。

#### 3.执行交易

```solidity
function executeTransaciton(uint _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );
        transaction.executed = true;
        (bool success,) = transaction.to.call{value:transaction.value}(transaction.data);
        require(success,"failed to tx");

        emit ExecuteTransaciton(msg.sender,_txIndex);
    }
```

当验证交易确认数合格之后，此次交易便被执行

#### 4.撤销交易

```solidity
function revokeConfirmation(uint _txIndex
    )public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaciton = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender],"tx not confirm");
        transaciton.numConfirmations-=1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }
```

如果EOA想要撤销确认的交易，需见检查交易的基本信息，验证是否被确认以及执行

#### 5.其他查询方法

```solidity
function getOwners() public  view   returns(address [] memory){
        return owners;
    }

    function getTransationCount() public view returns (uint){
        return transactions.length;
    }
    function getTransation(uint _txIndex)
     public view returns (
         address to,
         uint value,
         bytes memory data ,
         bool executed,
         uint numConfirmations
     ){
         Transaction storage transaction = transactions[_txIndex];
         return (
             transaction.to,
             transaction.value,
             transaction.data,
             transaction.executed,
             transaction.numConfirmations         );
     }
```

## 业务流程

地址数组以以下三个地址为例，交易确认数设定为2

```
["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
```

![image-20230609150855731](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609150855731.png)

![image-20230609151221450](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609151221450.png)

创建交易给第四个地址转账

![image-20230609151405733](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609151405733.png)

![image-20230609151420943](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609151420943.png)

此时查询并验证一次执行交易

![image-20230609151458075](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609151458075.png)

![image-20230609151647657](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609151647657.png)

进行签名流程，使用第一个账户进行签名

![image-20230609151820602](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609151820602.png)

再次执行交易

![image-20230609151856245](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609151856245.png)

此时切换到第一个账户进行签名

![image-20230609151924527](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609151924527.png)

![image-20230609151948065](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609151948065.png)

验证执行交易

![image-20230609152149132](D:\workPlace\study\solidity\SolidityExample\SolidityByExamole\MultiSigWallet\img\image-20230609152149132.png)

一次简单的交易便完成