### 一、合约调用

在了解合约升级的使用之前，我们先弄明白合约升级的原理。作为`Solidity`语言中的地址类型的成员变量函数，合约之间的底层调用我们通常使用`call`和`delegatecall`，两个函数均使用函数选择器+`abi`编码数据作为参数来调用对应的函数：

- 函数选择器：函数调用字节码(`input`)的前四个字节，相当于的合约函数接口标识，通过目标函数的名称加上其参数类型进行哈希(`Keccak-256`)计算,取前4个字节作为函数选择器，例如`bytes4(keccak256("hello(uint256)"))`

- `abi`编码数据：即发送目标函数调用的参数编码，将每个参数转换为32字节（256位）的定长数据（固定长度的数据类型，如`uint256`、`address`），如果是动态大小的数据类型，如`string`、数组等,则编码数据首先是数据的偏移量（动态数据的实际内容相对于其在编码数据中起始位置的距离，简单来说就是动态数据在编码数据的具体位置），然后是数据的长度和实际内容。我们写个示例演示一下：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SelectorAndabiData {

    function hello(string memory data)public pure  returns (bytes memory){
        return msg.data;
    }

    function getSelectorBySelector()public  pure returns (bytes4){
        return  this.hello.selector;
    }

    function getSelectorByKeccak()public  pure  returns (bytes4){
        return bytes4(keccak256("hello(string)"));
    }
    function getAbiData(string memory data)public  pure  returns (bytes memory){
        return abi.encodeWithSelector(bytes4(keccak256("hello(string)")), data);
    }

}
```

这里我们模拟需要获取`hello()`函数的相应函数选择器和传入参数编码

首先验证两个`getSelectorBySelector()`和`getSelectorByKeccak`()验证函数选择器编码，这里我们使用了两种方式进行计算验证，第一种是直接调用solidity的底层函数`selector`获取函数选择器，第二种是采用哈希计算获取。

![image-20240830101725933](.\img\image-20240830101725933-1725010797757-18.png)

接下来我们验证函数选择器+数据编码是否一致：这里我们同样采用两种方式进行验证，第一种是获取当调用`hello()`函数时的`msg.data`,我们可以理解为调用该函数的完整的`calldata`数据；第二种是采用`abi.encodeWithSelector`的形式计算获取。

![image-20240830102539099](.\img\image-20240830102539099-1725010244471-3.png)

可以看到两种形式均验证通过，我们简单分析一下这个`msg.data`

```solidity
0xa777d0dc//4个字节，hello的函数选择器
0000000000000000000000000000000000000000000000000000000000000020//string为动态数据，第一个为数据的偏移量
0000000000000000000000000000000000000000000000000000000000000005//数据长度 `hello`-5个字符
68656c6c6f000000000000000000000000000000000000000000000000000000//数据的编码
```

### 二、call和delegatecall

简单介绍完函数调用的原理，接下来回归主线。那么`call`和`delegatecall`是如何进行合约之间函数底层调用的呢？

二者的使用规范类似

- `address.call(bytes memory abiData) returns (bool, bytes memory)`
- `address.delegatecall(bytes memory abiData) returns (bool, bytes memory)`

两个底层调用方式均返回元组数据，执行状态码`bool`以及返回数据`bytes memory`,由于是合约的低级函数，状态码的存在则意味着这两个函数的调用只会提示成功与否，其不会检查被调用函数是否存在，也不关心函数的签名，不强制返回值类型。

在智能合约当中，`revert()`这个大家应该都很熟悉，回滚(`revert()`)指的是在发生异常和错误时候，事务被取消，所有的状态更改都被撤销。而与直接函数调用不同的是，`call` 和 `delegatecall`和函数的直接调用有所不同：

- 不会自动回滚：
  - 当合约使用`call`和`delegatecall`调用另一个合约时候，如果目标合约的函数内部发生异常(触发 `revert`、`assert` 或 `require`),调用方合约**不会自动回滚**
  - `call`和`delegatecall`的返回值为`bool`,指明调用是否成功。如果调用方合约忽略了返回状态码，并且不处理失败的情况，那么即使目标合约回滚了，调用方合约也会继续**向下执行**，状态不会回滚。这是合约开发的大忌，切记明确检查低级调用的状态执行情况，**谨慎使用低级调用**。

上图,让我们了解一下这两个底层调用到底有什么区别

![image-20240830140624412](.\img\image-20240830140624412-1724997986371-3-1725010244470-2.png)

- **调用上下文**：
  - 通过图片可以了解到，`call`调用合约时，调用在被执行的合约上下文执行，这就意味着被调用合约的存储、`msg.sender` 和 `msg.value` 都是以被调用合约的为准。比如上图的外部账户`EOA`调用合约A，合约A中使用`call`调用合约B，那么B中的代码将会B的存储数据为基础执行；
  - 与`call`不同，`delegatecall`在调用者合约的上下文执行，这就意味着被调用合约的代码实际上在调用合约的存储和上下文运行。
- **状态作用域：**
  - 被调用合约的状态变量在`call`中被直接访问和修改，任何在目标合约中状态变量的更改只会影响目标合约本身的存储，而不会影响调用合约；
  - 使用`delegatecall`时，被调用合约的代码操作的是调用合约的状态变量。目标合约虽然被执行，但其存储并没有修改，作用的是调用合约的状态变量。

我们接下来上代码，`code is law`，让合约代码说话

```solidity
contract caller {
    string public  _caller;//调用者
    address  public  _address;//作用域地址
    address public  _msgSender;//msg.sender

    function call(address contractAddress) public  {
        contractAddress.call(abi.encodeWithSelector(bytes4(keccak256("caller()"))));
    }
    function delegatecall(address contractAddress) public  {
        contractAddress.delegatecall(abi.encodeWithSelector(bytes4(keccak256("caller()"))));
    }
}

