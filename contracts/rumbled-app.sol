// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// Interface para o contrato do token (padrão BEP-20)
interface IBEP20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

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
}