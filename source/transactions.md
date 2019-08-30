Transactions - ndau API
===

Transactions are submitted to and retrieved from the ndau blockchain through the ndau API: all transaction input and output data is in JSON format. When a transaction is committed a unique transaction hash is generated for it, and that hash can be used to query the API for the details of that transaction.

Data Types
---

| Data Type | Description |
|-----------|-------------|
|string|A string|
|int|An integer (in base 10)|
|duration|A period of time in microseconds (10<sup>-6</sup> seconds)|
|napu|A quantity of ndau in napu (10<sup>-8</sup> ndau)|
|nanocent|A quantity of USD in nanocents (10<sup>-11</sup> US Dollars)|
|address|An account address in ndau text format|
|publickey|A secp256k1 or ed25519 public key in ndau text format|
|signature|A secp256k1 or ed25519 signature in ndau text format|

Some JSON fields are _lists_ of parameters and are indicated with a `[]` prefix (such as `[]signatures`). Fields specified as
lists must always be represented as lists even if they hold only a single value. Multiple values in a list are separated by commas.

To avoid rounding and precision errors created by different client environment, all ndau values are expressed as integers. There are never any floating point values in ndau transactions.

Submitting transactions
---
Each transaction is submitted in JSON format using the "json" fields shown below for each transaction. These names are longer and more descriptive than the compact format stored on the blockchain. Transactions may be prevalidated using the `/tx/prevalidate/:txname` endpoint before being submitted. Prevalidation ensures the transaction is valid and is properly signed, and it returns the transaction's hash and any fees that will be charged for it when it is submitted. Any errors are indicated by an error code and a descriptive message. A valid transaction is submitted to the API with the `/tx/submit/:txname` endpoint.

Querying transactions
---
Transaction details can be retrieved by specifying the unique hash returned by the API when the transaction was submitted. Each transaction type returns a unique set of fields. In the descriptions below, the "msg" fields are the labels used for each field in the returned JSON. The transaction type is identified by the `TransactableID` field: these are the ID values associated with each transaction type.
```
 1 Transfer
 2 ChangeValidation
 3 ReleaseFromEndowment
 4 ChangeRecoursePeriod
 5 Delegate
 6 CreditEAI
 7 Lock
 8 Notify
 9 SetRewardsDestination
10 SetValidation
11 Stake
12 RegisterNode
13 NominateNodeReward
14 ClaimNodeReward
15 TransferAndLock
16 CommandValidatorChange
18 UnregisterNode
19 Unstake
20 Issue
21 CreateChildAccount
22 RecordPrice
23 SetSysvar
24 SetStakeRules
25 RecordEndowmentNAV
26 ResolveStake
30 ChangeSchema
```
<<<<<<< HEAD:source/transactions.md

Mainnet and Testnet
===
The ndau mainnet and testnet are accessible to the public. Each node on each network is identified with a unique numeric ID given as "<N>" here:
Mainnet: https://mainnet-<N>.ndau.tech:3030
Testnet: https://testnet-<N>.ndau.tech:3030
The ndau API is available on all nodes in either network.
=======
<<<<<<< Updated upstream:transactions.md
Each transaction type returns a unique set of information. In the descriptions below, the "msg" fields are the labels used in the returned JSON
to identify each parameter. The "json" fields are the labels used for each parameter in the JSON input to the
`/tx/submit` and `/tx/prevalidate` endpoints.
=======

Mainnet and Testnet
===
The ndau mainnet and testnet are accessible to the public. Each node on each network is identified with a unique numeric ID (given as 0 here):

