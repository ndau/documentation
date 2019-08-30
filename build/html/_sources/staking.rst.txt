Staking
#######

## Definitions

**Staking** - Placing a quantity of ndau at risk to either guarantee future performance or guard against fraudulent/unethical actions. Staked ndau may not be transferred from the staked account.

**Stake** - The quantity of ndau at risk.

**Co-stake** - ndau staked to another account for the same purpose and subject to the same staking criteria. Co-staking adds support to the primary staker. 

**Primary Stake** - ndau staked on behalf of its own account. Primary stake is sometimes referred to as “self-stake” if there is any ambiguity. The account associated with primary stake is associated with the entity whose performance and/or actions are being secured. 

**Rules Account** - An account specifying a set of programmatic rules establishing the parameters of a staking arrangement and the validation rules for taking actions on it. The Staking Rules do not adjudicate the stake (i.e. they’re not a smart contract of any sort): the signatories of the Rules Account sign transactions implementing their decisions.

Anyone may convert any of their normal accounts into a Rules Account by submitting a `SetRules` transaction specifying the rules to be used. There are certain predefined Rules Accounts specified for BPC members, node operations, and transfer dispute resolution.

**Unstaking** - Releasing a staked quantity of ndau. The transaction is not valid unless the account meets the criteria specified by the Rules Account. Additional criteria  may be imposed, such as a time period after the unstaking event before the staked ndau are released and may be transferred.

**Resolving Stake** - An action taken by the signatories of the Rules Account. Resolving stake may burn none, some, or all of the stake. The remainder is unstaked immediately and is again spendable in the staker’s account.

*Note:* In many respects staking resembles the posting of a performance bond. A performance bond, however, provides financial compensation to a second party should a first party fail to meet its performance obligations. If the first party meets those obligations the bond is returned. Staking, however, never transfers ndau to a second (or any other) party - it is either burned or returned. If a second party is to receive some compensation it must be provided through other means.

## Staking Transactions
1. `Stake`, establishing the parameters of the stake and staking a quantity of ndau.
2. `Unstake`, by which the staker releases the stake.
3. `ResolveStake`, by which various actions may be taken to affect the state of the stake before releasing it.
4. `SetStakeRules`, which establishes or removes a rules account.


## Staking Rules

The Rules Account specifies additional rules governing the `Stake` and `Unstake` transactions of accounts staked to it. Transactions submitted by the account staking to it must be validated by the overlaid Staking Rules after being validated by the submitting account itself. The staking rules are in addition to the normal validation rules for the `Stake` and `Unstake` transactions, and are evaluated after the transaction is determined to be otherwise valid. These rules may govern, for example:


- **Minimum stake** - The minimum quantity of staked ndau required
- **Maximum stake** - The maximum quantity of staked ndau permitted
- **Staking period** - The time period after unstaking before the stake amount is released
- **Revocable** - Can the original staker unilaterally unstake?
- **Co-stake** - May other accounts stake to the original staker?
- **Timeout** - Will the stake be automatically released after a certain time has elapsed?

Staking rules are expressed as chaincode. As with validation rules, the `EVENT_STAKE` and `EVENT_UNSTAKE` event handlers are used. As with validation rules, a return value of 0 indicates that the transaction is valid, and anything else indicates that the transaction is invalid.

Rules accounts have special handling for `EVENT_RESOLVE_STAKE`: given appropriate context including the total stake, these rules return an integer. This is the quantity of napu deducted from the primary staker and transferred to the rules account before performing any other calculations. 

Sufficient context is provided for staking rules to distinguish between a primary staker and a co-staker. The staking account and any co-staking accounts may be treated differently when stake is resolved


## Staking Mechanics

`**Stake**` **Transaction**
The `Stake` tx has the following fields:

- `Target`: the address of an account to stake
- `Rules`: the address of the account defining the staking rules 
- `StakeTo`: the same `Rules` address for a primary stake, or the address of any other account to co-stake to it.
- `Qty`: the amount of ndau to stake
- `Sequence`, `Signatures`: as normal

The `Stake` transaction has relatively complicated semantics, because we need to support complicated use cases. It is helpful to begin by enumerating some use cases:

- An account may stake less than its total balance
- An account may stake multiple times
- An account may stake multiple times to itself
- An account may stake multiple times to another account
- An account may co-stake to multiple other accounts
- An account’s total effective stake may be increased by the cooperation of co-stakers.
- Depending on the staking rules and current stake status, an account may or may not accumulate further co-stakers.
- Depending on the staking rules and current stake status, an account may or may not be allowed to unstake.

In order to support these use cases, `Stake` has the following semantics:

