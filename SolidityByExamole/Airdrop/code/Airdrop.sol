// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";


contract Airdrop{
    mapping (address => uint) failTransferList;
    //向多个地址转账ERC20代币
    function multiTransferToken(
        address _token,
        address[]calldata _address,
        uint256[]calldata _amounts
    )external  {
        require(_address.length==_amounts.length,"length not conrect");// 检查：_addresses和_amounts数组的长度相等
        IERC20 token = IERC20(_token);
        uint _amountSum = getSum(_amounts);  //
        require(
            token.allowance(msg.sender, address(this))> _amountSum,
            "need approve erc20 token"
        );
        for(uint i =0;i<_address.length;i++){
            token.transferFrom(msg.sender, _address[i],_amounts[i]);
        }
    }
    /// 向多个地址转账ETH
    function multiTransferETH(
        address payable []calldata _address,
        uint[]calldata _amounts
    )public  payable {
        require(_address.length == _amounts.length,"lentgh not equal");
        uint _amountsSum = getSum(_amounts);
        require(msg.value == _amountsSum,"transfer amount error");
        for(uint i =0;i<_address.length;i++){
            (bool success,) = _address[i].call{value:_amounts[i]}("");
            if(!success){
                failTransferList[_address[i]] = _amounts[i];
            }
        }
    }
    // 给空投失败提供主动操作机会
    function withdrawFromFailList(address _to)public {
        uint failAmount = failTransferList[msg.sender];
        require(failAmount > 0,"you are not in failed list");
        failTransferList[msg.sender]=0;
        (bool success , ) = _to.call{value:failAmount}("");
        require(!success,"call eth failed");
    }



    function getSum(uint256[]calldata amounts)public pure returns (uint sum){
            for(uint i=0;i<amounts.length;i++){
                sum +=amounts[i];
            }
    }
}



// ERC20代币合约
contract ERC20 is IERC20 {
    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply; // 代币总供给

    string public name; // 名称
    string public symbol; // 符号

    uint8 public decimals = 18; // 小数位数

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // @dev 实现`transfer`函数，代币转账逻辑
    function transfer(
        address recipient,
        uint amount
    ) external override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // @dev 实现 `approve` 函数, 代币授权逻辑
    function approve(
        address spender,
        uint amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // @dev 实现`transferFrom`函数，代币授权转账逻辑
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // @dev 铸造代币，从 `0` 地址转账给 调用者地址
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // @dev 销毁代币，从 调用者地址 转账给  `0` 地址
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
