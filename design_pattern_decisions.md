
# Design Pattern Decisions

## Restricting Access

Function access to most of the important functions are
restricted to either the chairperson for the election or specific
voters or candidates who have registered. This prevents fradulent
voting by a single Ethereum address. uPort authentication will be
included in the future.

## Mortal

The contract will become useless after the election is completed
and a result is determined, so the chairperson has the ability
to destroy it at that time.

## Circuit breakers

Circuit breakers are used to allow the election to 
be suspended by the owner if necessary.
