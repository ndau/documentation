# Demonstration of equivalence of BTCEC-`secp256k1` and ndau keys

## Setup

```sh
cd samples/btcec-secp256k1
go build .
go get -u github.com/oneiro-ndev/commands
(
    cd $GOPATH/src/github.com/oneiro-ndev/commands &&
    dep ensure &&
    bin/build.sh
)
cp $GOPATH/src/github.com/oneiro-ndev/commands/keytool \
   .
```

## Demo using standard btcec

Run `./btcec-test.sh`. This will generate some keys, sign some data, and verify the signature. It produces three files: `keypair.btcec`, `pubkey.btcec`, and `signature.btcec`, which can be used to validate the operations performed after the fact.

## Demo using ndau tooling

Run `./ndau-test.sh`. This will generate some keys, sign some data, and verify the signature. It produces three files: `keypair.nd`, `pubkey.nd`, and `signature.nd`, which can be used to validate the operations performed after the fact.

## Equivalence

It should be clear from inspection of the test scripts and generated data files that `keytool` and `btcec-secp256k1` are performing the same operations interchangeably.
