// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract HeadOrTailGame {
    address public owner;


    event GameHistory(address indexed palyer, uint256 gamblingAmount, bool win);


    constructor() {
        owner = msg.sender;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function play(bool guess) external payable {
        require(address(this).balance >= 2 * msg.value, "Pool Not Enough Balance");
        bool result = getRandomNumber() % 2 > 0? true : false;
        bool win = guess == result;
        if (win) {
            (bool sent, ) = payable(msg.sender).call{value: msg.value * 2}("");
            require(sent, "Failed to send Ether");
        }
        emit GameHistory(msg.sender, msg.value, win);
    }

    modifier onlyowner() {
      require(msg.sender == owner);
      _;
    }
}