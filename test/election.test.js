let catchRevert = require("./exceptionsHelpers.js").catchRevert
var Election = artifacts.require("./Election.sol")

contract('Election', function(accounts) {

  const chairperson = accounts[0]
  const candidate1 = accounts[1]
  const candidate2 = accounts[2]
  const alice = accounts[3]
  const bob = accounts[4]
  const charlie = accounts[5]
  const david = accounts[6]


  beforeEach(async () => {
    instance = await Election.new()
    await instance.addCandidate("Candidate1", {from: candidate1})
    await instance.addCandidate("Candidate2", {from: candidate2})
    await instance.addVoter("Alice", {from: alice})
    await instance.addVoter("Bob", {from: bob})
    await instance.addVoter("Charlie", {from: charlie})
    await instance.addVoter("David", {from: david})
  })

  it("should correctly count the number of candidates and voters", async () =>{
    const expectedVoterCount = 4
    const voterCount = await instance.getVoterCount()
    assert.equal(expectedVoterCount, voterCount, "Incorrect number of candidates");
    const expectedCandidateCount = 2
    const candidateCount = await instance.getCandidateCount()
    assert.equal(expectedCandidateCount, candidateCount, "Incorrect number of candidates");
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
