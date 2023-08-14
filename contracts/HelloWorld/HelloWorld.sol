// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HelloWorld is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    address public addressToStore;

    event Message(address indexed sender, string msg);
    
    receive() external payable {}

    function testSomething(address _addressToStore) external nonReentrant returns (address) {
        addressToStore = _addressToStore;
        return _addressToStore;
    }

    function testRevert() external nonReentrant {
        revert("HelloWorld:testRevert: should XXXXXXX some reason for explain");
    }

    function saveMessage(string memory msg) external nonReentrant {
        emit Message(msg.sender, msg);
    }
}
