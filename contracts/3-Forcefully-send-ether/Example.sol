// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
    Forcing Ether with sefldestruct
*/

contract Foo {
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Bar {
    function kill(address payable addr) public payable {
        // This will send ethers to the address
        // (regarless of whether the contract has payable fallback function or not)
        selfdestruct(addr); 
    }
}