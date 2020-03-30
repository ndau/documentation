User
====
NO EDITING HAS BEEN DONE AFTER THIS POINT. SOME OF THIS MATERIAL WILL MOVE OUT OF THIS DOCUMENT AND INTO NETWORK/IMPLEMENTATION SPECIFICATIONS. 
As of 8/10/18, this is not worth reading yet. 

The complete state of an address is derivable at any time by playing back all of the transactions on the chain that mention that address. In practice, nodes will maintain a cached list of some or all addresses and their state so as to simplify and speed up processing.

## Wallet

A wallet is a software application for managing ndau addresses. Wallets may offer various organizational features to the user, but they are independent of the ndau blockchain and are not recorded on it. ndau transactions only operate on addresses, but wallets may offer features allowing users to aggregate addresses in various ways for convenience.

## Node

A node is a computing device participating in the ndau network, running ndau blockchain software.

Each node is identified by exactly one ndau address, which is used to mediate node operations.

Nodes may monitor or store the ndau blockchain and propose transactions to it.

## Node Operator

An entity responsible for operating one or more nodes. The node operator of a particular node is considered to be the entity that holds the private key for the node's staked address.

## Stake

A stake is a quantity of ndau associated with a node and held as a surety bond. "Stake" is also a verb describing the process of that association.

Stake may be forfeited (slashed) as a penalty for poor or malicious node behavior. Stake has a target -- the address to which the stake is pledged.

"Self-stake" is ndau in an address staked to itself. ndau staked to a different address is "co-stake".

## Active Node

An active node is one that has self-staked the minimum quantity of ndau currently specified by the BPC.

Any rewards for a node's participation in the ndau network are credited to its address.

## Resiliency Score

The resiliency score measures the quality of an active node's performance in support of the ndau network. It is based on a node's total stake, performance, and other performance metrics.

## Validator Node

A validator node is an active node currently assigned to the consensus engine's network.

Any validator node may be selected to prepare a block for an ndau blockchain. All validator nodes participate in the consensus mechanism to add new blocks to an ndau blockchain.

Active nodes that are not currently validator nodes may become validator nodes at any time to support network resiliency.

## Transaction Fees

A fee is charged for all transactions. In some cases fees may be set to 0 ndau.

The fee is paid from each transaction's source address.

Fees are set by a published fee schedule that is controlled by the BPC. In some cases, the fee's value may be determined by a formula rather than being a scalar value.

## Ecosystem Alignment Incentives (EAI)

Ecosystem Alignment Incentives are newly-issued ndau available to ndau holders to incent holder behavior in support of ndau fiscal policy and goals.

EAI is only credited to addresses delegating that action to active nodes. EAI accrues at rates based on a published schedule.

EAI is accrued for each address but not credited to that address until its associated node explicitly requests it by submitting an EAI claim transaction. The BPC may specify additional requirements, to encourage ecosystem participation, before accrued EAI may be credited to an address.

## EAI Service Fees

Mandatory service fees are deducted from all EAI: they include
* An Ecosystem Funding Fee (4%)
* A Market Maker Price Discovery Fee (1%)
* A Node Operations Fee (10%)

## Node Operation Rewards

Node operation rewards incent node operators to improve network performance and resilience.

Rewards are paid from both transaction fees and the node operations fee deducted from EAI.

Only active nodes earn node operations rewards.

# Implementation Notes

## Time

It is tempting to simply use block number (a monotonically increasing value) as the only timestamp, and to denominate all time-based calculations in terms of block numbers. However, block rate can vary, and may in fact vary both up and down, especially early in the life of ndau. This will play havoc with human-understood quantities like annualized rates and expiration times. Consequently, we really must have a more time-based approach.

Clock time is right out. The complications involved with keeping clock time correct (leap years, leap days, etc) are particularly troublesome when durations are required -- and almost everything we're doing is with respect to duration. Consequently, we just use time as a duration in milliseconds from a fixed point, which is a monotonically increasing number.

Timestamps are a 64-bit value corresponding to the number of microseconds (usec) since the start of the epoch (which will be arbitrarily defined from some meaningful date); there is enough resolution that this value will not overflow for half a million years.

Every block has a timestamp that is set by the block proposer, and which must be strictly greater than that of the previous block.

