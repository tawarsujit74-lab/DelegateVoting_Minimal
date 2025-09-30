// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DelegateVoting - Ultra Minimal Version
 * @dev Absolute minimum viable voting system with delegation
 */
contract DelegateVoting {
    
    struct Proposal {
        string description;
        uint128 votesFor;
        uint128 votesAgainst;
        uint32 deadline;
        bool executed;
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(address => address) public delegates;
    mapping(address => uint64) public votingPower;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    
    uint256 public proposalCount;
    address public owner;
    
    event Voted(uint256 indexed proposalId, address indexed voter, bool support);
    event Delegated(address indexed from, address indexed to);
    
    constructor() {
        owner = msg.sender;
        votingPower[owner] = 100;
    }
    
    // Core Function 1: Delegate
    function delegate(address to) external {
        require(to != address(0) && to != msg.sender, "Invalid");
        delegates[msg.sender] = to;
        emit Delegated(msg.sender, to);
    }
    
    // Core Function 2: Vote
    function vote(uint256 id, bool support) external {
        require(id < proposalCount && !hasVoted[id][msg.sender], "Invalid");
        Proposal storage p = proposals[id];
        require(block.timestamp <= p.deadline, "Ended");
        
        uint64 power = votingPower[msg.sender];
        hasVoted[id][msg.sender] = true;
        
        if (support) {
            p.votesFor += power;
        } else {
            p.votesAgainst += power;
        }
        
        emit Voted(id, msg.sender, support);
    }
    
    // Core Function 3: Create Proposal
    function createProposal(string calldata desc) external returns (uint256) {
        require(votingPower[msg.sender] > 0, "No power");
        
        uint256 id = proposalCount++;
        proposals[id] = Proposal({
            description: desc,
            votesFor: 0,
            votesAgainst: 0,
            deadline: uint32(block.timestamp + 7 days),
            executed: false
        });
        
        return id;
    }
    
    // Grant voting power (owner only)
    function grantPower(address to, uint64 amount) external {
        require(msg.sender == owner, "Not owner");
        votingPower[to] = amount;
    }
}
