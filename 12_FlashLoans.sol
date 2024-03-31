//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./03_ERC20Token.sol";

contract FlashLoanContract {
    address public owner;
    MyToken public dai;
    
    constructor(address _daiAddress) {
        owner = msg.sender;
        dai = MyToken(_daiAddress);
    }

    function flashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only the contract owner can initiate a flash loan");
        uint256 balanceBefore = dai.balanceOf(address(this));
        require(balanceBefore >= amount, "Not enough DAI in the contract");
        uint256 balanceAfter = dai.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan repayment failed");
    }
}