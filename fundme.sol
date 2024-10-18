// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;
    
    uint256 public minimumUSD = 5e18; // Minimum of 5 USD in wei
    address[] public funders;

    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        // Using the library to convert ETH to USD
        require(msg.value.getConversionRate() >= minimumUSD, "Didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }
}
