
Sources
=======
CreditEAI Procedure

1. CreditEAI transactions are issued by active nodes and each causes all accounts delegated to that node to have their accrued EAI credited, provided they are not currently on the BPC list of accounts forfeiting EAI.  and each includes a list of accounts to which accrued EAI is to be credited.
2. The transaction is not valid if it lists an account not delegated to the node submitting it, or if it lists an account currently listed in the BPC's "forfeited EAI" blacklist.
3. The CreditEAI transaction fee includes a per-byte component, discouraging nodes from listing accounts more often than necessary.
4. There are two applicable CreditEAI limits published on the chaos chain: a maximum elapsed time and a maximum accrued amount. Nodes are responsible for crediting EAI to each account with sufficient frequency to not exceed either of those limits.
5. If those limits are exceeded, the next CreditEAI transaction will credit the amount accrued as if the most recent CreditEAI transaction had occurred at the oldest time that would not have exceeded either of them.
6. There is no minimum elapsed time between credits to any given account, nor is there a minimum amount to be credited. Nodes and accounts are penalized for too-frequent credits: the node pays unnecessary fees, and the account loses more EAI due to truncation.
7. No accrued EAI is lost if an account is redelegated to a new node. The next CreditEAI transaction issued by the new node will credit all accrued EAI due, subject to the time and quantity limits listed in #5 above.

EAI Rate Schedule Changes

1. EAI accrues based on an account’s WAA according to the EAI rate table currently in effect. An account’s WAA is updated on every incoming transfer to it: outgoing transfers and EAI credits do not update the WAA.
2. When an account is locked, the current EAI lock bonus for the specified lock period is recorded as part of the account state. That lock bonus never changes and is always added to the current unlocked base rate, which may change.
3. EAI is accrued by a locked account at the current base rate applicable to its current WAA plus the lock bonus rate recorded when the account was locked.
4. Changes to the unlocked EAI rate tables take effect immediately. All accounts begin accruing EAI at the new rates. Locked accounts continue to have their original EAI bonus amount added to the current unlocked rate.
5. If an account is re-locked its bonus is changed to the then-current rate for the new lock period.

Node Reward Procedure

1. An off-chain service (initially operated by ndev) periodically issues NominateNodeReward transactions. The chaos chain identifies the accounts permitted to issue this transaction, and it lists a table of EAI fees to be allocated to system accounts and node rewards.
2. System EAI fees due to all listed recipients are calculated in the NominateNodeReward transaction and credited to the appropriate system accounts. The transaction also calculates the amount available to be claimed in the node reward itself and publishes it in the transaction but does not credit it to that node.
3. The nominated node must respond within a time limit (published on the chaos chain) by issuing a ClaimNodeReward transaction.
4. The ClaimNodeReward transaction must be issued by the nominated node, and it credits the node reward specified in the nomination to it.
5. The NominateNodeReward transaction calculates all fee and reward amounts accrued since the last NominateNodeReward transaction. If the previous node reward was not claimed in time, it is discarded.
