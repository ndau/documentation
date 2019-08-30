# ndau Network Values
This is a comprehensive list of all system variables, account restrictions, rate tables, and special permissions used in the ndau mainnet.


## System Variables
| **System Variable**         | **Value**                               |
| --------------------------- | --------------------------------------- |
| Default settlement duration | 1 hour                                  |
| EAI Rate Table              | See table below                         |
| EAI Lock Bonus Rate Table   | See table below                         |
| Transaction Fee formulas    | See table below (applied after genesis) |
| ReleaseFromEndowment        | Axiom Foundation account                |
| NominateNodeRewards         | ndau Network Operations account         |
| CommandValidatorChange      | ndau Network Operations account         |
| SetSysvar                   | ndau Network Operations account         |
| RecordPrice                 | ntrd Operations account                 |
| RecordEndowmentNAV          | Axiom Foundation account                |

## Node Operations Variables
| **Node Operations Variables** | **Value**                      |
| ----------------------------- | ------------------------------ |
| Node goodness function        | 1 (all nodes are equally good) |
| Node rewards frequency        | At least 60 minutes            |
| Node rewards claim timeout    | 30 minutes                     |

## EAI Fee Distribution
| **EAI Fee Distribution**    | **Value** | **Address**                                              |
| --------------------------- | --------- | -------------------------------------------------------- |
| Software Development        | 4%        | ndaea8w9gz84ncxrytepzxgkg9ymi4k7c9p427i6b57xw3r4         |
| Market Maker                | 1%        | ndmmw2cwhhgcgk9edp5tiieqab3pq7uxdic2wabzx49twwxh         |
| BPC Operations              | 0.075%    | ndbmgby86qw9bds9f8wrzut5zrbxuehum5kvgz9sns9hgknh         |
| Axiom Foundation Operations | 0.005%    | ndeeh86uun6us9cenuck2uur679e37uczsmys33794gnvtfz         |
| ndau Network Operations     | 0.010%    | ndnf9ffbzhyf8mk7z5vvqc4quzz5i2exp5zgsmhyhc9cuwr4         |
| Node Rewards                | 9.910%    | Unassigned - distributed in ClaimNodeRewards transaction |

## EAI Unlocked Rate Table
| **EAI Unlocked Rate Duration**                           | **EAI Rate** |
| -------------------------------------------------------- | ------------ |
| Less than 30 days                                        | 0%           |
| Equal to or greater than 30 days and less than 60 days   | 2%           |
| Equal to or greater than 60 days and less than 90 days   | 3%           |
| Equal to or greater than 90 days and less than 120 days  | 4%           |
| Equal to or greater than 120 days and less than 150 days | 5%           |
| Equal to or greater than 150 days and less than 180 days | 6%           |
| Equal to or greater than 180 days and less than 210 days | 7%           |
| Equal to or greater than 210 days and less than 240 days | 8%           |
| Equal to or greater than 240 days and less than 270 days | 9%           |
| Equal to or greater than 270 days                        | 10%          |

## EAI Lock Bonus Rates
| **EAI Lock Duration**                                      | **EAI Lock Bonus Rate** |
| ---------------------------------------------------------- | ----------------------- |
| Equal to or greater than 90 days and less than 180 days    | 1%                      |
| Equal to or greater than 180 days and less than 365 days   | 2%                      |
| Equal to or greater than 365 days and less than 730 days   | 3%                      |
| Equal to or greater than 730 days and less than 1,095 days | 4%                      |
| Equal to or greater than 1,095 days                        | 5%                      |

## Transaction Fees
| **Transaction Fees** |                          |                                                      |
| -------------------- | ------------------------ | ---------------------------------------------------- |
|                      | *SetValidation*          | 0.005 ndau + 0.0001 ndau/byte                        |
|                      | *ChangeValidation*       | 0.005 ndau + 0.0001 ndau/byte                        |
|                      | *CreateChildAccount*     | 0.005 ndau + 0.0001 ndau/byte                        |
|                      | *ReleaseFromEndowment*   | 0.1% of amount, 0.005 ndau minimum, 0.5 ndau maximum |
|                      | *Transfer*               | 0.1% of amount, 0.005 ndau minimum, 0.5 ndau maximum |
|                      | *TransferAndLock*        | Transfer fee + 0.005 ndau                            |
|                      | *ChangeRecoursePeriod*   | 0.005 ndau                                           |
|                      | *Delegate*               | 0.005 ndau                                           |
|                      | *Lock*                   | 0.005 ndau                                           |
|                      | *Notify*                 | 0.005 ndau                                           |
|                      | *CreditEAI*              | 0.005 ndau                                           |
|                      | *ClaimNodeReward*        | 0.005 ndau                                           |
|                      | *NominateNodeReward*     | 0.005 ndau                                           |
|                      | *CommandValidatorChange* | 0.005 ndau                                           |
|                      | *RecordPrice*            | 0.005 ndau                                           |
|                      | *SetSysvar*              | 0.005 ndau                                           |
|                      | *SetRewardsDestination*  | 0.005 ndau                                           |
|                      | *Unstake*                | 0.005 ndau                                           |
|                      | *Issue*                  | 0.005 ndau                                           |
|                      | *RegisterNode*           | 1 ndau                                               |
|                      | *UnregisterNode*         | 1 ndau                                               |
|                      | *Stake*                  | 1 ndau                                               |

