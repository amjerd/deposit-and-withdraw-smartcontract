# deposit and withdraw contract

**License:** GPL-3.0-or-later  
**Solidity Version:** >=0.4.22 <0.9.0  

---

## Description

This project contains a simple Ethereum smart contract.  
The contract allows users to deposit and withdraw Ether securely, while preventing reentrancy attacks using a basic lock mechanism.

---

## Features

- Deposit Ether into the contract
- Withdraw Ether from the contract
- Check your current deposited balance
- Protected from reentrancy using a `nonReentrancy` modifier

---

## Contract Code

```solidity
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.22 <0.9.0;

interface Ibank {
    function deposit(uint256 amount) external payable;
    function withdraw(uint256 amount) external;
    function checkBalance() external view returns (uint256);
}

contract bank is Ibank {
    bool public isLocked;
    mapping(address => uint256) public balance;

//custom nonreentrancy 
    modifier nonReentrancy() {
        require(!isLocked, "unauthorized");
        isLocked = true;
        _;
        isLocked = false;
    }

    function deposit(uint256 amount) external payable override {
        require(msg.value == amount, "insufficient balance");
        require(amount > 0, "the balance must be greater than zero");
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external nonReentrancy override {
        require(balance[msg.sender] >= amount, "insufficient balance");
        balance[msg.sender] -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function checkBalance() external view override returns (uint256) {
        return balance[msg.sender];
    }
}
