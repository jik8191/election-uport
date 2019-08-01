pragma solidity ^0.5.0;

contract Election {

    // voter fields
    struct Voter {
        string name;
        uint voterId;     // voter's registration id
        uint candidateId; // voter's cast vote
    }

    // candidate fields
    struct Candidate {
        address addr;
        string name;
        uint voteCount;
    }

    // will change to uPort identification later
    mapping (address => Voter) public voters;
    mapping (address => bool) public voterRegistrations;
    mapping (address => bool) public candidateRegistrations;
    uint constant NUM_CANDIDATES_MAX = 2;
    Candidate[NUM_CANDIDATES_MAX] public candidates;

    event LogVoterAdded(string name, uint voterId);
    event LogVoterVoted(uint voterId, uint candidateId);
    event LogVoterRecalledVote(uint voterId, uint candidateId);
    event LogCandidateAdded(string name, uint candidateId);
    event LogEndElection(uint candidateId);

    modifier isOwner() {require (msg.sender == owner); _;}

    // store organizer information
    address public owner;
    uint public voterIdGenerator;
    uint public candidateIdGenerator;

    constructor () public {
        owner = msg.sender;
        voterIdGenerator = 0;     // no 0th voter
        candidateIdGenerator = 0; // 0 counts as a spoiled vote for now
    }

    
    // for now, anyone can participate until the organizer closes this
    function addVoter(string memory _name) public returns (uint) {
        uint _voterId = voterIdGenerator;
        address _addr = msg.sender;
        voters[_addr] = Voter({name: _name,
                               voterId: _voterId,
                               candidateId: NUM_CANDIDATES_MAX});
        voterIdGenerator++;
        emit LogVoterAdded(_name, _voterId);
        return _voterId;
    }

    function readVoter() public view 
        returns (string memory name, uint voterId, uint candidateId) {
        address _addr = msg.sender;
        name = voters[_addr].name;
        voterId = voters[_addr].voterId;
        candidateId = voters[_addr].candidateId;
        return (name, voterId, candidateId);
    }


    // for now, anyone can participate
    function addCandidate(string memory _name) public
        returns (uint) {
        require (candidateRegistrations[msg.sender] == false);    
        require (candidateIdGenerator < NUM_CANDIDATES_MAX, "No more candidates allowed");
        uint _candidateId = candidateIdGenerator;
        address _addr = msg.sender;
        candidates[_candidateId] = Candidate({addr: _addr,
                                              name: _name,
                                              voteCount: 0});
        candidateIdGenerator++;
        return _candidateId;
        emit LogCandidateAdded(_name, _candidateId);
    }

    function readCandidate(uint _id) public view 
        returns (address addr, string memory name, uint voteCount) {
        addr = candidates[_id].addr;
        name = candidates[_id].name;
        voteCount = candidates[_id].voteCount;
        return (addr, name, voteCount);
    }


    function getCandidateCount() public view returns (uint candidateCount) {
        return candidateIdGenerator;
    }
    
    function getVoterCount() public view returns (uint voterCount) {
        return voterIdGenerator;
    }

    
    function getCandidateVoteCount(uint id) external
        view returns (uint){
        return candidates[id].voteCount;
    }
    
    function castVote(uint voterId, uint candidateId) external {
        require (voters[msg.sender].voterId == voterId);
        require (voters[msg.sender].candidateId == NUM_CANDIDATES_MAX, "Voter has already voted");
        require (candidateId < candidateIdGenerator, "invalid candidate");
        candidates[candidateId].voteCount++;
        voters[msg.sender].candidateId = candidateId;
        emit LogVoterVoted(voterId, candidateId);
    }

 
    function recallVote(uint voterId, uint candidateId) external {
        require (voters[msg.sender].voterId == voterId);
        require (voters[msg.sender].candidateId < NUM_CANDIDATES_MAX, "Voter has not yet voted");
        require (candidateId < candidateIdGenerator, "invalid candidate");
        candidates[candidateId].voteCount--;
        voters[msg.sender].candidateId = NUM_CANDIDATES_MAX;
        emit LogVoterRecalledVote(voterId, candidateId);
    }


    function endElection() public view returns (uint winnerId) {
        uint winningVoteCount = 0;
        for (uint i = 0; i < candidateIdGenerator; i++) {
            if (candidates[i].voteCount > winningVoteCount){
                winningVoteCount = candidates[i].voteCount;
                winnerId = i;
            }
        }
        return winnerId;
    }

}
