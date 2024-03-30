//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DelegatedVoting {

    struct Voter {
        bool hasVoted;
        address delegate;
        uint256 vote;
    }
    address public admin;
    uint256 public totalVotes;
    uint256 public proposal;

    mapping(address => Voter) public voters;

    constructor() {
        admin = msg.sender;
        proposal = 0;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        _;
    }

    function delegateVote(address to) external {
        require(to != msg.sender, "You cannot delegate your vote to yourself");
        require(!voters[msg.sender].hasVoted, "You have already voted");

        address delegateTo = to;
        while(voters[delegateTo].delegate != address(0)) {
            delegateTo = voters[delegateTo].delegate;
            require(delegateTo != msg.sender, "Delegation cycle detected");
        }
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].delegate = to;
        if(voters[to].hasVoted) {
            proposal += 1;
        }
    }

    function vote(uint256 option) external hasNotVoted {
        require(option == 0 || option == 1, "Invalid vote option");
        address delegateTo = voters[msg.sender].delegate;
        if(delegateTo != address(0)) {
            require(!voters[delegateTo].hasVoted, "Delegate has already voted");
            voters[msg.sender].hasVoted = true;
            voters[msg.sender].vote = option;
        } else {
            voters[msg.sender].hasVoted = true;
            voters[msg.sender].vote = option;
        }

        if(option == 1) {
            proposal += 1;
        }

        totalVotes += 1;
    }
}