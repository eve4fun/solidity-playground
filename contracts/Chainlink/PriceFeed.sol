// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceFeed {
    AggregatorV3Interface internal priceFeed;
    address priceFeedAddress;

    constructor(address _priceFeedAddress) {
        priceFeedAddress = _priceFeedAddress;
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int256) {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = priceFeed
            .latestRoundData();
        return answer;
    }

    function getHistoricalPrice(uint80 roundId) public view returns (int256) {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = priceFeed
            .getRoundData(roundId);
        require(updatedAt > 0, "Round not complete");
        return answer;
    }
}
