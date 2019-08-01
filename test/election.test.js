let catchRevert = require("./exceptionsHelpers.js").catchRevert
var Election = artifacts.require("./Election.sol")

contract('Election', function(accounts) {

  const chairperson = accounts[0]
  const mike = accounts[1]
  const nancy = accounts[2]
  const alice = accounts[3]
  const bob = accounts[4]
  const charlie = accounts[5]
  const david = accounts[6]
  
  var NUM_CANDIDATES_MAX

  let instance

  beforeEach(async () => {
    instance = await Election.new()
    await instance.addCandidate("Mike", {from: mike})
    await instance.addCandidate("Nancy", {from: nancy})
    await instance.addVoter("Alice", {from: alice})
    await instance.addVoter("Bob", {from: bob})
    await instance.addVoter("Charlie", {from: charlie})
    await instance.addVoter("David", {from: david})
    NUM_CANDIDATES_MAX = await instance.getNumCandidatesMax()
  })

  it("should correctly count the number of candidates and voters", async () =>{
    const expectedVoterCount = 4
    const voterCount = await instance.voterCount()
    assert.equal(expectedVoterCount, voterCount, "Incorrect number of candidates");
    const expectedCandidateCount = 2
    const candidateCount = await instance.candidateCount()
    assert.equal(expectedCandidateCount, candidateCount, "Incorrect number of candidates");
  })

  it("should initialize the voters with the correct values", async () =>{
    const voter0 = await instance.readVoter({from: alice})
    assert.equal(voter0.name, "Alice", "the voter name should match")
    assert.equal(voter0.voterId, 0, "the voter name should match")
    // assert.equal(voter0.candidateId, NUM_CANDIDATES_MAX, "the voter should not have voted for a candidate yet")
  })

  it("should initialize the candidates with the correct values", async () =>{
    const candidate0 = await instance.readCandidate(0, {from: chairperson})
    assert.equal(candidate0.addr, mike, "the candidate address should match")
    assert.equal(candidate0.name, "Mike", "the candidate name should match")
    assert.equal(candidate0.voteCount, 0, "the candidate vote count should match")
  })

  it("voting for two different candidates should throw an error", async () => {
    await instance.castVote(0, 0, {from: alice})
    await catchRevert(instance.castVote(0, 0, {from: alice}))  
  })

  it("should correctly determine the winner of the election", async () => {
    await instance.castVote(0, 0, {from: alice})
    await instance.castVote(1, 0, {from: bob})
    await instance.castVote(2, 1, {from: charlie})
    await instance.castVote(3, 1, {from: david})
    await instance.recallVote(3, 1, {from: david})
    const expectedWinnerId = 0
    const winnerId = await instance.endElection({from: chairperson})
    assert.equal(expectedWinnerId, winnerId, "Winner not correctly determined");
  })
})