- When `StakeTo != Rules`, this is a **Co****-****stake**. `StakeTo` designates the account being staked to. `Rules` designates the staking rules being imposed.
- Co-staking is allowed when the `StakeTo` account is not itself currently staked.
- Co-staking may or may not be allowed, depending on the `Rules` account, when the `StakeTo` account is currently staked.
- When `StakeTo == Rules`, this is a **Primary Stake**. This imposes the stake, subjecting the primary staker and all co-stakers to the specified staking rules.. See `Unstake` semantics for details.
- The `Target` account must contain at least `Qty` spendable ndau.
- When the transaction is valid, `Qty` ndau are marked in persistent internal state as unspendable.
- There is only one level of indirection: if `P` is a primary staker to `R`, and `A` submits `Stake` with `StakeTo: P; Rules: R`, it is a costaker of `P` to `R`. If `B` submits `Stake` with `StakeTo: A; Rules: R`, the transaction will succeed, but it is *not* a costaker of `P` to `R`. The transaction succeeds because it is legal for `A` to later become a primary staker to `R` in its own right. 
- No primary staker may have more than one primary stake to the same rules account.
- All accounts staked to a primary staker for the same purpose (same Rules Account) will be co-staked together when the primary stake is established.

`**Unstake**` **Transaction**
`Unstake` has the same fields as `Stake`. It has the following semantics:

- `Target`, `Rules`, `StakeTo`, and `Qty` must match a previous `Stake` tx exactly. 
- If the previous stake was a co-stake, and the `StakeTo` account has not yet staked, the transaction is valid.
- Otherwise, the transaction is valid if the `Rules` chaincode allows it. 
- If `Target` is the primary staker, the resolution of `Unstake` also applies to all co-stakers. 
- The `Rules` chaincode may impose a delay on a valid `Unstake` transaction. 
- If `Unstake` is valid and there is no delay, the first unspendable `Qty` ndau in `Target` for which `StakeTo` and `Rules` match and which is not already marked with an expiration date are immediately marked as spendable.
- If `Unstake` is valid and there is a delay, the first unspendable `Qty` ndau in `Target` for which `StakeTo` and `Rules` match and which are not already marked with an expiration date are given an expiration date: the current block time plus the delay. 
- Unspendable ndau with an expiration timestamp are spendable from that timestamp and will be automatically removed from the unspendable list in the first transfer past that block time.

`**ResolveStake**` **Transaction**
`ResolveStake` transactions are not submitted by primary stakers or co-stakers: they are submitted and signed by Stake Rules accounts. As the name suggests, they resolve the stake.

Most of the time, for stakers who have performed as expected, `ResolveStake` will not be required: they will `Unstake` at an appropriate time, and after an appropriate delay, will have their stake spendable again. `ResolveStake` is mainly for slashing the stake of misbehaving individuals and their co-stakers, and for dispute resolution. 

These are *not* in any way smart contracts. They instead implement decisions made by humans about the actual performance and/or behavior observed by the primary staker. They do not cause any action to be taken to further resolve the situation (such as transferring ndau from one account to another).

`ResolveStake` has the following fields:

- `Staker`: address of primary staker
- `Burn`: an integer between 0 and 255: the percentage of staked ndau which is burned. This is usually only non-0 in the event of staker misbehavior.
- `Sequence`, `Signatures`: as normal

`ResolveStake` has the following semantics:

- If `Burn>``2``55`, the transaction is invalid
- The transaction resolves the stake one way or another. There is no recourse past this point. Once the transaction resolves, the appropriate staked ndau are either burned, or they are released and are immediately spendable.

**State Updates**

We need to track some additional data to support this. 

`Settlements` should be renamed to `Holds`. Each hold must grow some additional fields:
`TxHash *string`, `StakeData` (type TBD). `Expiry` must change to be possibly nil. 

## Actions Requiring Stake

Although actions such as registering an active node require stake placed under the appropriate Rules Account, the act of staking itself does not take that action. Likewise, unstaking does not undo it. The transactions involved that require stake must check that it exists and determine its disposition.

**Example 1 - Running an Active Node**
Stake is required to run an active node. The account intending to become an active node must be the primary staker to the appropriate account. The `RegisterNode` transaction checks that the account submitting it is staked as the primary staker to the appropriate Staking Rules account. 

After submitting a `RegisterNode` transaction, the account may not be unstaked. (This is an additional constraint not related to the staking rules of the node operations account) The `UnregisterNode` transaction removes the account from the set of active nodes and flags the `Unstake` transaction as being permitted. The account may then be unstaked or may be left staked if the node operator intends to submit another `RegisterNode` transaction soon. 

