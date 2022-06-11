// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ByeWorld is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    address public addressToStore;

    constructor(address _addressToStore) {
        addressToStore = _addressToStore;
    }

    receive() external payable {}
}
