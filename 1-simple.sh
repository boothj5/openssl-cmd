#!/bin/bash

# Generates keypairs
# Alice sends message to Bob

. ./common.sh

trap error_handler ERR
trap exit_handler EXIT

# key generation
echo_wait $GREEN "--> Generate Alice's private key"
openssl genrsa -out alice/alice_priv_key.pem 4096
cat alice/alice_priv_key.pem

echo_wait $GREEN "--> Extract Alice's public key"
openssl rsa -pubout -in alice/alice_priv_key.pem -out alice/alice_pub_key.pem
cat alice/alice_pub_key.pem

echo_wait $GREEN "--> Generate Bob's private key"
openssl genrsa -out bob/bob_priv_key.pem 4096
cat bob/bob_priv_key.pem

echo_wait $GREEN "--> Extract Bob's public key"
openssl rsa -pubout -in bob/bob_priv_key.pem -out bob/bob_pub_key.pem
cat bob/bob_pub_key.pem

# key exchange
echo_wait $GREEN "--> Exchange public keys"
cp alice/alice_pub_key.pem bob/.
cp bob/bob_pub_key.pem alice/.

# Alice sends
echo_wait $GREEN "--> Alice create message"
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat alice/plaintext

echo_wait $GREEN "--> Alice encrypt plaintext"
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/plaintext -out alice/ciphertext
base64 alice/ciphertext > alice/ciphertext.base64
cat alice/ciphertext.base64

echo_wait $GREEN "--> Alice send message"
cp alice/ciphertext.base64 bob/.

# Bob receives
echo_wait $GREEN "--> Bob decrypt ciphertext"
base64 --decode bob/ciphertext.base64 > bob/ciphertext
openssl rsautl -decrypt -inkey bob/bob_priv_key.pem -in bob/ciphertext -out bob/plaintext
cat bob/plaintext
