# Demonstration of equivalence of BTCEC-`secp256k1` and ndau keys

## Setup

```sh
dep ensure
cd samples/ndau-secp256k1
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