Transactions must also include a timestamp, also specified as a duration since the epoch. The timestamp of the transaction must be within `timestamp_precision` of the most recent's block timestamp or the transaction will be rejected. It is expected that `timestamp_precision` will be roughly equivalent to either the maximum permitted network latency or the interval between blocks, whichever is greater.

All time-based calculations, such as EAI and the like, will be done using these times. All durations will be measured in milliseconds by subtracting these timestamps.

Note that some public values, like EAI durations, are specified in units of days or years. Values specified in days will use an 86400-second standard day, and durations specified in years will assume a year of exactly 365 standard days. Leap years and leap seconds are not considered; conversion between clock time and system time is not part of the ndau specification.

## Transaction Ordering

All transactions must have a timestamp, as stated above. All timestamps generated by a given source address must be processed in strict timestamp order. The ordering within a block is not important (clients are expected to sort transactions by timestamp within a block). However, a transaction from address A in block N must be timestamped earlier than any transaction from address A in any later block.

(Note -- do we have to be stricter than this? Do we have to also restrict destinations?)

## ndau Units

The ndau is the standard currency unit. One ndau is composed of 100 Million (10^8) `napu`. One napu is the smallest division of ndau that can be calculated or transferred -- fractional napu ("dust") are simply discarded (not rounded).

All ndau calculations are done with integer quantities of napu. All ndau calculations (especially those involving multiplication and division) are defined with order of operations carefully documented so that the result is well-defined and repeatable. Quantities of ndau are stored as 64-bit integer amounts of napu, and calculations (especially those involving multiplication) are expected to use "big number" libraries to avoid overflow.

## Rate Units

Rates are important to the ndau system. Rates are normally quoted as decimal fractions. However, for repeatability we would like to use integer multiples of a quantum value, so we are using millionths of a basis point as the minimum quantum for interest rates (rates are specified to 8 decimal places). Rate calculations are done by multiplying the integer quantum value using big number math and then dividing by 10^8.

## Random numbers

Random values are recorded as 64-bit integers, rectangularly distributed (all values are equally possible).

## Transaction fees

All transactions have an associated fee.

Transfer transactions incur a fee of X% of the transfer amount, within a range between a minimum and maximum value. Other transaction types have additional fees that are constant.

Every transaction also pays a fee that is a function of the number of bytes in the transaction (transactions with multiple destinations or complex signatures will incur a higher cost).

The values of all these parameters are controlled by governance.

Fees are paid by the originator (source) of the transaction.

Transaction fees are paid to node operators as part of the node operations rewards.

# Implementation questions

* What if the RewardTarget is in the notified state?
    * For EAI, this can happen to both reward-targeted addresses as well as untargeted addresses. There is no fallback. The choices are:
        * Fail EAI transactions and burn the EAI
        * Pay anyway because total EAI impact is limited (but this does allow someone to be earning as much as 15% on EAI with short-term liquidity)
    * Node rewards specify many targets so one invalid one should not be a failure. However, because a node's address must be staked, node rewards cannot be due directly to an address in the notified state; this can only happen through targeting. Options:
        * If target is in the notified state, pay rewards instead to main address (which will make them unspendable since the address is by definition staked)
        * Burn the reward (complicated because of system EAI)
 
# Transactions

## Summary

Transactions always have a **source**: the account whose signature is required in order to validate the transaction. The source is the object of the transaction's action unless specified otherwise. Transactions may also have one or more **targets**; these are additional accounts that will be affected by the transaction.

Transactions on the ndau blockchain can be grouped into broad categories:

- Financial: Transactions that directly affect the source's `Balance` or the mechanisms by which the `Balance` is determined.
- Node operations: Transactions used to manage the operations of a node.
- Governance: Transactions used for governance of the blockchain system as a whole.

### Financial Transactions

All financial transactions must be signed by the `TransferKey` of the source; therefore, none of these transactions can occur until that `TransferKey` has been set.

