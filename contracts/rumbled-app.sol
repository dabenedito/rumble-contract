// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

struct Challange {
    address payable challenging;
    address payable demanding;
    address payable judge;
    uint256 bet;
}

contract RumbledApp {
    address owener;
    address token;
    Challange[] challanges;
    mapping (address => uint256) public bets;
    
    constructor() {
        owener = msg.sender;
    }

    function getChallanges() public view returns (Challange[] memory) {
        return challanges;
    }

    function createChallange(uint256 bet) public payable {
        require(msg.value >= bet, "Out of balance");
        uint256 _bet = uint256(bet);

        Challange memory newChallange;
        newChallange.challenging = payable(msg.sender);
        newChallange.bet = uint256(_bet);

        bets[payable(msg.sender)] = uint256(msg.value);
        challanges.push(newChallange);
    }

    function calc(uint256 weiValue) public pure returns(uint256) {
    
        return weiValue / 1e18;
    }
}