#!/bin/bash

. ./common.sh

trap error_handler ERR
trap exit_handler EXIT

echo_wait $GREEN "--> Bob: Generate PRIVATE KEY"
openssl genrsa -out bob/bob_priv_key.pem 4096
cat bob/bob_priv_key.pem

echo_wait $GREEN "--> Bob: Extract PUBLIC KEY from PRIVATE_KEY"
openssl rsa -pubout -in bob/bob_priv_key.pem -out bob/bob_pub_key.pem
cat bob/bob_pub_key.pem

echo_wait $GREEN "--> Bob: Send PUBLIC KEY to Alice"
echo "cp bob/bob_pub_key.pem alice/."
cp bob/bob_pub_key.pem alice/.

echo_wait $GREEN "--> Alice: Create message"
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat alice/plaintext

echo_wait $GREEN "--> Alice: Encrypt plaintext with Bob's PUBLIC KEY"
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/plaintext -out alice/ciphertext
base64 alice/ciphertext > alice/message
cat alice/message

echo_wait $GREEN "--> Alice: Send message to Bob"
echo "cp alice/message bob/."
cp alice/message bob/.

# Bob receives
echo_wait $GREEN "--> Bob: Decrypt message with Bob's PRIVATE_KEY"
base64 --decode bob/message > bob/ciphertext
openssl rsautl -decrypt -inkey bob/bob_priv_key.pem -in bob/ciphertext -out bob/plaintext
cat bob/plaintext
