#!/usr/bin/env bash

set -xv

# NEW_KEYS=($(ndau-secp256k1/ndau-secp256k1 new))
# PRIVATE_VALIDATION_1=${NEW_KEYS[0]}
# PUBLIC_VALIDATION_1=${NEW_KEYS[1]}
# NEW_KEYS=($(ndau-secp256k1/ndau-secp256k1 new))
# PRIVATE_VALIDATION_2=${NEW_KEYS[0]}
# PUBLIC_VALIDATION_2=${NEW_KEYS[1]}
PRIVATE_VALIDATION_1=npvtayjadtcbicr29vfw6j5q8hyhj6xv5srbdmszwandy5h474bmzjxgmdz6n4ryhxfn6btra2zj7dr9cshamx6v8rgsnzwhg96bz3tkqeedsjmazdj6fr7vgkyy
PUBLIC_VALIDATION_1=npuba8jadtbbedkk32dc8btqv4g98faqazm3h68pa3riqp92drvcw6iihauybqgv3q2wqz2ayshe
PRIVATE_VALIDATION_2=npvtayjadtcbibukekpws55hqrbivz75jkax9f7u498bt4daiu9h6k29m2j4ay3gb5p8vhk743nhijxy84gh3h5ycwfxmqwmmtsjv85bb6wbyy9in69whxmsgii5
PUBLIC_VALIDATION_2=npuba8jadtbbedy57gqx5xu2qsvmp7wnrurznfimky7iyzdavh7ycd3idpp8s339jp47wzgey3gi
echo "Public Progenitor Validation Keys:"; echo $PUBLIC_VALIDATION_1; echo $PUBLIC_VALIDATION_2

PARENT=ndxcmix3w3ez7ep326zht4gkf9575emz3hj42s89ac8sn2h6

NEW_CHILD_KEYS=($(ndau-secp256k1/ndau-secp256k1 new))
PRIVATE_CHILD_OWNERSHIP=${NEW_CHILD_KEYS[0]}
PUBLIC_CHILD_OWNERSHIP=${NEW_CHILD_KEYS[1]}
CHILD=$(./keytool addr $PUBLIC_CHILD_OWNERSHIP -x)
CHILD_SIGNATURE=$(./keytool sign $PRIVATE_CHILD_OWNERSHIP $CHILD)

NEW_KEYS=($(ndau-secp256k1/ndau-secp256k1 new))
PRIVATE_CHILD_VALIDATION_1=${NEW_KEYS[0]}
PUBLIC_CHILD_VALIDATION_1=${NEW_KEYS[1]}
NEW_KEYS=($(ndau-secp256k1/ndau-secp256k1 new))
PRIVATE_CHILD_VALIDATION_2=${NEW_KEYS[0]}
PUBLIC_CHILD_VALIDATION_2=${NEW_KEYS[1]}
CHILD_VALIDATION_KEYS='"'$PUBLIC_CHILD_VALIDATION_1'","'$PUBLIC_CHILD_VALIDATION_2'"'

HOST=localhost:3030
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
# create a b64 encoded string of signable bytes to be signed externally
SIGNABLE_BYTES=$(echo $TX | ./ndau signable-bytes "$TXTYPE")
# sign bytes of TX with private validation keys (replace keytool with your signature tool)
SIGNATURE_1=$(./keytool sign $PRIVATE_VALIDATION_1 "$SIGNABLE_BYTES" -b)
SIGNATURE_2=$(./keytool sign $PRIVATE_VALIDATION_2 "$SIGNABLE_BYTES" -b)
SIGNED_TX=$(echo $TX | jq '.signatures=["'$SIGNATURE_1'","'$SIGNATURE_2'"]')
curl -H "Content-Type: application/json" -d "$SIGNED_TX" $HOST/tx/submit/$TXTYPE

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
# create a b64 encoded string of signable bytes to be signed externally
SIGNABLE_BYTES=$(echo $TX | ./ndau signable-bytes "$TXTYPE")
# sign bytes of TX with private validation keys (replace keytool with your signature tool)
SIGNATURE_1=$(./keytool sign $PRIVATE_VALIDATION_1 "$SIGNABLE_BYTES" -b)
SIGNATURE_2=$(./keytool sign $PRIVATE_VALIDATION_2 "$SIGNABLE_BYTES" -b)
SIGNED_TX=$(echo $TX | jq '.signatures=["'$SIGNATURE_1'","'$SIGNATURE_2'"]')
curl -H "Content-Type: application/json" -d "$SIGNED_TX" $HOST/tx/submit/$TXTYPE

