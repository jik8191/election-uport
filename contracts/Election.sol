pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/** @title Election **/
contract Election is Ownable {

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

    bool private stopped = false;
    function toggleContractActive() onlyOwner public {
        stopped = !stopped;
    }

    modifier stopInEmergency { if (!stopped) _; }
    modifier onlyInEmergency { if (stopped) _; }

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

    uint public voterCount;
    uint public candidateCount;

    constructor () public {
        voterCount = 0;     // no 0th voter
        candidateCount = 0; // 0 counts as a spoiled vote for now
    }

    
    /** @dev Adds a voter to the list of registered ones
      * @param _name Name of voter
      * @return _id Id of voter in the registration array
      */
    function addVoter(string memory _name) public returns (uint) {
        uint _voterId = voterCount;
        address _addr = msg.sender;
        voters[_addr] = Voter({name: _name,
                               voterId: _voterId,
                               candidateId: NUM_CANDIDATES_MAX});
        voterCount++;
        emit LogVoterAdded(_name, _voterId);
        return _voterId;
    }

    /** @dev Reads voter from the list of registered ones
      * @return name Name of voter
      * @return voterId Id of voter
      * @return candidateId Id of candidate voted for by voter (to be encrypted)
      */
    function readVoter() public view 
        returns (string memory name, uint voterId, uint candidateId) {
        address _addr = msg.sender;
        name = voters[_addr].name;
        voterId = voters[_addr].voterId;
        candidateId = voters[_addr].candidateId;
        return (name, voterId, candidateId);
    }


    /** @dev Adds a candidate to the list of registered ones
      * @param _name Name of candidate to be displayed
      * @return _id Id of candidate in the registration array
      */
    function addCandidate(string memory _name) public
        returns (uint) {
        require (candidateRegistrations[msg.sender] == false);    
        require (candidateCount < NUM_CANDIDATES_MAX, "No more candidates allowed");
        uint _candidateId = candidateCount;
        address _addr = msg.sender;
        candidates[_candidateId] = Candidate({addr: _addr,
                                              name: _name,
                                              voteCount: 0});
        candidateCount++;
        emit LogCandidateAdded(_name, _candidateId);
        return _candidateId;
    }

    /** @dev Reads candidate from the list of registered ones
      * @param _id Id of candidate in the registration array
      * @return addr Ethereum address of candidate
      * @return name Name of candidate
      * @return voteCount Number of votes for this candidate
      */
    function readCandidate(uint _id) public view 
        returns (address addr, string memory name, uint voteCount) {
        addr = candidates[_id].addr;
        name = candidates[_id].name;
        voteCount = candidates[_id].voteCount;
        return (addr, name, voteCount);
    }

    function getNumCandidatesMax() public view returns (uint) {
        return NUM_CANDIDATES_MAX;
    }

    /** @dev Allows voter with voterId to cast a vote
      * @param voterId Id of voter
      * @return candidateId Id of candidate they are voting for
      */ 
    function castVote(uint voterId, uint candidateId) stopInEmergency external {
        require (voters[msg.sender].voterId == voterId);
        require (voters[msg.sender].candidateId == NUM_CANDIDATES_MAX, "Voter has already voted");
        require (candidateId < candidateCount, "invalid candidate");
        candidates[candidateId].voteCount++;
        voters[msg.sender].candidateId = candidateId;
        emit LogVoterVoted(voterId, candidateId);
    }

     /** @dev Allows voter with voterId to recall a vote
      * @param voterId Id of voter
      * @return candidateId Id of candidate for whom they are recalling a vote
      */ 
    function recallVote(uint voterId, uint candidateId) stopInEmergency external {
        require (voters[msg.sender].voterId == voterId);
        require (voters[msg.sender].candidateId < NUM_CANDIDATES_MAX, "Voter has not yet voted");
        require (candidateId < candidateCount, "invalid candidate");
        candidates[candidateId].voteCount--;
        voters[msg.sender].candidateId = NUM_CANDIDATES_MAX;
        emit LogVoterRecalledVote(voterId, candidateId);
    }


    function endElection() onlyOwner public view returns (uint winnerId) {
        uint winningVoteCount = 0;
        for (uint i = 0; i < candidateCount; i++) {
            if (candidates[i].voteCount > winningVoteCount){
                winningVoteCount = candidates[i].voteCount;
                winnerId = i;
            }
        }
        return winnerId;
    }

    function kill() onlyOwner public {
        selfdestruct(address(uint160(owner())));
    }
}