Co-stakers may submit `Unstake` transactions at any time, even while the staked account is still a registered node. Co-staked accounts remain subject to slashing for the required period after the `Unstake` transaction (not after the `UnregisterNode` transaction).

The Rules Account in this case is expected to have rules which impose a minimum total stake for `Stake`, and a constant hold period for `Unstake`. 

**Example 2 - Serving as a BPC Delegate**
Stake is required to serve as a BPC Delegate. The signatories authorized to add a member to the list of current BPC Delegates must first (manually) confirm that that candidate has staked an account to the Staking Rules account for BPC Delegates. That staked account’s address should be posted publicly and associated with the public key identifying the member (perhaps that public key must be a validation key for the staked account, but that is a rule imposed by humans, not the blockchain). The account may not be unstaked during the member’s term. 

The Rules Account in this case is expected to have rules which impose both a minimum and maximum total stake for `Stake`, prohibit co-staking after the primary stake is established, and prohibit `Unstake` before a hard-coded timestamp corresponding with the term limit. Once `Unstake` is allowed, it is expected to have a fairly long delay before the associated ndau may be spent.


----------

Dispute resolution is hard. The rest of this document is still very much under development, but I think we’re at the point where the staking mechanisms described above are suitable.

**Example 3 - Disputing a Transfer Transaction**
Stake is required under the Staking Rules for a dispute. The stake is not revocable but has a timeout period during which the dispute must be resolved. A separate `Dispute` transaction (of some sort) specifies the transaction ID being disputed. The transaction must be a `Transfer` transaction whose recourse period has not expired. This transaction extends the hold period on the disputed transfer to a standard time period for resolution. The amount in dispute is not the stake - the stake must be funded from another source.

The signatories on the Staking Rules account (the adjudicators), after examining the facts of the case, will eventually issue a `ResolveDispute` transaction. That transaction will either release the hold on the transferred amount or remove it from the original destination account and deposit it in the  original source account, where it is immediately spendable. A `ResolveStake`  transaction can be submitted separately by the adjudicators to either return or burn the disputer’s stake. 

The Rules Account in this case is expected to have rules which restrict `Unstake`.

# Recourse requests on ndau

This is a proposal for handling recourse requests for ndau transfer transactions that have not yet settled. It depends on some expected behaviors for staking (note: this is pasted in from another document, and is intended for reference while settling on the real staking implementation design)


## General principles:
- One disputes transactions, not accounts
- A dispute transaction can name multiple transactions but they must all have the same source
- A dispute may not name a transaction that has already settled
- Disputes may be filed from any account
- Disputes require staking a bond which has a minimum absolute value as well as a minimum percentage


## Scenario

X notices a transaction on an account that was not authorized.

During the period before X's recourse period has expired, X submits a RecourseClaim transaction. This document describes what happens then.


## RecourseClaim fields
- Authority, which is the ndau address of the dispute authority being consulted; this authority account must have Stake Rules regarding dispute resolution. 
- Transactions, a list of Tx IDs being disputed; there must be at least one (do we need/want a max)?
- The amount being staked to back the dispute (this is staked from the account signing the tx)
- The dispute duration, which must be in the range of dispute durations permitted by the named authority.


## Validity

If the RecourseClaim is valid on its face, the following happens:

For each disputed transaction:

- The unresolved transaction is marked as staked rather than in the recourse period
- The expiry time on the transaction is set to the current time plus the dispute duration
- The target of the dispute stake is set to the source of the original transaction (so that a ResolveStake transaction can return the funds if that’s how it goes)
- The dispute bond is staked with the same dispute duration
- The dispute bond’s stake target is set to the authority's address

The disputant (source of the dispute) must follow up off-blockchain with documentation of 
details of the dispute. The details should include a reference back to the RecourseClaim transaction ID.  (This can be mediated by a wallet app)

The target of the dispute (disputee) may also respond off-blockchain with additional information. (This can also be mediated by a wallet app). (Should we let the disputee also file a Stake transaction as a way of indicating their sincerity here?)


## Results

One of three things can happen:

1. The dispute authority takes no action before the dispute duration expires. This is a de-facto resolution in favor of the disputee; the original transaction completes and the bond stake expires and is burned (since the authority did nothing, it gets no fee).
2. The authority rules in favor of the disputant; it files a ResolveStake transaction where the amount is returned to the disputant. It also files a ResolveStake transaction in favor of the disputant on the bond, which returns the fee to the disputant.
3. The authority rules in favor of the disputee; it files ResolveStake in favor of the disputee, and the transaction immediately resolves. It also files a ResolveStake transaction against the disputant for the bond (the bond is forfeited).

