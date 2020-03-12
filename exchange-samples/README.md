# Exchange Transaction Examples

## Overview

Examples of how to construct transactions and submit them to the ndau API.  The intended audience of this document is an exchange manager.

## Setup

* Ensure you have the following installed:
    - `go` v1.12
    - `dep`
    - `curl`
    - `jq`
* Build `keytool`:
    - Clone the [commands](https://github.com/ndau/commands) repo
    - `cd ~/go/src/github.com/ndau/commands`
    - `dep ensure`
    - `go build ./cmd/keytool`

## Get an Exchange Address

An address will be created and registered as an Exchange Address by Oneiro, outlined [here](exchange_accounts.md).  This address will be the "progenitor" (oldest ancestor) to a family of child accounts created under it.

Oneiro will ask for the public keys you want associated with your progenitor exchange account.  Oneiro will submit a `SetValidation` transaction with these keys.

You can generate keys using the `keytool`.  Here we generate two keys:

```sh
NEW_KEYS=($(./keytool ed new))
PRIVATE_VALIDATION_1=${NEW_KEYS[0]}
PUBLIC_VALIDATION_1=${NEW_KEYS[1]}
NEW_KEYS=($(./keytool ed new))
PRIVATE_VALIDATION_2=${NEW_KEYS[0]}
PUBLIC_VALIDATION_2=${NEW_KEYS[1]}
echo "Public Progenitor Validation Keys:"; echo $PUBLIC_VALIDATION_1; echo $PUBLIC_VALIDATION_2
```

Give the public keys to Oneiro.  For example:

```
npuba8jadtbbedkk32dc8btqv4g98faqazm3h68pa3riqp92drvcw6iihauybqgv3q2wqz2ayshe
npuba8jadtbbedy57gqx5xu2qsvmp7wnrurznfimky7iyzdavh7ycd3idpp8s339jp47wzgey3gi
```

Oneiro will then give you the progenitor address, at which time it will be ready for you to use.

## Find a Node

In order to submit transactions to the blockchain, you must find a node.  You can submit to an already-existing node on the network, or run one yourself.

### Connect to an existing node

You can get a list of available nodes on testnet by accessing the `services.json` file:

```sh
NETWORK=testnet
SERVICES_URL="https://s3.us-east-2.amazonaws.com/ndau-json/services.json"
SERVICES_JSON=$(curl -s "$SERVICES_URL")
HOSTS=($(echo "$SERVICES_JSON" | jq -r .networks.$NETWORK.nodes[].api))
LEN="${#HOSTS[@]}"
INDEX=$((RANDOM % LEN))
HOST="https://${HOSTS[$INDEX]}"
echo HOST=$HOST
```

This will choose a random node on testnet for you to use with the following examples for submitting transactions to the blockchain.

### Connect to your own node

Optionally, you can follow the steps [here](https://github.com/ndau/commands/blob/master/docker/node_operator.md) to run your own node, connected to testnet.  Once your node is running, you know your host and port for the ndau API.  For example, use `HOST=http://localhost:3030` in the following transaction examples if you're running your node locally with the default ndau API port.

## Child Accounts

Once you have your progenitor exchange address, child accounts can be created under it.  Here is how to build and submit the `CreateChildAccount` transaction to the blockchain:

Put the progenitor address you received from Oneiro into an environment variable.  It's going to be the parent account to the first child account.  For example:

```sh
PARENT=ndxj6wafqg8edqvbaujz6we6q45n9rwdz6b2gvffcvr3wag9
```

Use `keytool` to generate a child address:

```sh
NEW_CHILD_KEYS=($(./keytool ed new))
PRIVATE_CHILD_OWNERSHIP=${NEW_CHILD_KEYS[0]}
PUBLIC_CHILD_OWNERSHIP=${NEW_CHILD_KEYS[1]}
CHILD=$(./keytool addr $PUBLIC_CHILD_OWNERSHIP -x)
CHILD_SIGNATURE=$(./keytool sign $PRIVATE_CHILD_OWNERSHIP $CHILD)
```

Set some child validation keys.  Here we generate two and put them into a comma-separated environment variable with each key quoted.  You should save off the private validation keys associated with the child account:

```sh
NEW_KEYS=($(./keytool ed new))
PRIVATE_CHILD_VALIDATION_1=${NEW_KEYS[0]}
PUBLIC_CHILD_VALIDATION_1=${NEW_KEYS[1]}
NEW_KEYS=($(./keytool ed new))
PRIVATE_CHILD_VALIDATION_2=${NEW_KEYS[0]}
PUBLIC_CHILD_VALIDATION_2=${NEW_KEYS[1]}
CHILD_VALIDATION_KEYS='"'$PUBLIC_CHILD_VALIDATION_1'","'$PUBLIC_CHILD_VALIDATION_2'"'
```

Build and submit the `CreateChildAccount` transaction:

You may want to change the sequence number and recourse period, as well as set the validation script to what you want for the child account.  We use sequence 2 here with the assumption that Oneiro used sequence 1 for the initial `SetValidation` transaction.  The sequence numbers don't need to be sequential.  But they do need to be strictly increasing.

```sh
TXTYPE=CreateChildAccount
SEQUENCE=2
CHILD_RECOURSE_PERIOD=t0s
CHILD_VALIDATION_SCRIPT=""
read -d '' TX << EOF
{
    "target": "$PARENT",
    "child": "$CHILD",
    "child_ownership": "$PUBLIC_CHILD_OWNERSHIP",
    "child_signature": "$CHILD_SIGNATURE",
    "child_recourse_period": "$CHILD_RECOURSE_PERIOD",
    "child_validation_keys": [$CHILD_VALIDATION_KEYS],
    "child_validation_script": "$CHILD_VALIDATION_SCRIPT",
    "child_delegation_node": "$CHILD",
    "sequence": $SEQUENCE
}
EOF
SIGNATURE_1=$(./keytool sign $PRIVATE_VALIDATION_1 "$TX" -t $TXTYPE)
SIGNATURE_2=$(./keytool sign $PRIVATE_VALIDATION_2 "$TX" -t $TXTYPE)
SIGNED_TX=$(echo $TX | jq '.signatures=["'$SIGNATURE_1'","'$SIGNATURE_2'"]')
curl -H "Content-Type: application/json" -d "$SIGNED_TX" $HOST/tx/submit/$TXTYPE
```

## Transfers

Now that you have a progenitor account and a child account, let's transfer some ndau between them.  The progenitor account was funded by Oneiro so that the initial `SetValidation` that Oneiro performed, and the above `CreateChildAccount` transactions will have enough ndau to afford the transaction fees.  Let's assume that the progenitor account still has some funds and transfer a small amount to the child account.

Notice the sequence number has been incremented again.

```sh
TXTYPE=Transfer
SEQUENCE=3
NAPU_AMOUNT=1
read -d '' TX << EOF
{
    "source": "$PARENT",
    "destination": "$CHILD",
    "qty": $NAPU_AMOUNT,
    "sequence": $SEQUENCE
}
EOF
SIGNATURE_1=$(./keytool sign $PRIVATE_VALIDATION_1 "$TX" -t $TXTYPE)
SIGNATURE_2=$(./keytool sign $PRIVATE_VALIDATION_2 "$TX" -t $TXTYPE)
SIGNED_TX=$(echo $TX | jq '.signatures=["'$SIGNATURE_1'","'$SIGNATURE_2'"]')
curl -H "Content-Type: application/json" -d "$SIGNED_TX" $HOST/tx/submit/$TXTYPE
```

The parent account now has less ndau (1 napu less, plus transaction fees), and the child account now has one napu (0.00000001 ndau).
