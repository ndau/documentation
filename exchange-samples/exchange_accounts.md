# Exchange Accounts

## Overview

Steps for setting up exchange accounts.  The intended audience of this document is Oneiro.

## Steps

The steps found [here](README.md) demonstrate what exchanges do.  Part of those steps involve coordination with Oneiro to set up the progenitor exchange address.  Documented below are the Oneiro-side steps of that coordination.

### Get Public Keys from the Exchange

Put them into an environment variable, comma-separated, each one quoted.  For example:

```sh
PUBLIC_VALIDATION_1=npuba8jadtbbedkk32dc8btqv4g98faqazm3h68pa3riqp92drvcw6iihauybqgv3q2wqz2ayshe
PUBLIC_VALIDATION_2=npuba8jadtbbedy57gqx5xu2qsvmp7wnrurznfimky7iyzdavh7ycd3idpp8s339jp47wzgey3gi
VALIDATION_KEYS='"'$PUBLIC_VALIDATION_1'","'$PUBLIC_VALIDATION_2'"'
echo $VALIDATION_KEYS
```

We'll use these when we submit the `SetValidation` transaction below.

### Generate the Progenitor Address

Use `keytool` to generate an exchange address:

```sh
NEW_KEYS=($(./keytool ed new))
PRIVATE_OWNERSHIP=${NEW_KEYS[0]}
PUBLIC_OWNERSHIP=${NEW_KEYS[1]}
PROGENITOR=$(./keytool addr $PUBLIC_OWNERSHIP -x)
echo $PROGENITOR
```

When we're all done below, we'll give that progenitor address to the exchange so that they can create child accounts under it.

### Register it as an Exchange Address

Add the new progenitor address as an exchange account in the `AccountAttributes` system variable.

First, point to a node on the network you'd like.  In this case, we point to testnet-0:

```sh
HOST=https://api.ndau.tech:31300
```

If you are testing this on localnet, then use `HOST=http://localnet:3030`.

1. Get the current account attributes:
    ```sh
    OLD_ACCT_ATTRS=$(curl -s $HOST/system/get/AccountAttributes | jq .AccountAttributes)
    echo $OLD_ACCT_ATTRS | jq .
    ```
1. Do one of the following:
    - If `""` is returned, create fresh attributes:
    ```sh
    NEW_ACCT_ATTRS='{"'$PROGENITOR'":{"x":{}}}'
    echo $NEW_ACCT_ATTRS | jq .
    ```
    - Otherwise, add the address to the existing attributes:
    ```sh
    NEW_ACCT_ATTRS=$(echo $OLD_ACCT_ATTRS | jq .+={"$PROGENITOR":{"x":{}}})
    echo $NEW_ACCT_ATTRS | jq .
    ```
1. Set the new account attributes into the sysvar (update sequence and bpc keys below as needed):
    ```sh
    TXTYPE=SetSysvar
    SEQUENCE=1000
    BPC_PRIVATE_KEY_1=npvtayjadtcbibku43344uqmrn9kaifw4nf3szuue8gep73zcdqrpq3tab3qqxw8rhjqcdt3wnsdnf747tddsz5ws9z7v9y2xygajqfc2f5tw23xgug8xjzz2nru
    BPC_PRIVATE_KEY_2=npvtayjadtcbic4aregt9ni3w4njqtyniseskq6knu5cajnxx42ntwwaq2ammi9dr3gh9dqigrmjv9idtn68ktwacvgddg23y39x96v2e4h5j2aqqp355wh2byix
    BPC_PRIVATE_KEY_3=npvtayjadtcbib94iw83xfjuez788xf82v9f5iq4ddf54vj85r5bexg564xk6pw9kzewczreekfevdpazerdg96bbr2mwja5by73v846icrjmdh2dhxup3c3gpex
    TX=$(curl -s -d "$NEW_ACCT_ATTRS" $HOST/system/set/AccountAttributes | jq .sequence=$SEQUENCE)
    SIGNATURE_1=$(./keytool sign $BPC_PRIVATE_KEY_1 "$TX" -t $TXTYPE)
    SIGNATURE_2=$(./keytool sign $BPC_PRIVATE_KEY_2 "$TX" -t $TXTYPE)
    SIGNATURE_3=$(./keytool sign $BPC_PRIVATE_KEY_3 "$TX" -t $TXTYPE)
    SIGNED_TX=$(echo $TX | jq '.signatures=["'$SIGNATURE_1'","'$SIGNATURE_2'","'$SIGNATURE_3'"]')
    curl -H "Content-Type: application/json" -d "$SIGNED_TX" $HOST/tx/submit/$TXTYPE
    ```