## Special System Account Validation Rules

Several ndau blockchain transactions are associated with special system accounts. These transactions do not
specify a `target` or `source` account. They are validated using the validation rules established by the
account with the address specified by the appropriate system variable.

| **Special Account**         | **Setting**                                                                           | **Values**                                                                                                        |
| --------------------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| **BPC Operations**          |                                                                                       |                                                                                                                   |
|                             | **Permitted Transactions**                                                            | ChangeValidation<br>SetSysvar                                                                                     |
|                             | **Validation Keys**                                                                   | 9 BPC keys                                                                                                        |
|                             | *ChangeValidation*                                                                    | 6 of 9 signatures                                                                                                 |
|                             | *SetSysvar*                                                                           | 6 of 9 signatures                                                                                                 |
| **Axiom Foundation**        |                                                                                       |                                                                                                                   |
|                             | **Permitted Transactions**                                                            | ChangeValidation<br>ReleaseFromEndowment<br>Transfer<br>TransferAndLock<br>Issue                                  |
|                             | **Validation Keys**                                                                   | 3 Axiom keys<br>9 BPC keys                                                                                        |
|                             | *ChangeValidation*                                                                    | 2 of 3 Axiom signatures ***and***<br>3 of 9 BPC signatures<br>**or**<br>6 of 9 BPC signatures                     |
|                             | *ReleaseFromEndowment*                                                                | <= 30,000 ndau<br>       1 Axiom signature<br>> 30,000 ndau<br>       2 Axiom signatures                          |
|                             | *Transfer*<br>*TransferAndLock*<br>*Issue*                                            | <= 30,000 ndau<br>      1 Axiom signature<br>> 30,000 ndau<br>       2 Axiom signatures                           |
| **ntrd Operations**         |                                                                                       |                                                                                                                   |
|                             | **Permitted Transactions**                                                            | All                                                                                                               |
|                             | **Validation Keys**                                                                   | 3 ntrd keys                                                                                                       |
|                             | *ChangeValidation*                                                                    | 2 of 3 signatures                                                                                                 |
|                             | *RecordPrice*                                                                         | 1 signature                                                                                                       |
|                             | *All other transactions*                                                              | 1 signature                                                                                                       |
| **ndev Operations**         |                                                                                       |                                                                                                                   |
|                             | **Permitted Transactions**                                                            | All                                                                                                               |
|                             | **Validation Keys**                                                                   | 3 ndev keys                                                                                                       |
|                             | *ChangeValidation*                                                                    | 2 of 3 signatures                                                                                                 |
|                             | *All other transactions*                                                              | 1 signature                                                                                                       |
| **ndau Network Operations** |                                                                                       |                                                                                                                   |
|                             | **Permitted Transactions**                                                            | ChangeValidation<br>NominateNodeRewards<br>CommandValidatorChange                                                 |
|                             | **Validation Keys**                                                                   | 3 ndau Network Operations signatures<br>3 BPC signatures                                                          |
|                             | *ChangeValidation*                                                                    | 2 ndau Network Operations signatures ***and***<br>1 BPC signature                                                 |
|                             | *NominateNodeRewards*                                                                 | 1 ndau Network Operations signature                                                                               |
|                             | *CommandValidatorChange*                                                              | 2 ndau Network Operations signatures ***and***<br>1 BPC signature                                                 |
| **ndev Network Nodes**      |                                                                                       |                                                                                                                   |
|                             | **Permitted Transactions**                                                            | ChangeValidation<br>CreditEAI<br>ClaimReward<br>Transfer<br>Lock<br>Notify<br>Delegate<br>Unstake<br>RegisterNode |
|                             | **Validation Keys**                                                                   | Node Key (unique per node)<br>3 ndev keys                                                                         |
|                             | *CreditEAI*<br>*ClaimReward*                                                          | Node signature                                                                                                    |
|                             | *ChangeValidation*<br>*Transfer*<br>*Lock*<br>*Notify*<br>*RegisterNode*<br>*Unstake* | 2 of 3 ndev signatures                                                                                            |
