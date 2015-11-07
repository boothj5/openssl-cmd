#!/bin/bash

# Access coreutils on OSX, install with 'brew install coreutils'
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

. ./common.sh

trap error_handler ERR
trap exit_handler EXIT

create_dirs

echo_bob "Bob: Generate PRIVATE KEY"
wait_key
openssl genrsa -out bob/bob_priv_key.pem 4096
cat_unsafe bob/bob_priv_key.pem

echo_bob "Bob: Encrypt PRIVATE_KEY"
openssl rsa -in bob/bob_priv_key.pem -des3 -out bob/bob_priv_enc_key.pem
cat_safe bob/bob_priv_enc_key.pem

echo_bob "Bob: Extract PUBLIC KEY from PRIVATE KEY"
openssl rsa -pubout -in bob/bob_priv_enc_key.pem -out bob/bob_pub_key.pem
cat_safe bob/bob_pub_key.pem

echo_bob "Bob: Send PUBLIC KEY to Alice"
wait_key
echo "cp bob/bob_pub_key.pem alice/."
cp bob/bob_pub_key.pem alice/.

echo_alice "Alice: Create message"
wait_key
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat_unsafe alice/plaintext

echo_alice "Alice: Encrypt plaintext with Bob's PUBLIC KEY"
wait_key
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/plaintext -out alice/ciphertext
base64 -w 0 alice/ciphertext > alice/ciphertext.base64
cat_safe alice/ciphertext.base64
echo ""

echo_alice "Alice: Send message to Bob"
wait_key
payload_create alice/message \
    alice/ciphertext.base64
cp alice/message bob/.
cat_safe bob/message
echo ""

echo_bob "--> Bob: Decrypt message with Bob's PRIVATE KEY"
payload_get_message bob/message bob/ciphertext.base64
base64 --decode bob/ciphertext.base64 > bob/ciphertext
openssl rsautl -decrypt -inkey bob/bob_priv_enc_key.pem -in bob/ciphertext -out bob/plaintext
cat_unsafe bob/plaintext
