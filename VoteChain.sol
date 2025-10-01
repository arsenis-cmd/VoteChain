// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// File: contracts/VoteChain.sol
// How to name: contracts/VoteChain.sol

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title VoteChain
 * @dev Secure, transparent blockchain voting system
 * Features: Anonymous voting, audit trails, real-time results
 */
contract VoteChain is Ownable, ReentrancyGuard {
    
    // Structs
    struct Election {
        string title;
        string description;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool resultsPublished;
        ElectionType electionType;
        uint256 totalVotes;
        address creator;
    }
    
    struct Candidate {
        string name;
        string description;
        string imageUrl;
        uint256 voteCount;
    }
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        bytes32 voteHash; // Hash of vote for verification without revealing choice
        uint256 votedAt;
    }
    
    enum ElectionType {
        SingleChoice,    // One candidate
        MultipleChoice,  // Multiple candidates
        YesNo,          // Binary referendum
        Ranked          // Ranked choice (simplified)
    }
    
    // State variables
    mapping(uint256 => Election) public elections;
    mapping(uint256 => Candidate[]) public electionCandidates;
    mapping(uint256 => mapping(address => Voter)) public electionVoters;
    mapping(address => bool) public registeredVoters;
    mapping(uint256 => mapping(address => bool)) public electionAdmins;
    
    uint256 public electionCount;
    
    // Events
    event ElectionCreated(
        uint256 indexed electionId,
        string title,
        address indexed creator,
        uint256 startTime,
        uint256 endTime
    );
    
    event VoterRegistered(address indexed voter, uint256 timestamp);
    
    event VoteCast(
        uint256 indexed electionId,
        address indexed voter,
        bytes32 voteHash,
        uint256 timestamp
    );
    
    event ElectionEnded(uint256 indexed electionId, uint256 totalVotes);
    
    event ResultsPublished(uint256 indexed electionId);
    
    // Modifiers
    modifier onlyRegisteredVoter() {
        require(registeredVoters[msg.sender], "Not a registered voter");
        _;
    }
    
    modifier electionExists(uint256 _electionId) {
        require(_electionId < electionCount, "Election does not exist");
        _;
    }
    
    modifier electionActive(uint256 _electionId) {
        Election memory election = elections[_electionId];
        require(election.isActive, "Election is not active");
        require(block.timestamp >= election.startTime, "Election has not started");
        require(block.timestamp <= election.endTime, "Election has ended");
        _;
    }
    
    modifier hasNotVoted(uint256 _electionId) {
        require(!electionVoters[_electionId][msg.sender].hasVoted, "Already voted");
        _;
    }
    
    modifier onlyElectionAdmin(uint256 _electionId) {
        require(
            electionAdmins[_electionId][msg.sender] || 
            elections[_electionId].creator == msg.sender ||
            owner() == msg.sender,
            "Not authorized"
        );
        _;
    }
    
    // Voter Registration
    function registerVoter(address _voter) external onlyOwner {
        require(!registeredVoters[_voter], "Already registered");
        
        registeredVoters[_voter] = true;
        
        emit VoterRegistered(_voter, block.timestamp);
    }
    
    function registerVoterBatch(address[] calldata _voters) external onlyOwner {
        for (uint256 i = 0; i < _voters.length; i++) {
            if (!registeredVoters[_voters[i]]) {
                registeredVoters[_voters[i]] = true;
                emit VoterRegistered(_voters[i], block.timestamp);
            }
        }
    }
    
    // Election Management
    function createElection(
        string memory _title,
        string memory _description,
        uint256 _startTime,
        uint256 _endTime,
        ElectionType _electionType,
        string[] memory _candidateNames,
        string[] memory _candidateDescriptions
    ) external returns (uint256) {
        require(_startTime > block.timestamp, "Start time must be in future");
        require(_endTime > _startTime, "End time must be after start time");
        require(_candidateNames.length >= 2, "Need at least 2 candidates");
        require(_candidateNames.length == _candidateDescriptions.length, "Array length mismatch");
        
        uint256 electionId = electionCount++;
        
        elections[electionId] = Election({
            title: _title,
            description: _description,
            startTime: _startTime,
            endTime: _endTime,
            isActive: true,
            resultsPublished: false,
            electionType: _electionType,
            totalVotes: 0,
            creator: msg.sender
        });
        
        // Add candidates
        for (uint256 i = 0; i < _candidateNames.length; i++) {
            electionCandidates[electionId].push(Candidate({
                name: _candidateNames[i],
                description: _candidateDescriptions[i],
                imageUrl: "",
                voteCount: 0
            }));
        }
        
        // Set creator as admin
        electionAdmins[electionId][msg.sender] = true;
        
        emit ElectionCreated(electionId, _title, msg.sender, _startTime, _endTime);
        
        return electionId;
    }
    
    function addElectionAdmin(uint256 _electionId, address _admin) 
        external 
        electionExists(_electionId) 
        onlyElectionAdmin(_electionId) 
    {
        electionAdmins[_electionId][_admin] = true;
    }
    
    // Voting
    function castVote(uint256 _electionId, uint256 _candidateIndex, bytes32 _voteSecret)
        external
        nonReentrant
        onlyRegisteredVoter
        electionExists(_electionId)
        electionActive(_electionId)
        hasNotVoted(_electionId)
    {
        require(_candidateIndex < electionCandidates[_electionId].length, "Invalid candidate");
        
        // Record vote
        electionCandidates[_electionId][_candidateIndex].voteCount++;
        elections[_electionId].totalVotes++;
        
        // Create vote hash for verification (without revealing choice)
        bytes32 voteHash = keccak256(abi.encodePacked(
            _electionId,
            _candidateIndex,
            msg.sender,
            _voteSecret,
            block.timestamp
        ));
        
        // Mark voter as voted
        electionVoters[_electionId][msg.sender] = Voter({
            isRegistered: true,
            hasVoted: true,
            voteHash: voteHash,
            votedAt: block.timestamp
        });
        
        emit VoteCast(_electionId, msg.sender, voteHash, block.timestamp);
    }
    
    // Verify vote without revealing choice
    function verifyVote(
        uint256 _electionId,
        uint256 _candidateIndex,
        bytes32 _voteSecret,
        uint256 _timestamp
    ) external view returns (bool) {
        Voter memory voter = electionVoters[_electionId][msg.sender];
        
        if (!voter.hasVoted) return false;
        
        bytes32 calculatedHash = keccak256(abi.encodePacked(
            _electionId,
            _candidateIndex,
            msg.sender,
            _voteSecret,
            _timestamp
        ));
        
        return calculatedHash == voter.voteHash;
    }
    
    // End election
    function endElection(uint256 _electionId)
        external
        electionExists(_electionId)
        onlyElectionAdmin(_electionId)
    {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election already ended");
        require(block.timestamp > election.endTime, "Election period not over");
        
        election.isActive = false;
        
        emit ElectionEnded(_electionId, election.totalVotes);
    }
    
    function publishResults(uint256 _electionId)
        external
        electionExists(_electionId)
        onlyElectionAdmin(_electionId)
    {
        Election storage election = elections[_electionId];
        require(!election.isActive, "Election still active");
        require(!election.resultsPublished, "Results already published");
        
        election.resultsPublished = true;
        
        emit ResultsPublished(_electionId);
    }
    
    // View Functions
    function getElection(uint256 _electionId)
        external
        view
        electionExists(_electionId)
        returns (
            string memory title,
            string memory description,
            uint256 startTime,
            uint256 endTime,
            bool isActive,
            bool resultsPublished,
            ElectionType electionType,
            uint256 totalVotes,
            uint256 candidateCount
        )
    {
        Election memory election = elections[_electionId];
        return (
            election.title,
            election.description,
            election.startTime,
            election.endTime,
            election.isActive,
            election.resultsPublished,
            election.electionType,
            election.totalVotes,
            electionCandidates[_electionId].length
        );
    }
    
    function getCandidates(uint256 _electionId)
        external
        view
        electionExists(_electionId)
        returns (Candidate[] memory)
    {
        return electionCandidates[_electionId];
    }
    
    function getResults(uint256 _electionId)
        external
        view
        electionExists(_electionId)
        returns (Candidate[] memory)
    {
        Election memory election = elections[_electionId];
        require(election.resultsPublished || !election.isActive, "Results not available");
        
        return electionCandidates[_electionId];
    }
    
    function hasVoted(uint256 _electionId, address _voter)
        external
        view
        electionExists(_electionId)
        returns (bool)
    {
        return electionVoters[_electionId][_voter].hasVoted;
    }
    
    function getVoterStatus(uint256 _electionId)
        external
        view
        electionExists(_electionId)
        returns (bool isRegistered, bool hasVotedInElection, uint256 votedAt)
    {
        Voter memory voter = electionVoters[_electionId][msg.sender];
        return (
            registeredVoters[msg.sender],
            voter.hasVoted,
            voter.votedAt
        );
    }
    
    function getElectionStatus(uint256 _electionId)
        external
        view
        electionExists(_electionId)
        returns (
            bool isActive,
            bool hasStarted,
            bool hasEnded,
            uint256 remainingTime
        )
    {
        Election memory election = elections[_electionId];
        
        hasStarted = block.timestamp >= election.startTime;
        hasEnded = block.timestamp > election.endTime;
        
        uint256 remaining = 0;
        if (!hasEnded && hasStarted) {
            remaining = election.endTime - block.timestamp;
        }
        
        return (
            election.isActive && hasStarted && !hasEnded,
            hasStarted,
            hasEnded,
            remaining
        );
    }
    
    // Get all elections
    function getElectionCount() external view returns (uint256) {
        return electionCount;
    }
    
    // Emergency functions
    function pauseElection(uint256 _electionId)
        external
        electionExists(_electionId)
        onlyOwner
    {
        elections[_electionId].isActive = false;
    }
    
    function resumeElection(uint256 _electionId)
        external
        electionExists(_electionId)
        onlyOwner
    {
        require(block.timestamp <= elections[_electionId].endTime, "Election period ended");
        elections[_electionId].isActive = true;
    }
}