Mainnet: [https://mainnet-0.ndau.tech:3030](https://mainnet-0.ndau.tech:3030) \
Testnet: [https://testnet-0.ndau.tech:3030](https://testnet-0.ndau.tech:3030)

The ndau API is available on all nodes in either network.
>>>>>>> Stashed changes:source/transactions.md
>>>>>>> master:transactions.md

Examples
===

Submittal
---
A transaction is submitted with an HTTP POST to `/tx/submit/:txtype` where `:txtype` is the name of the transaction type from the table above. The transaction JSON is submitted as described below. This example transfers 10 ndau from one account to another.
URL: `https://mainnet-0.ndau.tech:3030/tx/submit/transfer`

JSON:
```
{
	"source": "ndak9vpyz58fjpa4kg6gei3p9nch8jbf9iyszhg8mw8ump7q",
	"destination": "ndam5m7qpznkbczn8ewc39iqdd32gama785jkkrp3nxy9jre",
	"qty": 1000000000,
	"seq": 203,
	"signatures": ["ayjaftcggbcaeib6ehzcwu7t85svchaj5kp6xhu5vmhrky25z7jfcwni3thp2evrrebcaz3vv5pn5hwtm5puecfj6w5s74iy64mji4wmawzefwxp5qbew9yjs56aqieb"]
}
```

Returns:
```
{
	"fee_napu": 1000000,
	"sib_napu": 0,
	"err": "Err and ErrCode are only set if an error occurred",
	"hash": "pAe0XAfcuiMwFlC4EQ8ftg",
	"msg": "only set if additional information is available",
	"code": 0
}
```

Query
---
A transaction query returns complete information about the transaction and information about the block on the ndau blockchain in which it is found. The transaction-specific information is in the `TransactableID` and `Transactable` fields.  For example, using the transaction hash returned from the above transfer submittal:

URL: `https://mainnet-0.ndau.tech:3030/transaction/pAe0XAfcuiMwFlC4EQ8ftg`

Returns:
```
{
  "BlockHeight": 13919,
  "TxOffset": 0,
  "Tx": {
    "Nonce": "arqilpepEempMQJCrBEAAg==",
    "TransactableID": 1,
    "Transactable": {
      "src": ["ndak9vpyz58fjpa4kg6gei3p9nch8jbf9iyszhg8mw8ump7q"],
      "dst": ["ndam5m7qpznkbczn8ewc39iqdd32gama785jkkrp3nxy9jre"],
      "qty": 1000000000,
      "seq": 203,
      "sig": [[2, "MEQCIDwh7ipLsfbhMRwJ2pvKnluazvVbG79SUVGIzE7cEm95AiBfM57azZ6RXtsiCKnlNw7pFuaWlGqLBS5C0q3bgkp+yQ=="]]
    }
  }
}
```
Because TxOffset is 0, the transaction is the first transaction in block 13919 on the ndau blockchain. `TransactableID` is `1`, so it is a `Transfer` transaction.

Account management transactions
===

Transfer
---
Transfers ndau from one account to another. The source account must be unlocked and have a sufficient available balance to pay for the transfer and any fees. The destination account may be locked or unlocked but may not be in its unlock countdown period.
```
{
	Source      address       `msg:"src" json:"source"`,
	Destination address       `msg:"dst" json:"destination"`,
	Qty         napu          `msg:"qty" json:"qty"`,
	Sequence    int           `msg:"seq" json:"sequence"`,
	Signatures  []signature   `msg:"sig" json:"signatures"`
}
```
SetValidation
---
Establishes the initial validation rules (script and keys) for an account. This transaction is signed with the account's ownership key.
```
{
	Target           address     `msg:"tgt" json:"target"`,
	Ownership        publickey   `msg:"own" json:"ownership"`,
	ValidationKeys   []publickey `msg:"key" json:"validation_keys"`,
	ValidationScript string      `msg:"val" json:"validation_script"`,
	Sequence         int         `msg:"seq" json:"sequence"`,
	Signature        signature   `msg:"sig" json:"signature"`
}
```
ChangeValidation
---
Changes the validation rules (script and keys) for an account.
```
{
	Target           address      `msg:"tgt" json:"target"`,
	NewKeys          []publickey  `msg:"key" json:"new_keys"`,
	ValidationScript string       `msg:"val" json:"validation_script"`,
	Sequence         int          `msg:"seq" json:"sequence"`,
	Signatures       []signature  `msg:"sig" json:"signatures"`
}
```
Lock
---
Locks an account for the specified countdown period. Locked accounts may not be the source of `Transfer` transactions, but their balance
may be used to pay fees for other transactions.
```
{
	Target     address      `msg:"tgt" json:"target"`,
	Period     duration     `msg:"per" json:"period"`,
	Sequence   int          `msg:"seq" json:"sequence"`,
	Signatures []signature  `msg:"sig" json:"signatures"`
}
```
Notify
---
Gives notice to unlock an account. After the account's countdown period expires, the account is unlocked. Accounts in their
countdown period may not be the source or destination of `Transfer` transactions.
```
{
	Target     address      `msg:"tgt" json:"target"`,
	Sequence   int          `msg:"seq" json:"sequence"`,
	Signatures []signature  `msg:"sig" json:"signatures"`
}
```
Delegate
---
Delegates the responsibility for crediting account's EAI to an active ndau network node. An account may be delegated or
redelegated at any time, but does not earn EAI unless it is delegated.
```
{
	Target     address      `msg:"tgt" json:"target"`,
	Node       address      `msg:"nod" json:"node"`,
	Sequence   int          `msg:"seq" json:"sequence"`,
	Signatures []signature  `msg:"sig" json:"signatures"`
}
```
ChangeRecoursePeriod
---
Changes the account's recourse period, the time between a `Transfer` transaction and the addition of the transferred amount to
the destination account's available balance.
```
{
	Target     address      `msg:"tgt" json:"target"`,
	Period     duration     `msg:"per" json:"period"`,
	Sequence   int          `msg:"seq" json:"sequence"`,
	Signatures []signature  `msg:"sig" json:"signatures"`
}
```
SetRewardsDestination
---
Set the destination account for redirecting EAI and node rewards. If a rewards destination is not
set, EAI and node rewards will be credited directly to the account earning them.
```
{
	Target      address      `msg:"tgt" json:"target"`,
	Destination address      `msg:"dst" json:"destination"`,
	Sequence    int          `msg:"seq" json:"sequence"`,
	Signatures  []signature  `msg:"sig" json:"signatures"`
}
```
TransferAndLock
---
Transfers ndau to a newly-created account and locks it for the specified period. Its effect is identical to that of a
`Transfer` transaction followed by a `Lock` transaction from the destination account. The destination account may not exist on
the ndau blockchain prior to this transaction.
```
{
	Source      address      `msg:"src" json:"source"`,
	Destination address      `msg:"dst" json:"destination"`,
	Qty         napu         `msg:"qty" json:"qty"`,
	Period      duration     `msg:"per" json:"period"`,
	Sequence    int          `msg:"seq" json:"sequence"`,
	Signatures  []signature  `msg:"sig" json:"signatures"`
}
```
CreateChildAccount
---
Creates a "child" account and specifies the account's initial validation rules, recourse period, and the node delegated to
credit the account's EAI. Used to propagate the properties of special account types to newly-created accounts.
```
{
	Target                address     `msg:"tgt"  json:"target"`,
	Child                 address     `msg:"chd"  json:"child"`,
	ChildOwnership        publickey   `msg:"cown" json:"child_ownership"`,
	ChildSignature        signature   `msg:"csig" json:"child_signature"`,
	ChildRecoursePeriod   duration    `msg:"cper" json:"child_recourse_period"`,
	ChildValidationKeys   []publickey `msg:"ckey" json:"child_validation_keys"`,
	ChildValidationScript string      `msg:"cval" json:"child_validation_script"`,
	ChildDelegationNode   address     `msg:"nod"  json:"child_delegation_node"`,
	Sequence              int         `msg:"seq"  json:"sequence"`,
	Signatures            []signature `msg:"sig"  json:"signatures"`
}
```
Staking transactions
===
SetStakeRules
---
Defines a set of chaincode stake rules by associating them with a stake rules account.
```
{
	Target     address     `msg:"tgt" json:"target"`,
	StakeRules string      `msg:"krs" json:"stake_rules"`,
	Sequence   int         `msg:"seq" json:"sequence"`,
	Signatures []signature `msg:"sig" json:"signatures"`
}
```
Stake
---
Stakes ndau to a specified set of stake rules by either staking directly to a stake rules account (primary stake) or by
staking to a primary stake account (co-stake).
```
{
	Target     address       `msg:"tgt" json:"target"`,
	Rules      address       `msg:"rul" json:"rules"`,
	StakeTo    address       `msg:"sto" json:"stake_to"`,
	Qty        napu          `msg:"qty" json:"qty"`,
	Sequence   int           `msg:"seq" json:"sequence"`,
	Signatures []signature   `msg:"sig" json:"signatures"`
}
```
Unstake
---
Revokes ndau previously staked. The right to unstake ndau is governed by the rules established in the stake rules account.
```
{
	Target     address       `msg:"tgt" json:"target"`,
	Rules      address       `msg:"rul" json:"rules"`,
	StakeTo    address       `msg:"sto" json:"stake_to"`,
	Qty        napu          `msg:"qty" json:"qty"`,
	Sequence   int           `msg:"seq" json:"sequence"`,
	Signatures []signature   `msg:"sig" json:"signatures"`
}
```
ResolveStake
---
Resolves a stake by releasing all or part of it. Any portion (including all) of the stake may be burned instead of being
released back to the staking account. The amount released is unstaked: the staking account does not need to submit an `Unstake`
transaction. This transaction can only be submitted in accordance with the stake rules.
```
{
	Target     address       `msg:"tgt" json:"target"`, primary staker
	Rules      address       `msg:"rul" json:"rules"`,
	Burn       int           `msg:"brn" json:"burn"`,
	Sequence   int           `msg:"seq" json:"sequence"`,
	Signatures []signature   `msg:"sig" json:"signatures"`
}
```
Node operations transactions
===
RegisterNode
---
Registers a node as an active node on the ndau blockchain, eligible to receive node rewards and to be promoted to a
validator node. The node account must already be successfully staked to the node operations stake rules account.
```
{
	Node               address     `msg:"nod" json:"node"`,
	DistributionScript string      `msg:"dis" json:"distribution_script"`,
	Ownership          publickey   `msg:"own" json:"ownership"`,
	Sequence           int         `msg:"seq" json:"sequence"`,
	Signatures         []signature `msg:"sig" json:"signatures"`
}
```
UnregisterNode
---
Removes an ndau network node from active status.
```
{
	Node       address     `msg:"nod" json:"node"`,
	Sequence   int         `msg:"seq" json:"sequence"`,
	Signatures []signature `msg:"sig" json:"signatures"`
}
```
CreditEAI
---
Credits EAI to all accounts delegated to a node. This transaction is submitted by the registered node account.
```
{
	Node       address     `msg:"nod" json:"node"`,
	Sequence   int         `msg:"seq" json:"sequence"`,
	Signatures []signature `msg:"sig" json:"signatures"`
}
```
ClaimNodeReward
---
Claims a node's node reward after it has been nominated to receive it by a `NominateNodeReward` transaction.
The reward must be claimed by the active node within a short time period or it will be burned.
```
{
	Node       address     `msg:"nod" json:"node"`,
	Sequence   int         `msg:"seq" json:"sequence"`,
	Signatures []signature `msg:"sig" json:"signatures"`
}
```
System transactions
===
ReleaseFromEndowment
---
Releases ndau from the Axiom Foundation Endowment. These new ndau are available to be issued into circulation, but are not
yet in circulation or used in any ndau blockchain calculations.

This transaction is validated by the signature rules of the account specified in the
system variable `ReleaseFromEndowmentAddress`. That account pays the transaction fee.
```
{
	Destination address      `msg:"dst" json:"destination"`,
	Qty         napu         `msg:"qty" json:"qty"`,
	Sequence    int          `msg:"seq" json:"sequence"`,
	Signatures  []signature  `msg:"sig" json:"signatures"`
}
```
Issue
---
Issues ndau previously released from the Axiom Foundation Endowment into circulation.

This transaction is validated by the signature rules of the account specified in the
system variable `ReleaseFromEndowmentAddress`.  That account pays the transaction fee.
```
{
	Qty        napu        `msg:"qty" json:"qty"`,
	Sequence   int         `msg:"seq" json:"sequence"`,
	Signatures []signature `msg:"sig" json:"signatures"`
}
```
RecordEndowmentNAV
---
Records the current Net Asset Value of the Axiom Foundation Endowment. This data is used to calculate whether SIB is in effect and, if so, what the current SIB fee is.

This transaction is validated by the signature rules of the account specified in the
system variable `ReleaseFromEndowmentAddress`.  That account pays the transaction fee.
```
{
	NAV        nanocent    `msg:"nav" json:"nav"`,
	Sequence   int         `msg:"seq" json:"sequence"`,
	Signatures []signature `msg:"sig" json:"signatures"`
}
```
RecordPrice
---
Records the current market price of ndau. This value is used to calculate whether SIB is in effect and, if so, what the current
SIB fee is.

This transaction is validated by the signature rules of the account specified in the
system variable `RecordPriceAddress`.  That account pays the transaction fee.
```
{
	MarketPrice nanocent    `msg:"prc" json:"market_price"`,
	Sequence    int         `msg:"seq" json:"sequence"`,
	Signatures  []signature `msg:"sig" json:"signatures"`
}
```
NominateNodeReward
---
Nominates the node eligible to receive the currently-available node rewards. The nominated node must claim its
reward within a short time period or it will be burned.

This transaction is validated by the signature rules of the account specified in the
system variable `NominateNodeRewardAddress`.  That account pays the transaction fee.
```
{
	Random     int         `msg:"rnd" json:"random"`,
	Sequence   int         `msg:"seq" json:"sequence"`,
	Signatures []signature `msg:"sig" json:"signatures"`
}
```
SetSysvar
---
Sets a system variable.

This transaction is validated by the signature rules of the account specified in the
system variable `SetSysvarAddress`.  That account pays the transaction fee.
```
{
	Name       string      `msg:"nme" json:"name"`,
	Value      string      `msg:"vlu" json:"value"`,
	Sequence   int         `msg:"seq" json:"sequence"`,
	Signatures []signature `msg:"sig" json:"signatures"`
}
```
CommandValidatorChange
---
Changes a node's "power". All nodes with power greater than zero are part of the validator set.

This transaction is validated by the signature rules of the account specified in the
system variable `CommandValidatorChangeAddress`.  That account pays the transaction fee.
```
{
	Power      int         `msg:"pow" json:"power"`,
	Sequence   int         `msg:"seq" json:"sequence"`,
	Signatures []signature `msg:"sig" json:"signatures"`
}
```
ChangeSchema
---
Triggers an ndau node to shut down. Used to enable versioned upgrades which change the ndau blockchain's database schema.

This transaction is validated by the signature rules of the account specified in the
system variable `ChangeSchemaAddress`.  That account pays the transaction fee.
```
{
	SchemaVersion string      `msg:"sav" json:"schema_version"`,
	Sequence      int         `msg:"seq" json:"sequence"`,
	Signatures    []signature `msg:"sig" json:"signatures"`
}
```
