#!/bin/bash

# Generates keypairs
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
    echo "--> Generate Alice's private key" ; read -n1 -s
tput sgr0
openssl genrsa -out alice/alice_priv_key.pem 4096
cat alice/alice_priv_key.pem

tput setaf 2
    echo "--> Extract Alice's public key" ; read -n1 -s
tput sgr0
openssl rsa -pubout -in alice/alice_priv_key.pem -out alice/alice_pub_key.pem
cat alice/alice_pub_key.pem

tput setaf 2
    echo "--> Generate Bob's private key" ; read -n1 -s
tput sgr0
openssl genrsa -out bob/bob_priv_key.pem 4096
cat bob/bob_priv_key.pem

tput setaf 2
    echo "--> Extract Bob's public key" ; read -n1 -s
tput sgr0
openssl rsa -pubout -in bob/bob_priv_key.pem -out bob/bob_pub_key.pem
cat bob/bob_pub_key.pem

# key exchange
tput setaf 2
    echo "--> Exchange public keys" ; read -n1 -s
tput sgr0
cp alice/alice_pub_key.pem bob/.
cp bob/bob_pub_key.pem alice/.

# Alice sends
tput setaf 2
    echo "--> Alice create message" ; read -n1 -s
tput sgr0
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat alice/plaintext

tput setaf 2
    echo "--> Alice encrypt plaintext" ; read -n1 -s
tput sgr0
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/plaintext -out alice/ciphertext
base64 alice/ciphertext > alice/ciphertext.base64
cat alice/ciphertext.base64

tput setaf 2
    echo "--> Alice send message" ; read -n1 -s
tput sgr0
cp alice/ciphertext.base64 bob/.

# Bob receives
tput setaf 2
    echo "--> Bob decrypt ciphertext" ; read -n1 -s
tput sgr0
base64 --decode bob/ciphertext.base64 > bob/ciphertext
openssl rsautl -decrypt -inkey bob/bob_priv_key.pem -in bob/ciphertext -out bob/plaintext
cat bob/plaintext
