# create和create2

在以太坊虚拟机中，交易的执行靠读取操作码进行，而操作码create和create2都用来生成合约地址

## create

create（v,p,n）

v:以Wei为单位发生的ether，发送给创建的合约

p,n：创建合约的字节码的开始和结束内存地址

create部署的合约地址计算公式：

```
keccak256(rabi.encode(address,nonce))[12:]
```

address是deploying address

在以太坊网络中，每个账户有一个与之关联的nonce：对外部账户而言，每发送一个交易，nonce就会随之+1；对合约账户而言，每创建一个合约，nonce就会+1；

用create创建一个合约

```
contract create{
    //create contracts by new
    uint x;
    constructor(uint a)payable  {
        x= a;
    }
    function D(uint _x)payable public  {
        x=_x;
    }
}
contract testCreate{
    create d = new create(4);
    address public  _address =address(d);
    function createD(uint args)public {
        create newD = new create(args);

    }
    function createWithTransfer(uint args,uint amount)public payable {
        create newD =(new create){value:amount}(args);
    }
}
```

当Token d = new Token()时，操作码output就是create

## create2

create2(v,p,n,s)

v:以Wei为单位发生的ether，发送给创建的合约

p,n：创建合约的字节码的开始和结束内存地址

s:salt,随机数

create2部署的合约地址计算公式：

```
keccak256(0xff,address(this),salt,type(xx).creationCode)
```

salt的存在使得create2创建的合约能够被预测

```
address predicted = address(uint160(uint(keccak256(abi.encodePacked(
        bytes1(0xff),
        address(this),
        salt,
        keccak256(abi.encodePacked(type(create2).creationCode,abi.encode(args)))   
       )))));
```

