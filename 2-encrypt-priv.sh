#!/bin/bash

# Generates keypairs
# Encrypt private keys
# Alice sends message to Bob

error_handler()
{
    ERR_CODE=$?
    tput setaf 1
    echo "Error $ERR_CODE with command '$BASH_COMMAND' on line ${BASH_LINENO[0]}. Exiting."
    tput sgr0
    exit $ERR_CODE
}

trap error_handler ERR

# key generation
tput setaf 2
echo "--> Generating Alice's private key"
tput sgr0
openssl genrsa -out alice/alice_priv_key.pem 4096

tput setaf 2
echo "--> Extracting Alice's public key"
tput sgr0
openssl rsa -pubout -in alice/alice_priv_key.pem -out alice/alice_pub_key.pem

tput setaf 2
echo "--> Encrypting Alice's private key"
tput sgr0
openssl rsa -in alice/alice_priv_key.pem -des3 -out alice/alice_priv_enc_key.pem

tput setaf 2
echo "--> Generating Bob's private key"
tput sgr0
openssl genrsa -out bob/bob_priv_key.pem 4096

tput setaf 2
echo "--> Extracting Bob's public key"
tput sgr0
openssl rsa -pubout -in bob/bob_priv_key.pem -out bob/bob_pub_key.pem

tput setaf 2
echo "--> Encrypting Bobs's private key"
tput sgr0
openssl rsa -in bob/bob_priv_key.pem -des3 -out bob/bob_priv_enc_key.pem

# key exchange
tput setaf 2
echo "--> Exchaning public keys"
tput sgr0
cp alice/alice_pub_key.pem bob/.
cp bob/bob_pub_key.pem alice/.

# Alice sends
tput setaf 2
echo "--> Alice encrypting plaintext"
tput sgr0
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/plaintext -out alice/ciphertext

tput setaf 2
echo "--> Alice base64 encoding ciphertext"
tput sgr0
base64 alice/ciphertext > alice/ciphertext.base64

tput setaf 2
echo "--> Alice sending message"
tput sgr0
cp alice/ciphertext.base64 bob/.

# Bob receives
tput setaf 2
echo "--> Bob base64 decoding ciphertext"
tput sgr0
base64 --decode bob/ciphertext.base64 > bob/ciphertext

tput setaf 2
echo "--> Bob decrypting ciphertext"
tput sgr0
openssl rsautl -decrypt -inkey bob/bob_priv_enc_key.pem -in bob/ciphertext -out bob/plaintext

tput setaf 2
echo "--> Bob message received:"
tput sgr0
cat bob/plaintext
