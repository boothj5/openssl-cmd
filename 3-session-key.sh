#!/bin/bash

. ./common.sh

trap error_handler ERR
trap exit_handler EXIT

echo_wait $GREEN "--> Bob: Generate PRIVATE KEY"
openssl genrsa -out bob/bob_priv_key.pem 4096
cat bob/bob_priv_key.pem

echo_wait $GREEN "--> Bob: Encrypt PRIVATE_KEY"
openssl rsa -in bob/bob_priv_key.pem -des3 -out bob/bob_priv_enc_key.pem
cat bob/bob_priv_enc_key.pem

echo_wait $GREEN "--> Bob: Extract PUBLIC KEY from PRIVATE KEY"
openssl rsa -pubout -in bob/bob_priv_enc_key.pem -out bob/bob_pub_key.pem
cat bob/bob_pub_key.pem

echo_wait $GREEN "--> Bob: Send PUBLIC KEY to Alice"
echo "cp bob/bob_pub_key.pem alice/."
cp bob/bob_pub_key.pem alice/.

echo_wait $GREEN "--> Alice: Create message"
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat alice/plaintext

echo_wait $GREEN "--> Alice: Create SESSION KEY"
openssl rand 8 -hex > alice/session_key
cat alice/session_key

echo_wait $GREEN "--> Alice: Encrypt plaintext with SESSION KEY"
openssl enc -des3 -in alice/plaintext -out alice/ciphertext -pass file:alice/session_key
base64 alice/ciphertext > alice/ciphertext.base64
cat alice/ciphertext.base64

echo_wait $GREEN "--> Alice: Encrypt SESSION KEY with Bob's PUBLIC KEY"
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/session_key -out alice/session_key_ciphertext
base64 alice/session_key_ciphertext > alice/session_key_ciphertext.base64
cat alice/session_key_ciphertext.base64

echo_wait $GREEN "--> Alice: Compose message"
echo "MESSAGE:" > alice/message
cat alice/ciphertext.base64 >> alice/message
echo "SESSION_KEY:" >> alice/message
cat alice/session_key_ciphertext.base64 >> alice/message
cat alice/message

echo_wait $GREEN "--> Alice send message"
echo "cp alice/message bob/."
cp alice/message bob/.

echo_wait $GREEN "--> Bob: Receive message"
cat bob/message

sed '2!d' alice/message > bob/ciphertext.base64
sed '4!d' alice/message > bob/session_key_ciphertext.base64
base64 --decode bob/ciphertext.base64 > bob/ciphertext
base64 --decode bob/session_key_ciphertext.base64 > bob/session_key_ciphertext

echo_wait $GREEN "--> Bob: Decrypt SESSION KEY with PRIVATE KEY"
openssl rsautl -decrypt -inkey bob/bob_priv_enc_key.pem -in bob/session_key_ciphertext -out bob/session_key
cat bob/session_key

echo_wait $GREEN "--> Bob: Decrypt ciphertext with SESSION KEY"
openssl enc -des3 -d -in bob/ciphertext -out bob/plaintext -pass file:bob/session_key
cat bob/plaintext
