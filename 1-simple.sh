#!/bin/bash

# Generates keypairs
# Alice sends message to Bob

error_handler()
{
        ERR_CODE=$?
        echo "Error $ERR_CODE with command '$BASH_COMMAND' on line ${BASH_LINENO[0]}. Exiting."
        exit $ERR_CODE

}

trap error_handler ERR

# key generation
echo
echo "--> Generating Alice's private key"
echo
openssl genrsa -out alice/alice_priv_key.pem 4096

echo
echo "--> Extracting Alice's public key"
echo
openssl rsa -pubout -in alice/alice_priv_key.pem -out alice/alice_pub_key.pem

echo
echo "--> Generating Bob's private key"
echo
openssl genrsa -out bob/bob_priv_key.pem 4096

echo
echo "--> Extracting Bob's public key"
echo
openssl rsa -pubout -in bob/bob_priv_key.pem -out bob/bob_pub_key.pem

# key exchange
echo
echo "--> Exchaning public keys"
cp alice/alice_pub_key.pem bob/.
cp bob/bob_pub_key.pem alice/.

# Alice sends
echo "--> Alice encrypting plaintext"
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/plaintext -out alice/ciphertext

echo "--> Alice base64 encoding ciphertext"
base64 alice/ciphertext > alice/ciphertext.base64

echo "--> Alice sending message"
cp alice/ciphertext.base64 bob/.

# Bob receives
echo "--> Bob base64 decoding ciphertext"
base64 -d bob/ciphertext.base64 > bob/ciphertext

echo "--> Bob decrypting ciphertext"
openssl rsautl -decrypt -inkey bob/bob_priv_key.pem -in bob/ciphertext -out bob/plaintext

echo "--> Bob message received:"
cat bob/plaintext
