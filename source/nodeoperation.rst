Node operation
==============
Reliability
___________
Staking
_______
Node rewards
____________


NDAU NODE OPERATIONS MANUAL
THE NDAU BLOCKCHAIN NETWORK
The ndau digital currency is secured by a unique combination of blockchains: the ndau blockchain for currency transactions and the chaos blockchain for storing related information as key-value pairs. ndau Network Nodes track and support both blockchains 
NDAU BLOCKCHAIN
The ndau blockchain is the primary means by which client applications manage the ndau digital currency. It provides traditional digital currency transactions such as transfers and multi-signature security as well as a number of new transactions supporting ndau’s unique features. These include account locking and notification, settlement periods, staking, and the release of new ndau currency from the Endowment.
CHAOS BLOCKCHAIN
The chaos blockchain provides a storage system for key-value pairs of unstructured information. Each ndau account has a unique namespace for this storage, and there are no restrictions on the type of information that can be stored. The Blockchain Policy Council (BPC) publishes a set of system variables on the chaos chain in a dedicated namespace for that purpose. These variables control various rates and fee schedules, node operations settings, and other ndau operations parameters.
TENDERMINT CONSENSUS NETWORK
Both the ndau and chaos blockchains are secured by the Tendermint Byzantine Fault Tolerant State Machine Replication consensus network. All ndau Network Nodes run a Tendermint server for this purpose: a subset of those nodes comprises the validator set for updating these blockchains.
https://github.com/tendermint/tendermint

OTHER NETWORK NODE SERVERS
NOMS
Each ndau Network Node is responsible for maintaining a database describing the overall state of the system and the state of every account represented on the ndau blockchains. This database tracks the effects of network transactions to provide an accurate picture of all accounts and transactions. The noms decentralized, versionable, synchronizable database provides this service, and all ndau Network Nodes run a noms instance.
https://github.com/attic-labs/noms
REDIS
As the size of the ndau blockchains and the size of the noms state database grow, queries and updates to that database will require a more efficient indexing scheme to maintain adequate performance. The redis in-memory database and cache services provides this indexing an all ndau Network Nodes run a redis instance.
https://redis.io
NDAU NETWORK NODE TYPES
ndau Network Nodes may simply watch activity on the ndau blockchains, monitor and verify that activity, or serve as validators in the consensus network to update the blockchains themselves.
PASSIVE NODES
Passive nodes see all blockchain activity and can watch for specific transaction activity. A node operator can start up the suite of node servers and register it with the network: no particular performance, uptime, or reliability requirements apply.
ACTIVE NODES
Active nodes are eligible to earn node rewards as payment. To become an active node, a node operator must stake a minimum number of ndau to act as a bond securing that node’s performance. That stake may be forfeited or “slashed” for poor or malicious behavior.
DELEGATION
ndau account holders may earn additional ndau – an Ecosystem Alignment Incentive (EAI) - for supporting the overall operation of the ndau Network. EAI is accrued when an account holder chooses an ndau Network Node to which to delegate the responsibility of crediting that EAI to the account. Such ndau holders have a financial incentive to monitor the performance of that node and to delegate their accounts to a different node if it is performing poorly. Any ndau holder may delegate an ndau account to any active node at any time, cancel that delegation, or delegate to a different active node.
CREDITING EAI
Active nodes to which accounts have been delegated have a responsibility to periodically credit accrued EAI to them. They do so by periodically submitting CreditEAI transactions to the ndau blockchain.
NODE RANKING
Active nodes are ranked according to a quality metric that considers network resiliency and reliability factors as well as the node’s stake. Stake is the dominant factor, and nodes with larger stake will achieve higher ranking.
VALIDATOR NODES
The highest-ranking active nodes are selected to act as validator nodes. Validator nodes create blocks, add them to the ndau blockchains, and ensure each other’s correct behavior in that work. Any active node may be promoted to a validator node at any time, allowing the network to quickly respond to node failure due to error or attack.
EARNING NODE REWARDS
A fee of 10% is deducted from EAI earned by accounts to pay for network operations. This fee, along with transaction fees, funds a node rewards pool. Node rewards are periodically paid out to active nodes to compensate them for supporting the ndau currency.
NODE REWARDS
STAKE
Active nodes must post stake to ensure their performance. The Blockchain Policy Council (BPC) establishes stake requirements, including maximum and minimum stake amounts. A node must stake a locked account for this purpose, and that lock period must be greater than the specified minimum.
CO-STAKE
An active node may invite other ndau holders to contribute to its total stake. This co-staking allows a reliable node operator to increase their ranking by attracting additional capital, and it allows ndau holders who do not wish to run an active node to earn node rewards.
A node that permits co-staking must publish a node rewards distribution schedule. When the node receives a node reward it must distribute a portion of it to all co-stakers according to that previously-published schedule.
The BPC also specifies a co-staking maximum amount relative to the node operator’s own stake. For example, a node might not be allowed to collect a co-stake total greater than 50% of its own stake.
NODE REWARDS DISTRIBUTION
All active nodes are eligible to earn node rewards. Node Rewards Nomination transactions are posted periodically on the ndau blockchains. Each nomination identifies a randomly-chosen active node, and that node is entitled to claim that entire reward.
Node nominations are made randomly but weighted by each node’s total stake (its own stake plus all co-stake). If a node’s total stake is 5% of the sum of the total stake of all active nodes then it will be randomly chosen approximately 5% of the time. The larger a node’s total stake is the more frequently it will be chosen, but all active nodes are always eligible for rewards.
Each node reward includes the funds from the 10% EAI and all transaction fees since the last node reward. The 10% EAI fee will change slowly as the total amount of EAI in the ndau network changes, but transaction fees may vary considerably from one reward to the next. Regardless of a reward’s size, all of it is awarded to a single active node.
CLAIMING NODE REWARDS
Node rewards also act as an incentive for nodes to remain active and operational. When a node is nominated to receive an award it must respond by posting a Claim Reward transaction in a timely manner. It only receives the node reward after successfully posting that transaction. If a node reward is unclaimed the total reward is permanently removed from circulation or “burned”. It is never distributed to another node and it is not carried over into the next award.
NDAU NETWORK NODE SYSTEM REQUIREMENTS
NDAU NETWORK NODE OPERATIONAL REQUIREMENTS
STAKE
UPTIME
OTHER QUALITY ATTRIBUTES
FINANCIAL CONSIDERATIONS
STAKE
NODE REWARDS
