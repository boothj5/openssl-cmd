#!/bin/bash

# Access coreutils on OSX, install with 'brew install coreutils'
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

. ./common.sh

trap error_handler ERR
trap exit_handler EXIT

echo_bob "Bob: Generate PRIVATE KEY"
openssl genrsa -out bob/bob_priv_key.pem 4096
cat_unsafe bob/bob_priv_key.pem

echo_bob "Bob: Encrypt PRIVATE_KEY"
openssl rsa -in bob/bob_priv_key.pem -des3 -out bob/bob_priv_enc_key.pem
cat_safe bob/bob_priv_enc_key.pem

echo_bob "Bob: Extract PUBLIC KEY from PRIVATE KEY"
openssl rsa -pubout -in bob/bob_priv_enc_key.pem -out bob/bob_pub_key.pem
cat_safe bob/bob_pub_key.pem

echo_bob "Bob: Send PUBLIC KEY to Alice"
echo "cp bob/bob_pub_key.pem alice/."
cp bob/bob_pub_key.pem alice/.

echo_alice "Alice: Create message"
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat_unsafe alice/plaintext

echo_alice "Alice: Encrypt plaintext with Bob's PUBLIC KEY"
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/plaintext -out alice/ciphertext
base64 -w 0 alice/ciphertext > alice/message
cat_safe alice/message
echo ""

echo_alice "Alice: Send message to Bob"
echo "cp alice/message bob/."
cp alice/message bob/.

echo_bob "--> Bob: Decrypt message with Bob's PRIVATE KEY"
base64 --decode bob/message > bob/ciphertext
openssl rsautl -decrypt -inkey bob/bob_priv_enc_key.pem -in bob/ciphertext -out bob/plaintext
cat_unsafe bob/plaintext