* *Transfer to Target:* Transfers of a quantity of ndau from the source account to the target account
* *Change Transfer Key:* Sets the account's transfer key to be used for future financial transactions; invalid if `TransferKey` is null.
* *Delegate to Target:* Specifies the address of the active node that is to be responsible for crediting accrued EAI to this account. An account must be delegated to an active node to be eligible to earn EAI. This transaction is valid if the account is already delegated to an active node: it changes the account's delegation to the newly-specified active node. 
* *Lock:* Sets the `NoticePeriod` for an account and locks it; this influences EAI rates. A locked account may not be used as the source for a *Transfer from Source to Target* transaction. The account may not be already locked.
* *Notify:* Starts the notification period for a source and calculates the account's `UnlockTimestamp`. The source account must be locked, not staked, and not already notified.
* *Set Rewards Target:* Directs this account's earned EAI and node operations rewards to a different address. By default, these rewards are directed to the account itself.
* *Stake to Target* Assigns this account as stake to an active node and makes it eligible to share in node rewards. The account must already be locked with the minimum `NoticePeriod` specified by the BPC and may be required to meet other criteria (e.g. minimum balance). If the target is null the source account is unstaked, making it ineligible for further node rewards but eligible for unlock notification with a `Notify Source` transaction.

### Node Operations Transactions

These transactions must be signed by the `TransferKey` of the source.

* *EAI Credit to Targets:* Credits the target's accrued EAI to its balance. This transaction may only be issued by the active node to which the account has currently delegated this transaction. The target's eligibility to receive this credit is determined by any EAI rules currently in place. The source account is not affected unless it is specified as the target of this transaction.
* *Node Start:* Registers a node as an active node, provided that the node's account meets the current self-staking requirements. This transaction includes the script that specifies how the node will distribute its node rewards to co-staked accounts.
* *Node Reward Claim:* Claims the node rewards made available to the source account in a *Node Reward Nomination* transaction. Node rewards must be claimed promptly after a nomination, otherwise they are burned. This transaction must distribute rewards to the specified co-staked target accounts using the script specified in the *Node Start* transaction.\

### Governance Transactions

All governance transactions must be signed by the `OwnershipKey` of the associated account.

* *Set Initial Transfer Key:* Sets the initial `TransferKey` to be used for this account's non-governance transactions. This transaction is invalid if the account's current `TransferKey` is not null.
* *Node Reward Nomination:* Specifies the active node eligible to claim the current node rewards. It is generated by a central service and must be signed by the canonical node reward nomination account.

## Common elements of transactions

### Timestamp

Timestamps are signed 64-bit values corresponding to the number of microseconds (μsec) since the start of the epoch (which will be arbitrarily defined from some meaningful date); there is enough resolution that this value will not overflow for almost 300,000 years. Timestamps may be subtracted to calculate a duration.

One of the system variables on the Chaos Chain is `timestamp_precision`. This is a duration.

All transactions must include a timestamp. In order to be sure that transactions are accurate and processed in a timely fashion, the timestamp of the transaction must be within `timestamp_precision` of the most recent's block timestamp or the transaction will be rejected. This value is one of the system variables on the Chaos Chain. It is expected that `timestamp_precision` will be roughly equivalent to either the maximum permitted network latency or the interval between blocks, whichever is greater.

All time-based calculations, such as EAI and the like, will be done using transaction timestamps.

### Signatures

Every transaction must be signed. Signatures contain a data block, which was created by signing a hash of the transaction data with the private key corresponding to the public key of the source.

For signatures created with a private `TransferKey`, the signature only needs to contain the data block itself. the public `TransferKey` is available as part of the address state, . The signature can be verified by using that public `TransferKey`.

For signatures created with a private `OwnershipKey`, the signature must also contain the public `OwnershipKey`. The signature verification process includes generating an address from the public key and confirming that it is identical to the transaction's source address.

If a signature fails to validate, the transaction is rejected.

### Transaction Fees

Every transaction requires a transaction fee. A transaction fee may include:

- A per-byte fee; larger transactions take up more space and require a higher fee.
- A fee based on the transaction type. Different transactions incur different fees.
- For transfer transactions, a fee based on the amount transferred. Transactions of a larger number of ndau cost more.

The transaction fees are recorded on the Chaos chain as system variables that are functions written in Chain code, and are subject to adjustment by the BPC.

Every transaction has a field for transaction fees, and the fees must be exactly correct or the transaction will be rejected.

## Financial Transactions

All Financial Transactions must be signed by the Source's current `TransferKey` or they will be rejected. If the `TransferKey` is null, the transaction will be rejected.

### Transfer

Causes a transfer of a quantity of ndau from the Source account to the Target account.

