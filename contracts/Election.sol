pragma solidity ^0.5.0;

contract Election {

    // voter fields
    struct Voter {
        uint id;
        address addr;
        string name;
        uint candidateId; // voter's cast vote
    }

    // candidate fields
    struct Candidate {
        uint id;
        address addr;
        string name;
        uint voteCount;

    }

    // may make this private later
    // will use a token for voting?
    mapping (uint => Voter) public voters;
    mapping (uint => Candidate) public candidates;

    event LogVoterAdded(string name);
    event LogVoterVoted(uint voterId, uint candidateId);
    event LogVoterRecalledVote(uint voterId, uint candidateId);
    event LogCandidateAdded(string name);
    event LogEndElection(uint candidateId);

    modifier isOwner() {require (msg.sender == owner); _;}
    modifier isVoter(uint id) {require (msg.sender == voters[id].addr); _;}
    modifier isValidCandidate(uint id) {require (id > 0 && id < candidateIdGenerator); _;}

    // store organizer information
    address public owner;
    uint public voterIdGenerator;
    uint public candidateIdGenerator;

    constructor () public {
        owner = msg.sender;
        voterIdGenerator = 1;     // no 0th voter
        candidateIdGenerator = 1; // 0 counts as a spoiled vote for now
    }

    
    // for now, anyone can participate until the organizer closes this
    function addVoter(string memory _name) public returns (uint) {
        uint _id = voterIdGenerator;
        address _addr = msg.sender;
        voters[_id] = Voter({id: _id,
                             addr: _addr,  
                             name: _name,
                             candidateId: 0});
        voterIdGenerator++;
        emit LogVoterAdded(_name);
        return _id;
    }

    function readVoter(uint _id) public view 
        returns (address addr, string memory name, uint candidateId) {
        addr = voters[_id].addr;
        name = voters[_id].name;
        candidateId = voters[_id].candidateId;
        return (addr, name, candidateId);
    }


    // for now, anyone can participate
    function addCandidate(string memory _name) public
        returns (uint) {
        uint _id = candidateIdGenerator;
        address _addr = msg.sender;
        candidates[_id] = Candidate({id: _id,
                                     addr: _addr,
                                     name: _name,
                                     voteCount: 0});
        candidateIdGenerator++;
        return _id;
        emit LogCandidateAdded(_name);
    }

    function readCandidate(uint _id) public view 
        returns (address addr, string memory name, uint voteCount) {
        addr = candidates[_id].addr;
        name = candidates[_id].name;
        voteCount = candidates[_id].voteCount;
        return (addr, name, voteCount);
    }


    function getCandidatesCount() public view returns (uint candidatesCount) {
        return (candidateIdGenerator-1);
    }
    
    function getVotersCount() public view returns (uint candidatesCount) {
        return (voterIdGenerator-1);
    }

    
    function getCandidateVoteCount(uint id) external
        view returns (uint){
        return candidates[id].voteCount;
    }
    
    function castVote(uint voterId, uint candidateId) external
        isVoter(voterId) isValidCandidate(candidateId){
        require (voters[voterId].candidateId == 0, "Voter has already voted");
        require (candidateId < candidateIdGenerator, "invalid candidate");
        candidates[candidateId].voteCount++;
        voters[voterId].candidateId = candidateId;
        emit LogVoterVoted(voterId, candidateId);
    }

    function recallVote(uint voterId, uint candidateId) external
        isVoter(voterId) isValidCandidate(candidateId){
        require (voters[voterId].candidateId == candidateId, "Voter has not yet voted");
        require (candidateId < candidateIdGenerator, "invalid candidate");
        candidates[candidateId].voteCount--;
        voters[voterId].candidateId = 0;
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
