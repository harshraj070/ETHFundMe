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
        if (addressToAmountFunded[msg.sender] == 0) {
            funders.push(msg.sender);
        }
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner whenNotPaused {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        delete funders;
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    function setPause(bool _pause) public onlyOwner {
        isPaused = _pause;
    }

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
        delete funders;
    }

    function refundFunder(address funder) public onlyOwner {
        uint256 amount = addressToAmountFunded[funder];
        require(amount > 0, "No funds to refund");

        addressToAmountFunded[funder] = 0;
        (bool success, ) = payable(funder).call{value: amount}("");
        require(success, "Refund failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