contract called1{
    string public  _caller;
    address  public  _address;
    address public  _msgSender;
    function caller()public {
        _caller ="called1";
        _address = address(this);
        _msgSender = msg.sender;
    }
}

contract called2 {
    string public  _caller;
    address  public  _address;
    address public  _msgSender;
    function caller()public {
        _caller ="called2";
        _address = address(this);
        _msgSender = msg.sender;
    }
}
```

简单解释一下三个合约，三个合约存储状态一致，`call`合约作为调用者合约，合约内部分别有两个不同的底层调用方法。`called`合约作为被调用合约(目标合约)，合约内部有`caller()`方法来修改对应状态变量。

接下来我们分别部署三个合约：

![image-20240830143330180](.\img\image-20240830143025729-1725010244473-4.png)

```solidity
called1  0x9d83e140330758a8fFD07F8Bd73e86ebcA8a5692
called2  0xD4Fc541236927E2EAf8F27606bD7309C1Fc2cbee
caller 	 0x5FD6eB55D12E759a21C09eF703fe0CBa1DC9d88D
EOA 	 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
```

首先我们执行`call`调用，在`call`方法中填入`called1`合约地址，执行方法。

![image-20240830143442705](.\img\image-20240830143442705.png)

现在我们分别检查`caller`和`called1`的状态存储状态

![image-20240830143644392](.\img\image-20240830143644392.png)

可以看到，只有`called1`的状态完成了修改，并且作用域地址为当前`called1`合约地址，`msg,sender`为调用合约的地址

接下来我们来试一下`delegatecall`,在`delegatecall`方法中填写`called2`合约地址,执行方法。

![image-20240830144143796](.\img\image-20240830144143796-1725010244474-5.png)

让我们看看发生了什么

![image-20240830144327044](.\img\image-20240830144327044-1725010536647-8.png)

是的，只有`caller`合约的状态变量发生了变化，并且作用域地址为`caller`合约地址，`msg,sender`为`EOA`地址

这就是两个底层调用的主要区别，其中涉及到的`EVM`存储原理，二者的底层调用适用于不同的业务场景：`call`适用于调用外部合约的某个函数，发送以太币或者进行其他合约的交互，常用于简单的支付转账、多合约交互；而`delegatecall`常用于代理合约模式，这种模式可以用于实现合约的可升级性，通过更换被代理的合约来改变逻辑，而保持调用合约的存储和地址不变。切记切记，在使用底层调用时处理安全性校验。

### 三、合约可升级的代理模式

为什么需要合约升级代理，由于智能合约一旦部署在区块链上就难以修改，其不可篡改的特性虽保证了安全性，但也限制了修复漏洞、添加新功能或改进现有逻辑的灵活性。如果重新部署合约，其中的数据迁移和用户体验都会收到影响，可能导致用户资产的转移、操作复杂性增加，并且存在潜在的安全风险。但有了合约升级的引入，其实为合约开发提供了一种新的合约完善新思路，在不影响用户和资产的前提下，对合约进行优化和改进，从而提升合约的可维护性。

那么它究竟是如何实现合约的升级的呢？其实这引入了一种新的模式，我们称他为合约代理模式，设置合约代理架构，采取代理合约和用户交互，代理合约的逻辑实现交给我们的逻辑合约，这用到了我们上一节讲到的`delegatecall`底层调用，数据存储在代理合约，业务逻辑交给实现合约，由代理合约通过`delegatecall`调用来实现状态变量的更改

![image-20240830151656133](.\img\image-20240830151656133-1725010244475-6.png)

接下来我们简单看一个简单可升级的合约

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//简单可升级合约
contract Proxy {
    string public  _mark;//待修改状态

    address public  _implementation;//实现合约地址
	//示例化逻辑合约地址
    constructor(address implementation_) {
        _implementation = implementation_;
    }

    fallback() external payable {
        (bool success ,) =_implementation.delegatecall(msg.data);
        require(success,"call error");
     }

     receive() external payable { } 
	//修改逻辑合约地址--合约升级
     function upgrade(address implementation)public {
        _implementation = implementation;
     }


}

contract Logic1{
    string public  _mark;

    //0x28b5e32b 待调用函数
    function call()public {
        _mark = "Logic1";

    }
}
contract Logic2{
    string public  _mark;
	//函数升级
    function call()public {
        _mark = "Logic2";

    }
}
```

