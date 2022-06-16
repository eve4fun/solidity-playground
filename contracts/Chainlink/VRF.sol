// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
    Chainlink VRF (Verifiable Random Function)
*/
contract ChainlinkVRFPlayground is Ownable, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface internal vrfCoordinator;
    address vrfCoordinatorAddress;
    bytes32 gweiKeyHash; // The gas lane to use, which specifies the maximum gas price to bump to.
    uint16 requestConfirmations;
    uint64 subscriptionId;
    uint32 callbackGasLimitPerWord = 50000; // Storing each word costs about 20,000 gas
    uint256[] public s_randomWords;

    event RandomWordsGenerated(uint256 indexed requestId, uint256[] randomWords);

    constructor(
        address _vrfCoordinatorAddress,
        bytes32 _gweiKeyHash,
        uint16 _requestConfirmations,
        uint64 _subscriptionId
    ) VRFConsumerBaseV2(_vrfCoordinatorAddress) {
        vrfCoordinatorAddress = _vrfCoordinatorAddress;
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddress);
        gweiKeyHash = _gweiKeyHash;
        requestConfirmations = _requestConfirmations;
        subscriptionId = _subscriptionId;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords(uint32 numWords) external onlyOwner {
        // Will revert if subscription is not set and funded.
        vrfCoordinator.requestRandomWords(
            gweiKeyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimitPerWord * numWords,
            numWords
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        for (uint8 i = 0; i < randomWords.length; i++) {
            s_randomWords.push(randomWords[i]);
        }
        emit RandomWordsGenerated(requestId, randomWords);
    }
}
