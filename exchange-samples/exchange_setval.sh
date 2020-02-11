#!/usr/bin/env bash

set -xv

PUBLIC_VALIDATION_1=npuba8jadtbbedkk32dc8btqv4g98faqazm3h68pa3riqp92drvcw6iihauybqgv3q2wqz2ayshe
PUBLIC_VALIDATION_2=npuba8jadtbbedy57gqx5xu2qsvmp7wnrurznfimky7iyzdavh7ycd3idpp8s339jp47wzgey3gi
VALIDATION_KEYS='"'$PUBLIC_VALIDATION_1'","'$PUBLIC_VALIDATION_2'"'
echo $VALIDATION_KEYS

# NEW_KEYS=($(./keytool ed new))
# PRIVATE_OWNERSHIP=${NEW_KEYS[0]}
PRIVATE_OWNERSHIP=npvtayjadtcbibjmc8ehdz3ewhqqyyzidcphsx9wyx64jca3d5q5hppevgiduk8wm9fdugve7deagxpb6f55vz89pzp3df48qdtivjb6c5duss3wnk5dmscqq4p8
# PUBLIC_OWNERSHIP=${NEW_KEYS[1]}
PUBLIC_OWNERSHIP=npuba8jadtbbed8khepgj4giapk4d2mzzhr785q5ugmx66hctgud2fyhfbbvi2xyhugvgzveyzv8
# PROGENITOR=$(./keytool addr $PUBLIC_OWNERSHIP -x)
PROGENITOR=ndxcmix3w3ez7ep326zht4gkf9575emz3hj42s89ac8sn2h6

OLD_ACCT_ATTRS=$(./ndau sysvar get AccountAttributes | jq .AccountAttributes)
echo $OLD_ACCT_ATTRS | jq .

NEW_ACCT_ATTRS='{"'$PROGENITOR'":{"x":{}}}'
echo $NEW_ACCT_ATTRS | jq .

# NEW_ACCT_ATTRS=$(echo $OLD_ACCT_ATTRS | jq .+={"$PROGENITOR":{"x":{}}})
# echo $NEW_ACCT_ATTRS | jq .

./ndau sysvar set AccountAttributes --json "$NEW_ACCT_ATTRS"

./ndau sysvar get AccountAttributes | jq .

./ndau rfe 10 -a "$PROGENITOR"

join_by() { local IFS="$1"; shift; echo "$*"; }
HOST=api.ndau.tech:31300
SEQUENCE=1
TXTYPE=SetValidation
VALIDATION_SCRIPT=""
read -d '' TX << EOF
{
    "target": "$PROGENITOR",
    "ownership": "$PUBLIC_OWNERSHIP",
    "validation_script": "$VALIDATION_SCRIPT",
    "sequence": $SEQUENCE,
    "validation_keys": [$VALIDATION_KEYS]
}
EOF
SIGNATURE=$(./keytool sign $PRIVATE_OWNERSHIP "$TX" -t $TXTYPE)
SIGNED_TX=$(echo $TX | jq '.signature="'$SIGNATURE'"')
curl -H "Content-Type: application/json" -d "$SIGNED_TX" https://$HOST/tx/submit/$TXTYPE