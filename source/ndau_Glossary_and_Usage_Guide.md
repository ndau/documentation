ndau Glossary and Usage Guide
===

# Definitions

**ndau Chain** - The main ndau blockchain.

**Chaincode** - Chaincode is a stack-based programming language that allows users of ndau to express complex logic about how their ndau should behave and implement sophisticated security systems.

**ndau** – A single unit of currency. Always spelled with a lowercase ‘n’, including when it is the first word in a sentence. Pronounced as "EN-dow". ndau is a count noun, not a mass noun: “many ndau”, not “a lot of ndau”, and “fewer ndau”, not “less ndau”. Use the indefinite article ‘an’: “an ndau account”.

**napu** - The smallest possible division of one ndau, equal to 1 x 10^-8 ndau. (Derived by flipping the word `ndau` upside down.)

**Account** – A single container of ndau. An account has many properties (e.g. lock status, weighted average age, etc.) in addition to its address. Do not use ‘address’ as a synonym for ‘account’: use ‘address’ only when referring to that specific attribute of an account.

**Address** – A 48-character string identifying an account on the ndau blockchain. All ndau transactions identify an account by its address.

**Transaction Terminology** - Transfer transactions have a **source** and **destination** account. The source account **sends** ndau and the destination **receives** them. The affected ndau have been **transferred.** Transactions that only affect a single account (e.g. locking) act on that account as the object of the transaction verb: the holder **locks** an account, **sets** a Recourse Period, **changes** a validation script.

**Ecosystem Alignment Incentive (EAI)** – (Not *Economic* Alignment Incentive) Newly-created ndau available to ndau holders to encourage holder behavior in support of ndau fiscal policy and goals.

**Locked** – A locked account does not permit outgoing transfers. Locked accounts accrue additional EAI as an incentive for locking, and are subject to restrictions on when they become unlocked.

**Recourse Period** – A period during which ndau transferred from a source account to a destination account are not yet available to destination account. Capitalize both words, do not use an acronym. Do not use ‘escrow’ as a synonym.

**Key** – A private key and a public key together make up a **keypair**. Information (of any sort) can be combined with one of those two keys, creating a **signature**. The signature can be verified by a holder of the other key, and the information can be confirmed to be unmodified since it was signed. In most ndau (and other blockchain) contexts, information is signed with the private key and verified with the public key: therefore, it is usually not necessary to qualify ‘key’ as ‘private key’ or ‘public key’. Do not confuse ‘signature’ with ‘key’: a signature is created by the combination of information and a key.

**Signature** - A combination of a **key** and information.

**Node** - A computing device participating in the ndau network, running the ndau blockchain software.  Also referred to as “Network Node”.

**Node operator** - An entity responsible for operating one or more nodes.

**Reward** - A payment made in response to user behavior. Both EAI and node operations payments are rewards.

**Delegate** - When an ndau holder assigns the calculation of EAI for a specific account to a specific network node.

**Stake** - A quantity of ndau assigned to an ndau account to be used as a sort of surety bond for ndau node operations. "Stake" is also a verb describing the process of that assignment.

**Primary Stake** - ndau from a source account that are staked to a rules account. ndau staked to a Primary Stake account is "**co-stake**".

**Active node** - An active node is a node that has self-staked a minimum quantity of ndau (as set by the BPC).

**Resiliency score** - A measure of the quality of an active node's performance in support of the ndau network. It is based on a node's total stake, uptime/responsiveness, and other metrics.

**Validator node** - An active node currently assigned to the ndau consensus engine's validation network.

**Transaction fee** - All transactions are charged a fee, deducted from the transaction’s source account. Fees are defined by a published fee schedule that is controlled by the BPC. In some cases, a fee's value may be determined by a formula based on the fields in a transaction rather than being a scalar value.

**EAI Service Fees** - Mandatory service fees deducted from all EAI: they include

-  An Ecosystem Funding Fee (4%)
-  A Market Maker Price Discovery Fee (1%)
-  A Node Operations Fee (10%)

**Node operation rewards** – Incentives for node operators to improve network performance and resilience. Rewards are paid from both transaction fees and from node operations fees deducted from EAI.

**Recovery Phrase** - A 12-word (could be longer in the future) phrase that can be used to reconstruct the keypairs and addresses of all accounts in a wallet.

**Wallet** - A collection of account addresses and their associated private keys.

**Wallet**  - The ndau mobile app, a **Hierarchical Deterministic Wallet** (HD Wallet) developed by ndev.   A wallet is a client software application used by an ndau holder to manage the collection of ndau accounts they own. ‘Wallet’ is also used to refer to that collection itself: both “I installed the ndau wallet” and “There are six accounts in my wallet” are correct. This is a very confusing term in the cryptocurrency world. It is sometimes also used to refer to the software required to run a node (sometimes that’s called a ‘full wallet’). Only use wallet in the two meanings given above. ndau blockchain transactions only operate on individual accounts: a wallet is a client-side convenience for users.

**App Password** - The password a user enters whenever they want to open and use the Wallet App.

# ndau Wallet Structure ([source](https://docs.google.com/presentation/d/1ELdJWT-N5RjwkzNMiZebv3kbfiiPn6RcW_cfC0-LXY8/edit#slide=id.g454b6172a0_0_9))
![](https://i.gyazo.com/5324ea65930ef972e7473eb59264eae2.png)

# Wallet with example of an imported private key ([source](https://docs.google.com/presentation/d/1ELdJWT-N5RjwkzNMiZebv3kbfiiPn6RcW_cfC0-LXY8/edit#slide=id.p))
![](https://i.gyazo.com/d2ee830f5ffeadbb80d949c01ecbc85e.png)

![The relationship between Wallet, Account and Address.](https://i.gyazo.com/0881a2ccd4b426c45b79160005db7b94.png)