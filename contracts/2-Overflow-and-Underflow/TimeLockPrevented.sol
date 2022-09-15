// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

/*
    OverFlow / Underflow
*/

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/math/SafeMath.sol';

contract TimeLockPrevented {
    using SafeMath for uint; // myUint.add(123);

    mapping(address => uint256) public balances;
    mapping(address => uint256) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = now + 1 weeks;
    }

    function increaseLockTime(uint256 _secondsToIncrease) public {
        // add takes care of uint overflow
        lockTime[msg.sender] = lockTime[msg.sender].add(_secondsToIncrease);
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(now > lockTime[msg.sender], "Lock time not expired");

        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    TimeLockPrevented timeLock;

    constructor(TimeLockPrevented _timeLock) public {
        timeLock = TimeLockPrevented(_timeLock);
    }

    fallback() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        // t == current lock time
        // find x such that
        // x + t = 2**256 = 0
        // x = -t
        timeLock.increaseLockTime(
            // 2**256 - t
            uint(-timeLock.lockTime(address(this)))
        );
        timeLock.withdraw(); 
    }
}