*State affected:*
- Source `Balance` is reduced by the sum of `TransferAmount` and `TransactionFee` and `SIB`
- Target `Balance` is increased by `TransferAmount`
- Target `WeightedAverageAge` is updated.

*Transaction Fields:*
- `Timestamp`
- `SourceAddress`
- `TargetAddress`
- `TransferAmount`
- `TransactionFee`
- `SIB`
- `Signature`

*Validation rules:*
- Source `TransferKey` must not be null
- Target address must not be the Source address
- Source `NoticePeriod` must be zero
- Target `NoticePeriod` must be zero
- Must be signed by the Source `TransferKey`
- `SIB` must be the appropriate value based on the current SIB percentage in effect, multiplied by `TransferAmount`
- The sum of `TransferAmount`, `TransactionFee`, and `SIB` must be greater than or equal to the source `Balance`

### ChangeTransferKey

Changes the transfer key that is used for all financial transactions.

*State affected:*
- Source `TransferKey` receives a new value

*Transaction Fields:*
- `Timestamp`
- `SourceAddress`
- `NewTransferKey` -- a public key
- `TransactionFee`
- `Signature`

*Validation rules:*
- `NewTransferKey` must not be null
- `NewTransferKey` must be different from Source `TransferKey`

### Delegate

Sets `DelegationNode`, which is the address of the node that will create EAI claim transactions for this address.

*State affected:*
- Source `DelegationNode` gets a new value.

*Transaction Fields:*
- `Timestamp`
- `SourceAddress`
- `NewDelegationAddress` -- an address in standard form
- `TransactionFee`
- `Signature`

*Validation rules:*
- `NewDelegationAddress` must be a node address currently on the active node list
- `NewDelegationAddress` must be different from Source `DelegationAddress`

### LockSource

Sets `NoticePeriod` for a source; this influences EAI rates. If `NoticePeriod` is not zero, the account is said to be "locked".

*State affected:*
- `NoticePeriod` is set to `NewNoticePeriod`
- `UnlockTimestamp` is set to 0
- `WeightedAverageAge` is incremented by `NewNoticePeriod`

*Transaction Fields:*
- `Timestamp`
- `SourceAddress`
- `NewNoticePeriod` -- a duration in microseconds
- `TransactionFee`
- `Signature`

*Validation rules:*
- `DelegationNode` must be non-empty
- Source `NoticePeriod` must be less than `NewNoticePeriod`
- `NewNoticePeriod` must be at least 24 hours and no more than 5 years.

