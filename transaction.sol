// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.22 <0.9.0;

interface Ibank {
    function deposit(uint256 amount) external payable ;
    function withdraw(uint256 amount) external ;
    function checkBalance()external view returns(uint256);
    
}

contract bank is Ibank{
    bool public isLocked;

    mapping (address => uint256)public balance;

    //custom reentrancy guard for safety of withdrawal
    modifier nonReentrancy(){
        require(!isLocked,"unauthorized");
        isLocked = true;
        _;
        isLocked = false;

    }


    function deposit(uint256 amount) external payable override {
        require(msg.value == amount,"insufficient balance");
        require(amount > 0,"the balance must be greater than zero");
        balance[msg.sender] += msg.value;
        

    }

     //no double withdraw since there is is nonReentrancy guard
    function withdraw(uint256 amount) external nonReentrancy override {
        require(balance[msg.sender] >= amount,"insufficient balance");
        balance[msg.sender] -= amount;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Failed to send Ether");

    }

    //view balance after or before withdrawal or deposit
    function checkBalance()external view override returns (uint256){
        return balance[msg.sender];
    }
   
}
