// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns (uint256) {
        // Instantiate the Chainlink Price Feed contract
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 price,,,) = priceFeed.latestRoundData();
        // Chainlink price has 8 decimals, scale it to 18 decimals by multiplying with 1e10
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        // Calculate the value in USD (ethPrice is in USD with 18 decimals)
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUSD;
    }
}