一般委托调用的通常放在`fallback`函数中，向合约发送数据时，找不到对应的函数签名，会默认调用`fallback()`函数,可以理解为`fallback`用于处理所有未匹配函数调用的默认函数。通过将`delegatecall`放在`fallback`函数中，可以捕获并处理所有这些未定义的函数调用，并将它们转发到目标逻辑合约。这允许代理合约灵活地处理不同版本的逻辑合约，而无需在代理合约中预先定义所有可能的函数。

在这个代理合约`Proxy`的`fallback`中，使用`delegatecall`调用实现合约`_implementation`的目标函数`call()`，来修改代理合约的`_mark`状态，

这里分别部署一次部署`Logic1`和`Logic2`合约，在`Proxy`构造函数中填写`Logic1`的合约地址

![image-20240830153038384](.\img\image-20240830153038384.png)

`Remix`提供了合约底层调用的方式，我们只需要编码`calldata`,这里我提前计算了`call()`的函数选择器为`0x28b5e32b`，由于目标函数没有传参，直接在代理合约采用底层调用形式输入函数选择器即可

![image-20240830153824516](.\img\image-20240830153824516-1725010244475-7.png)

可以看到，此时`_mark`修改为了`Logic1`，代表我们调用实现合约成功，状态存储完成修改，接下来我们将合约地址升级为`Logic2`的地址，

![image-20240830154126141](.\img\image-20240830154126141-1725010244475-8.png)

接下来继续执行`calldata`底层调用，来看看会发什么

![image-20240830154236751](.\img\image-20240830154236751-1725010244475-9-1725010491046-1.png)

是的，存储状态更改变成了`Logic2`的业务逻辑,恭喜你，完成了一次合约的升级

#### 透明代理

在透明代理模式中，只有合约管理员才有权限调用代理合约的管理功能，如升级逻辑合约。普通用户的调用会被直接转发到逻辑合约，而不会触发代理合约的管理逻辑，这样确保了代理合约对普通用户来说时”透明“的，其不会察觉到代理的存在，更像是在直接与逻辑合约交互。

我们来修改一下代理合约

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//透明代理

contract Proxy{
    string public  _mark;
    address public  _owner;
    address public  _implementation;

    constructor(address implementation_ , address owner_){
        _implementation = implementation_;
        _owner = owner_;
    }
    fallback() external payable {
        require(msg.sender != _owner);
        (bool success ,) =_implementation.delegatecall(msg.data);
        require(success,"call error");
     }
     receive() external payable { }

     function upgrade(address implementation) external {
        if (msg.sender != _owner) revert();

        _implementation = implementation;
     }
}


contract Logic1 {
    string public  _mark;

    //0x28b5e32b
    function call()public {
        _mark = "logic1";

    }
}

contract Logic2 {
    string public  _mark;

    address public  _implementation;

    function call()public {
        _mark = "logic2";

    }
}


