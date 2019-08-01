# Avoiding Common Attacks

## TxOrigin Attack

The global variable tx.origin in Solidity always references the address of
the original sender of the transaction, so we use msg.sender to get
the address of the sender of the current call instead. The contract
may include cryptocurrency staking at a future point so we want
to avoid using tx.origin for authorization.


## Denial of Service by Block Gas Limit (or startGas)

There is a need to loop over all the candidates to determine the
winner, so we use an array of fixed size to avoid a possible DoS
attack by a large number of fake candidates.


## Timestamp Dependence

We avoid using a timestamp to determine the end time of the election.
