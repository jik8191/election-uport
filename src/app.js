App = {
  loading: false,
  contracts: {},
  load: async () => {
    // load app
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
    await App.render()
    console.log("app loading")
  },    

  // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
  loadWeb3: async () => {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider
      web3 = new Web3(web3.currentProvider)
    } else {
      window.alert("Please connect to Metamask.")
    }
    // Modern dapp browsers...
    if (window.ethereum) {
      window.web3 = new Web3(ethereum)
      try {
        // Request account access if needed
        await ethereum.enable()
        // Acccounts now exposed
        web3.eth.sendTransaction({/* ... */})
      } catch (error) {
        // User denied account access...
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = web3.currentProvider
      window.web3 = new Web3(web3.currentProvider)
      // Acccounts always exposed
      web3.eth.sendTransaction({/* ... */})
    }
    // Non-dapp browsers...
    else {
      console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  },

  loadAccount: async () => {
    App.account = web3.eth.accounts[0]
    console.log(App.account)
  },

  loadContract: async () => {
    // Create a Javascript version of the smart contract
    const Election = await $.getJSON('Election.json') // in /build/contracts
    App.contracts.Election = TruffleContract(Election)
    App.contracts.Election.setProvider(App.web3Provider)
    console.log(Election)  

    // Hydrate the smart contract with values from the blockchain
    App.election = await App.contracts.Election.deployed()
  },

  render: async () => {

    // Prevent double render
    if (App.loading) {
      return
    }

    // Update app loading state
    App.setLoading(true)

    // Render account
    $('#account').html(App.account)
  
    // Render Candidates
    await App.renderCandidates()
        
    // Update loading state
    App.setLoading(false)
  },

  renderCandidates: async () => {
    // Load the total candidate count from the blockchain
    const candidateCount = await App.election.candidateIdGenerator()
    const candidateCount2 = await App.election.getCandidateCount()
      
    console.log(candidateCount)
    console.log(candidateCount2)
    const $candidateTemplate = $('.candidateTemplate')

    // Render out each candidate with a new candidate template
    for (var i = 1; i < candidateCount; i++){
      // Fetch the candidate data from the blockchain
      const candidate = await App.election.readCandidate(i)
      console.log(candidate)  
      // const candidateAddr = candidate[0]
      const candidateName = candidate[1]
      // const candidateVoteCount = candidate[2]  
      // Create the html for the candidate
      const $newCandidateTemplate = $candidateTemplate.clone()
      $newCandidateTemplate.find('.content').html(candidateName)  

      $('#candidateList').append($newCandidateTemplate)

      // Show the candidate
      $newCandidateTemplate.show()
    }
  },


  setLoading: (isLoading) => {
    App.loading = isLoading
    const loader = $('#loader')
    const content = $('#content')
    if (isLoading) {
      loader.show()
      content.hide()
    } else {
      loader.hide()
      content.show()    
    }
  },

  addCandidate: async () => {
    App.setLoading(true)
    const candidateName = $('#candidateName').val()
    await App.election.addCandidate(candidateName)
    window.location.reload()
  }


}




$(()=> {
  $(window).load(()=> {
    App.load()
  })
})

