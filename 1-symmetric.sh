#!/bin/bash

# Access coreutils on OSX, install with 'brew install coreutils'
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

. ./common.sh

trap error_handler ERR
trap exit_handler EXIT

create_dirs

echo_both "Both: Alice and Bob share a SECRET KEY"
wait_key
openssl rand 8 -hex > shared/secret_key
cat_unsafe shared/secret_key

echo_alice "Alice: Create message"
wait_key
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat_unsafe alice/plaintext

echo_alice "Alice: Encrypt plaintext with SECRET KEY"
wait_key
openssl enc -des3 -in alice/plaintext -out alice/ciphertext -pass file:shared/secret_key
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

echo_bob "Bob: Decrypt ciphertext with SECRET KEY"
wait_key
payload_get_message bob/message bob/ciphertext.base64
base64 --decode bob/ciphertext.base64 > bob/ciphertext
openssl enc -des3 -d -in bob/ciphertext -out bob/plaintext -pass file:shared/secret_key
cat_unsafe bob/plaintext
