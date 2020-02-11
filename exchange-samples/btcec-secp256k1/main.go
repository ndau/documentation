package main

//  Example using btcsuite to create ndau-compatible secp256k1 keypairs and signatures, and to
//  verify the signatures generated.
//
//  Keys and signatures are all given/supplied as hex-encoded raw bytes. The ndau blockchain
//  tools (ndau and keytool) can interoperate with these hex-encoded values. These examples
//  demonstrate how an external key-management system can be used with the ndau blockchain.

//	Additional tools:
//		keytool - 	Convert raw binary keys and signatures to ndau-encoded text format
//		ndau	- 	Create ndau transactions in JSON format, emit bytes to be signed, import
//					signatures, and prepare transactions to be submitted to the ndau API
//		ndauapi	-	REST interface to an ndau blockchain

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"os"

	"github.com/btcsuite/btcd/btcec"
)

var err error

var privKey btcec.PrivateKey
var pubKey btcec.PublicKey

//	All keys and signatures are read and written in hex-encoded format.
//	Data to be signed is read literally with no conversion. Public keys are encoded in
//	compressed format (34 bytes)
//
//	Usage:	btcec-sec256kp1 new
// 			btcec-sec256kp1 sign [private key] [data]
// 			btcec-sec256kp1 [public key] [signature] [data]

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage:\n     btcec-sec256kp1 new\n     btcec-sec256kp1 sign [private key] [data]\n     btcec-sec256kp1 verify [public key] [signature] [data]")
	}

	keylenBytes := 32
	pkBytes := make([]byte, keylenBytes)

	if (len(os.Args) == 2) && (os.Args[1] == "new") {
		_, err := rand.Read(pkBytes)
		if err != nil {
			fmt.Println("Error reading random bytes:", err)
			return
		}

		privKey, pubKey := btcec.PrivKeyFromBytes(btcec.S256(), pkBytes)
		if err != nil {
			fmt.Println("Key generation error:", err)
			return
		}

		fmt.Println(hex.EncodeToString(privKey.Serialize()))
		fmt.Println(hex.EncodeToString(pubKey.SerializeCompressed()))
	}

	if (len(os.Args) == 4) && (os.Args[1] == "sign") {
		pkBytes, err = hex.DecodeString(os.Args[2])
		if err != nil {
			fmt.Println("Invalid hex-encoded 32-byte private key")
			return
		}

		privKey, _ := btcec.PrivKeyFromBytes(btcec.S256(), pkBytes)

		// ndau uses a SHA256 hash of the message to be signed

		message := []byte(os.Args[3])
		msgHash := sha256.Sum256(message)

		sig, err := privKey.Sign(msgHash[:])
		if err != nil {
			fmt.Println("Signature could not be created:", err)
			return
		}

		fmt.Println(hex.EncodeToString(sig.Serialize()))
	}

	if (len(os.Args) == 5) && (os.Args[1] == "verify") {
		sigBytes, err := hex.DecodeString(os.Args[3])
		if err != nil {
			fmt.Println("Invalid hex-encoded signature")
			return
		}

		signature, err := btcec.ParseSignature(sigBytes, btcec.S256())
		if err != nil {
			fmt.Println("Hex bytes could not be converted to a signature")
			return
		}

		message := []byte(os.Args[4])
		msgHash := sha256.Sum256(message[:])

		pubKeyBytes, _ := hex.DecodeString(os.Args[2])
		if err != nil {
			fmt.Println("Invalid hex-encoded 34-byte compressed public key")
			return
		}

		pubKey, err := btcec.ParsePubKey(pubKeyBytes, btcec.S256())
		if err != nil {
			fmt.Println("Hex bytes could not be converted to a public key")
			return
		}

		verified := signature.Verify(msgHash[:], pubKey)
		fmt.Println(verified)
	}
}
