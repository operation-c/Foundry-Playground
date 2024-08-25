// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Wallet {
    address payable public owner;
    
    event Deposit(address indexed account, uint256 amount);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() payable {
        owner = payable(msg.sender);
    }

    receive() external payable {
        deposit();
        emit Deposit(msg.sender, msg.value);
    }

    fallback() external payable {}

    function withdraw(uint256 _amount) public {
        require(msg.sender == owner, "caller is not owner");
        payable(msg.sender).transfer(_amount);
    }

    function setOwner(address _owner) public {
        require(msg.sender == owner, "caller is not owner");
        owner = payable(_owner);
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

}
