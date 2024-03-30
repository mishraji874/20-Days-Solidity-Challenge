//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TimeLockedWallet {
    address public owner;
    uint256 public unlockTime;

    constructor(address _owner, uint256 _unlockTime) {
        owner = _owner;
        unlockTime = _unlockTime;
    }

    receive() external payable {
        require(msg.sender == owner, "Only the owner can deposit ether");
    }

    function withdraw() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(block.timestamp >= unlockTime, "Funds are locked until the unlock time");
        payable(owner).transfer(address(this).balance);
    }
}