*Notes*
- What should the min/max be?
- Do we need to restrict `NewNoticePeriod` to specific values? (I don't think so)

### NotifySource

Sets `UnlockTimestamp` for a source and prevents this node from being a target of transfer transactions until `NoticePeriod` expires.

*State affected:*
- `UnlockTimestamp` is set to transaction `Timestamp` plus Source `NoticePeriod`
- Source `WeightedAverageAge` is updated.

*Transaction Fields:*
- `Timestamp`
- `SourceAddress`
- `TransactionFee`
- `Signature`

*Validation rules:*
- Source `NoticePeriod` must be nonzero
- Source `UnlockTimestamp` must be zero

### SetRewardsTarget

Sets `RewardsTarget` for a source; this directs this account's reward transactions to a different address.

*State affected:*
- `RewardsTarget` is set to `NewRewardsTarget`

*Transaction Fields:*
- `Timestamp`
- `SourceAddress`
- `NewRewardsTarget` -- the address of the rewards target, or 0. If `NewRewardsTarget` is the same as the Source address, `RewardsTarget` is set to 0.
- `TransactionFee`
- `Signature`

*Validation rules:*
- `NewRewardsTarget` must be different than Source `RewardsTarget`

### StakeToTarget

Sets `StakeTarget` for a source; this is an identifier of the node to which this address is staked; it may be its own address, in which case the address is said to be "self-staked". A staked node can participate in node rewards for. Target may be null, which unstakes the source (making it ineligible for node rewards but eligible for notification).

*State affected:*
- `StakeTarget` is set to `NewStakeTarget`

*Transaction Fields:*
- `Timestamp`
- `SourceAddress`
- `NewStakeTarget` -- the address of the stake target, or 0 to unstake. It is permissible for `NewStakeTarget` to be the same as the Source address.
- `TransactionFee`
- `Signature`

*Validation rules:*
- `NewStakeTarget` must be different from the current value of Source `StakeTarget`
- `NoticePeriod` must be greater than `system.MinimumNoticePeriod`
- `UnlockTime` must be zero
If this is nonzero, `NoticePeriod` must have a minimum value AND `UnlockTime` must be zero.

## Transaction Validation

All ndau transactions must be signed with the `TransferKey` currently associated with the transaction's source account. That key must first be set by a *Set Initial Transfer Key* transaction after an account has been created by a transfer of ndau to its address. It may be modified by a *Change Transfer Key* transaction at any point after the initial key has been set.

An account may also have an optional `ValidationScript` attached to it. If such a script exists, it is used to provide further control over the validity of a transaction. Once the transaction's signature has been validated, this script is executed by the Chaincode VM. If it returns ```TRUE``` the transaction is considered valid; any other return value causes the transaction validation to fail.

The validation script runs in a sandboxed VM with limited access to the current state of the blockchain. The current `Transaction` and source `Account` attributes are pushed on the stack before the Chaincode script is run, but no other information is provided. Chaincode scripts may only modify values on their own stack within their current VM context, and may only return values by leaving them on that stack.

Both the validation script and the transaction signature check must be valid for the transaction to be considered valid, and the validation script is not executed if the transaction signature is not correct.

## Validation Script Transactions

Validation scripts are properties of accounts: at any time an account may have either one validation script or no script at all. An account with no validation script only require standard transaction signature validation.

* *Set Initial Transfer Key:* This transaction sets the account's initial transfer key. It may also optionally specify the account's initial validation script. Accounts intended to be controlled by a validation script should have that script set atomically in this transaction along with the initial transfer key: otherwise all transactions will be permitted.
* *Change Validation Script:* Replaces the account's current validation script with a new script or a null script. If the current validation script is null, the new script is simply assigned to the account. Accounts controlled with a validation script should ensure that proper protection is given to this transaction to prevent unauthorized changes to it.

## Example Validation Scripts

Chaincode is a stack-based assembler that runs in a per-instance virtual machine. It may be used in other contexts beyond transaction validation: it is documented separately.
 
Node operator features

### Active node requirements

1. Any device may begin to operate as an ndau network node. An ndau network node can monitor the ndau blockchains and submit transactions.

2. A node becomes an active node once it has staked ndau to its node address ("self-staking"). Staked ndau may be forfeited due to poor node behavior. [See note 2]

3. Other addresses may also be staked to a node address ("co-staking").

4. Nodes will be ranked by an overall quality/resiliency score based on the node's total stake (self-stake and co-stake) and other criteria.

5. The highest-ranked nodes will be selected to serve as validator nodes in the consensus mechanism.

### Computation and granting of node operations rewards

1. All transaction fees and network operation fees (currently 10% of EAI) since the last node rewards nomination are added to a node rewards pool.

2. When the node rewards pool is to be awarded, a node rewards nomination is posted identifying the node entitled to claim that pool. [See note 3]

3. The nominated node must respond and claim the node rewards pool within a specified time limit. If the pool is not claimed in time, the entire pool is forfeited and the ndau in it are burned.

4. Other EAI fees (4% Ecosystem Funding fee, 1% Market Maker Price Discovery fee) accrued since the last successful node claim are transferred to the appropriate recipient addresses as part of the node rewards claim transaction.

5. A node receiving a node rewards pool is expected to distribute a portion of it to addresses co-staked to it. The distribution criteria are to be specified by the node operator and published so address holders can use that information in their decision whether to co-stake to any particular node.

# Major open issues needing further discussion

1. The details of the SIB mechanism and its implementation are not yet resolved. At MVP, ndau will not be traded on exchanges, so a Market Price cannot be calculated and therefore the SIB cannot be in effect.

2. The details of self-staking and co-staking need further specification. The mechanisms for slashing self-stake and co-stake for undesirable or malicious behavior have not been discussed. At MVP, self-staking will require a trivial stake and that stake will not be slashed. Oneiro will operate all nodes and all ndau holders must assume that all nodes can be trusted.

3. The final mechanism for distribution of node rewards among active nodes, validator nodes, block preparer node, etc. is not yet resolved. At MVP, Oneiro will operate all nodes (and therefore receive all node rewards) so the distribution mechanism may still change without affecting node operators.
