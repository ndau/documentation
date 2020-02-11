#!/usr/bin/env bash

set -xv

data="ndau buoyant digital currency"
./ndau-secp256k1 new > keypair.nd
./ndau-secp256k1 sign "$(head -n 1 keypair.nd)" "$data" > signature.nd
echo "$(tail -n 1 keypair.nd)" > pubkey.nd
./keytool verify -v "$(cat pubkey.nd)" "$(cat signature.nd)" "$data"