1. Make sure it's there:
    ```sh
    curl -s $HOST/system/get/AccountAttributes | jq .
    ```

Look over the structure that gets printed; it should look similar to the following example, which demonstrates what two exchange accounts would look like in the system variable:

```json
{
  "AccountAttributes": {
    "ndx...a": {
      "x": {}
    },
    "ndx...b": {
      "x": {}
    }
  }
}
```

You should see the new progenitor address in the list under "AccountAttributes".  You should also see that everything else that was in there before is still in there.  If something's wrong, you'll have to rebuild the full AccountAttributes json and try again.  Corrections should be made quickly as what was returned above in the last step is what is now live on the blockchain.

### Fund the Address

We can't perform any transactions on it without it having some ndau to pay for transaction fees.  This is up to Oneiro for how we get ndau into the progenitor account, to be able to afford the upcoming `SetValidation` transaction.

When testing against localnet, the following commands do the job:

```sh
./ndau rfe 1 -a $PROGENITOR
./ndau issue 1
```

When performing against testnet or mainnet, it's likely an Oneiro account will transfer ndau into the progenitor account.  You'll have to construct your own `Transfer` TX json and submit that to testnet/mainnet.  For example:

First, choose which account that has some ndau we can transfer to the progenitor.  For example, if the "12 eyes" account on testnet wanted to transfer ndau to the new progenitor:

```sh
TXTYPE=Transfer
SOURCE_ADDRESS=ndakj49v6nnbdq3yhnf8f2j6ivfzicedvfwtunckivfsw9qt
SOURCE_PRIVATE_KEY=npvta8jaftcjeagjezfenbez6ty99q9hua3ee9w5uj8gnnqvxubzta8xucvhxe874cv5nm6aaaaaah4gge9w4yzi6wtttqpfx2yt9a9ceiiai8kqxq4yw8cz2faqcyvtrkt849pkfedc
SEQUENCE=2000
NAPU_AMOUNT=50000000
read -d '' TX << EOF
{
    "source": "$SOURCE_ADDRESS",
    "destination": "$PROGENITOR",
    "qty": $NAPU_AMOUNT,
    "sequence": $SEQUENCE
}
EOF
SIGNATURE=$(./keytool sign $SOURCE_PRIVATE_KEY "$TX" -t $TXTYPE)
SIGNED_TX=$(echo $TX | jq '.signatures=["'$SIGNATURE'"]')
curl -H "Content-Type: application/json" -d "$SIGNED_TX" $HOST/tx/submit/$TXTYPE
```

### Set Validation Keys

Get the public keys from the exchange that they want to use as validation keys for the progenitor address.  We'll then submit a `SetValidation` transaction on their behalf.  This gives us the ability to make sure that things like the validation script are appropriate.

You may want to change the sequence number and set the validation script to what you want for the given exchange address you're setting up.

NOTE: After the transfer above, the progenitor account will have to wait the default 1-hour recourse period before the following transaction is submitted.

```sh
TXTYPE=SetValidation
SEQUENCE=1
VALIDATION_SCRIPT=""
read -d '' TX << EOF
{
    "target": "$PROGENITOR",
    "ownership": "$PUBLIC_OWNERSHIP",
    "validation_keys": [$VALIDATION_KEYS],
    "validation_script": "$VALIDATION_SCRIPT",
    "sequence": $SEQUENCE
}
EOF
SIGNATURE=$(./keytool sign $PRIVATE_OWNERSHIP "$TX" -t $TXTYPE)
SIGNED_TX=$(echo $TX | jq '.signature="'$SIGNATURE'"')
curl -H "Content-Type: application/json" -d "$SIGNED_TX" $HOST/tx/submit/$TXTYPE
```

### The Address is Ready

Give the progenitor address to the exchange manager.  They can now create child accounts under it, transfer funds out of it, etc.  They should not need the public and private ownership keys we generated above.  They should only need the progenitor address we stored in `$PROGENITOR`.
