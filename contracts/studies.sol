// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Studies {
    address owner;
    uint public balance;
    
    constructor() {
        owner = msg.sender;
    }

    function sendMeMoney() public payable returns(uint) {
        address payable _contract = payable(address(this));

        return _contract.balance;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}