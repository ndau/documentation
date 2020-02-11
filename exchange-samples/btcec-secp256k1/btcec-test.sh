#!/usr/bin/env bash

set -xv

data="ndau buoyant digital currency"
./btcec-secp256k1 new > keypair.btcec
./btcec-secp256k1 sign "$(head -n 1 keypair.btcec)" "$data" | ../../../commands/keytool hd raw signature --stdin -x > signature.btcec
./keytool hd raw public "$(tail -n 1 keypair.btcec)" -x > pubkey.btcec
./keytool verify -v "$(cat pubkey.btcec)" "$(cat signature.btcec)" "$data"
