// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUSD = 5e18;
    address[] public funders;
    address public owner;
    bool public isPaused = false;

    mapping(address => uint256) public addressToAmountFunded;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable whenNotPaused {
        require(msg.value.getConversionRate() >= minimumUSD, "Didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner whenNotPaused {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
        funders = new address Reset funders array
    }


    function setPause(bool _pause) public onlyOwner {
        isPaused = _pause;
    }

    // Allow the owner to change the minimum USD value
    function setMinimumUSD(uint256 _newMinUSD) public onlyOwner {
        minimumUSD = _newMinUSD;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function resetFunding() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address ;

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
