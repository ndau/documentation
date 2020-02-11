package main

//  Example using ndau tooling to create secp256k1 keypairs and signatures, and
//  to verify the signatures generated.
//
//  Keys and signatures are all given/supplied as hex-encoded raw bytes. The
//  ndau blockchain tools (ndau and keytool) can interoperate with these
//  hex-encoded values. These examples demonstrate how external
//  software can be used with the ndau libraries.

//	Additional tools:
//		keytool - 	Convert raw binary keys and signatures to ndau-encoded text format
//		ndau	- 	Create ndau transactions in JSON format, emit bytes to be signed, import
//					signatures, and prepare transactions to be submitted to the ndau API
//		ndauapi	-	REST interface to an ndau blockchain

import (
	"bytes"
	"crypto/rand"
	"fmt"
	"os"
	"strings"

	"github.com/oneiro-ndev/ndaumath/pkg/key"
	"github.com/oneiro-ndev/ndaumath/pkg/signature"
)

//	All keys and signatures are read and written in ndau format.
//	Data to be signed is read literally with no conversion.
//
//	Usage:	ndau-sec256kp1 new
// 			ndau-sec256kp1 sign [private key] [data]
// 			ndau-sec256kp1 [public key] [signature] [data]

func main() {
	if len(os.Args) < 2 {
		fmt.Println(strings.TrimSpace(`
Usage:
	ndau-sec256kp1 new
	ndau-sec256kp1 sign [private key] [data]
	ndau-sec256kp1 verify [public key] [signature] [data]

All keys and signatures are read and written in ndau format.
Data to be signed is read literally with no conversion.
		`))
	}

	seedBytes := make([]byte, key.RecommendedSeedLen)
	_, err := rand.Read(seedBytes)
	if err != nil {
		fmt.Println("Error reading random bytes:", err)
		return
	}

	if (len(os.Args) == 2) && (os.Args[1] == "new") {
		// if you pass in nil as the second argument to Generate, it will do
		// the exact same thing we do here: make a byte buffer of the
		// recommended length, fill it from crypto/rand, and use that data. We
		// just externalized that process for clarity and better parallelism
		// with the btcec tool example.
		pubKey, privKey, err := signature.Generate(signature.Secp256k1, bytes.NewBuffer(seedBytes))
		if err != nil {
			fmt.Println("Key generation error:", err)
			return
		}

		privKeyS, err := privKey.MarshalString()
		if err != nil {
			fmt.Println("Private key marshalling error:", err)
			return
		}
		pubKeyS, err := pubKey.MarshalString()
		if err != nil {
			fmt.Println("Public key marshalling error:", err)
			return
		}

		fmt.Println(privKeyS)
		fmt.Println(pubKeyS)
	}

	if (len(os.Args) == 4) && (os.Args[1] == "sign") {
		privKey, err := signature.ParsePrivateKey(os.Args[2])
		if err != nil {
			fmt.Println("Invalid ndau private key")
			return
		}

		// privKey.Sign and pubKey.Verify internally hash the message when
		// using secp256k1, based on recommendations in btcec documentation.
		// Implementation: https://github.com/oneiro-ndev/ndaumath/blob/93bc4c443f9d0e097ff833750b6aac7c2b02559b/pkg/signature/algorithms/secp256k1/secp256k1.go#L59-L65

		message := []byte(os.Args[3])

		sig := privKey.Sign(message)

		sigS, err := sig.MarshalString()
		if err != nil {
			fmt.Println("Signature could not be serialized:", err)
			return
		}
		fmt.Println(sigS)
	}

	if (len(os.Args) == 5) && (os.Args[1] == "verify") {
		sig, err := signature.ParseSignature(os.Args[3])
		if err != nil {
			fmt.Println("Invalid ndau-format signature")
			return
		}

		message := []byte(os.Args[4])

		pubKey, err := signature.ParsePublicKey(os.Args[2])
		if err != nil {
			fmt.Println("Invalid ndau-format public key")
			return
		}

		verified := sig.Verify(message, *pubKey)
		fmt.Println(verified)
	}
}
