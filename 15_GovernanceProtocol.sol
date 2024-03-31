//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GovernanceProtocol {
    address public owner;
    uint256 public proposalCount = 0;

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votesInFavor;
        uint256 votesAgainst;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public hasVoted;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    event ProposalSubmitted(uint256 indexed id, address indexed proposer, string description);
    event VoteCast(uint256 proposalId, address indexed voter, bool inFavor);
    event ProposalExecuted(uint256 indexed proposalId);

    function submitProposal(string memory _description) external {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            proposar: msg.sender,
            description: _description,
            votesInFavor: 0,
            votesAgainst: 0,
            executed: false
        });
        emit ProposalSubmitted(proposalCount, msg.sender, _description);
    }

    function castVote(uint256 _proposalId, bool _inFavor) external {
        require(proposals[_proposalId].id > 0, "Proposal does not exist");
        require(!hasVoted[msg.sender], "You have already voted on this proposal");

        if(_inFavor) {
            proposals[_proposalId].votesInFavor++;
        } else {
            proposals[_proposalId].votesAgainst++;
        }
        hasVoted[msg.sender] = true;
        emit VoteCast(_proposalId, msg.sender, _inFavor);
    }

    function executeProposal(uint256 _proposalId) external onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.id > 0, "Proposal does not exist");
        require(!proposal.executed, "Proposal has already been executed");

        uint256 totalVotes = proposal.votesInFavor + proposal.votesAgainst;
        require(totalVotes > 0, "No votes have been cast for this proposal");

        uint256 quorum = totalVotes / 2;
        if(proposal.votesInFavor > quorum) {
            //execute the proposal here
            proposal.executed = true;
            emit ProposalExecuted(_proposalId);
        }
    }
}