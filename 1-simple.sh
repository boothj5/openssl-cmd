#!/bin/bash

# Generates keypairs
# Alice sends message to Bob

echo_wait()
{
    COLOUR=$1    
    MESSAGE=$2
    tput setaf $1
    echo $MESSAGE
    read -n1 -s
    tput sgr0
}

function exit_handler {
    tput sgr0
}

error_handler()
{
    ERR_CODE=$?
    tput setaf 1
        echo "Error $ERR_CODE with command '$BASH_COMMAND' on line ${BASH_LINENO[0]}. Exiting."
    tput sgr0
    exit $ERR_CODE
}

trap exit_handler EXIT
trap error_handler ERR

RED=2

# key generation
echo_wait $RED "--> Generate Alice's private key"
openssl genrsa -out alice/alice_priv_key.pem 4096
cat alice/alice_priv_key.pem

echo_wait $RED "--> Extract Alice's public key"
openssl rsa -pubout -in alice/alice_priv_key.pem -out alice/alice_pub_key.pem
cat alice/alice_pub_key.pem

echo_wait $RED "--> Generate Bob's private key"
openssl genrsa -out bob/bob_priv_key.pem 4096
cat bob/bob_priv_key.pem

echo_wait $RED "--> Extract Bob's public key"
openssl rsa -pubout -in bob/bob_priv_key.pem -out bob/bob_pub_key.pem
cat bob/bob_pub_key.pem

# key exchange
echo_wait $RED "--> Exchange public keys"
cp alice/alice_pub_key.pem bob/.
cp bob/bob_pub_key.pem alice/.

# Alice sends
echo_wait $RED "--> Alice create message"
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat alice/plaintext

echo_wait $RED "--> Alice encrypt plaintext"
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/plaintext -out alice/ciphertext
base64 alice/ciphertext > alice/ciphertext.base64
cat alice/ciphertext.base64

echo_wait $RED "--> Alice send message"
cp alice/ciphertext.base64 bob/.

# Bob receives
echo_wait $RED "--> Bob decrypt ciphertext"
base64 --decode bob/ciphertext.base64 > bob/ciphertext
openssl rsautl -decrypt -inkey bob/bob_priv_key.pem -in bob/ciphertext -out bob/plaintext
cat bob/plaintext