```

这合约总共三个状态变量

- `_mark`：待修改状态
- `_owner`：合约管理员
- `_implementation`：实现合约地址

在这个合约当中实现了业务逻辑分离，管理员只能实现合约的升级，而用户只能调用逻辑合约的函数。有同学可以要问了，升级函数这个只能管理员来调用可以理解，为什么`fallback`里面也要限制管理员调用？这一切归结于“**函数选择器冲突**”，试想，有没有一种可能逻辑合约和代理合约有函数的选择器相同？如果管理员想要调用逻辑合约的函数，那么`fallback`该执行哪个合约的函数呢？这有可能导致管理员无意中将合约升级，有可能导致逻辑合约进入黑洞，这很可能会导致很严重的事故。

- 合约构造函数：完成管理员和逻辑合约的实例化
- `fallback()`：委托调用逻辑合约`call()`，修改`_mark`状态
- `upgrade()`：管理员升级合约地址

#### UUPS代理

`UUPS`这种模式其实是透明代理的一个变体，它通过减少代理合约中的代码量来提供一种更轻量级的升级方式，`UUPS`将升级合约的逻辑从代理合约迁移到了逻辑合约中，从而使代理合约更加简洁和高效。

**升级过程**：

- 当需要升级合约时，管理员或拥有升级权限的角色调用逻辑合约的`upgradeTo`函数。这个函数会更新代理合约中指向逻辑合约的地址，从而将代理合约的逻辑切换到新版本。

废话少说，上代码！

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//通用可升级代理
contract UUPSProxy {
    string public  _mark;
    address public  _implementation;
    address public  _admin;
    
    constructor(address implementation_){
        _implementation = implementation_;
        _admin = msg.sender;
    }
    fallback() external payable { 
        (bool success,) = _implementation.delegatecall(msg.data);
        require( success,"ERRO");
    }
    receive() external payable { }

    function getCalldata(address addr)external pure returns (bytes memory){
        return abi.encodeWithSelector(bytes4(keccak256("upgrade(address)")), addr);
    }
}

contract UUPSProxiable1 {
    string public  _mark;
    address public  _implementation;
    address public  _admin;
    constructor(){
        _admin   = msg.sender;
    }

    function upgrade(address newImplementation) external  {
        require(msg.sender == _admin,"");
        _implementation = newImplementation;
    }
    //0x28b5e32b
    function call()external {
        _mark = "UUPSProxiable1";
    }
}
contract UUPSProxiable2 {
    string public  _mark;
    address public  _implementation;
    address public  _admin;
    constructor(){
        _admin   = msg.sender;
    }

    function upgrade(address newImplementation) external  {
        require(msg.sender == _admin,"");
        _implementation = newImplementation;
    }

    function call()external {
        _mark = "UUPSProxiable2";
    }
}

```

在这个代理合约当中，数据存储结构不变，将合约升级的逻辑交给逻辑合约实现。对比透明代理可以看出，`UUPS`模式明显减少了合约的存储需求，节省了存储空间。同时，升级函数有逻辑合约实现，所以在进行合约升级逻辑处理时可以灵活的定义升级逻辑。和`UUPS`一致，防止恶意或错误的升级操作，升级函数只能管理员执行。

#### 信标代理

`UUPS`和透明代理都是一个代理合约来管理多个逻辑合约，有没有多个代理共同使用一个逻辑合约的情况呢？

信标代理就是这个代理模式，与传统的代理模式不同，它引入了一个“信标”（Beacon）合约来管理逻辑合约的地址。信标代理的主要目的是在同一个项目或应用中实现多个代理合约同时使用同一个逻辑合约的共享升级，而无需单独升级每个代理合约。

![image-20240830171025201](.\img\image-20240830171025201-1725010244476-10.png)

所有代理均从信标合约当中读取实现合约地址，当需要升级逻辑合约，只需要更新新报合约中存储的逻辑合约地址，所有引用该信标的代理合约自动指向新的逻辑合约。，这里简单给出合约代码示例

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//信标代理
contract Proxy {
    Beacon immutable _beacon;

    fallback() external payable { 
        address implementation = _beacon.implementation();
        implementation.delegatecall(msg.data);
    }
}

contract Beacon {
    address public  _implementation;

    function implementation()public  view returns (address){
        return _implementation;
    }
    function upgrade(address newImplementation) public {
        _implementation = newImplementation;
    }
}

contract Logic {

    function call()external {
        //TODO
    }
}
```

在`Proxy`代理合约当中，将信标合约设置为不可变量，在`fallback`函数中自动获取信标合约的逻辑合约地址，执行`delegatecall`调用。

**注意**：不管是哪一种代理模式，代理合约和逻辑合约都需要保持数据存储一致。



参考：

https://noxx.substack.com/p/evm-deep-dives-the-path-to-shadowy-a5f

[ OpenZeppelin/openzeppelin-contracts (github.com)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/proxy/Proxy.sol)

https://blog.openzeppelin.com/proxy-patterns/