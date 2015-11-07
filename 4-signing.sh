#!/bin/bash

# Access coreutils on OSX, install with 'brew install coreutils'
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

# Generates keypairs
# Encrypt private keys
# Use des3 symmetric session key
# Include signature
# Alice sends message to Bob

. ./common.sh

trap error_handler ERR
trap exit_handler EXIT

# key generation
echo_wait $GREEN "--> Generate Alice's private key"
openssl genrsa -out alice/alice_priv_key.pem 4096
cat alice/alice_priv_key.pem

echo_wait $GREEN "--> Encrypt Alice's private key"
openssl rsa -in alice/alice_priv_key.pem -des3 -out alice/alice_priv_enc_key.pem
cat alice/alice_priv_enc_key.pem

echo_wait $GREEN "--> Extract Alice's public key"
openssl rsa -pubout -in alice/alice_priv_key.pem -out alice/alice_pub_key.pem
cat alice/alice_pub_key.pem

echo_wait $GREEN "--> Generate Bob's private key"
openssl genrsa -out bob/bob_priv_key.pem 4096
cat bob/bob_priv_key.pem

echo_wait $GREEN "--> Encrypt Bobs's private key"
openssl rsa -in bob/bob_priv_key.pem -des3 -out bob/bob_priv_enc_key.pem

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

echo_wait $GREEN "--> Alice create session key"
openssl rand 8 -hex > alice/session_key
cat alice/session_key

echo_wait $GREEN "--> Alice encrypt session key"
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/session_key -out alice/session_key_ciphertext
base64 alice/session_key_ciphertext > alice/session_key_ciphertext.base64
cat alice/session_key_ciphertext.base64

echo_wait $GREEN "--> Alice encrypting plaintext with session key"
openssl enc -des3 -in alice/plaintext -out alice/ciphertext -pass file:alice/session_key
base64 alice/ciphertext > alice/ciphertext.base64
cat alice/ciphertext.base64

echo_wait $GREEN "--> Alice creating digest"
sha256sum alice/plaintext | awk '{print $1}' > alice/digest
cat alice/digest

echo_wait $GREEN "--> Alice sign digest"
openssl rsautl -sign -inkey alice/alice_priv_enc_key.pem -in alice/digest -out alice/signature
base64 alice/signature > alice/signature.base64
cat alice/signature.base64

echo_wait $GREEN "--> Alice send message"
cp alice/ciphertext.base64 bob/.
cp alice/session_key_ciphertext.base64 bob/.
cp alice/signature.base64 bob/.

# Bob receives
base64 --decode bob/ciphertext.base64 > bob/ciphertext
base64 --decode bob/session_key_ciphertext.base64 > bob/session_key_ciphertext
base64 --decode bob/signature.base64 > bob/signature

echo_wait $GREEN "--> Bob verify signature"
openssl rsautl -verify -in bob/signature -inkey bob/alice_pub_key.pem -pubin > bob/verify_digest
cat bob/verify_digest

echo_wait $GREEN "--> Bob decrypt session key ciphertext"
openssl rsautl -decrypt -inkey bob/bob_priv_enc_key.pem -in bob/session_key_ciphertext -out bob/session_key
cat bob/session_key

echo_wait $GREEN "--> Bob decrypt ciphertext"
openssl enc -des3 -d -in bob/ciphertext -out bob/plaintext -pass file:bob/session_key
cat bob/plaintext

echo_wait $GREEN "--> Bob create digest"
sha256sum bob/plaintext | awk '{print $1}' > bob/digest
cat bob/digest

echo_wait $GREEN "--> Bob verify message integrity"
cmp --silent bob/verify_digest bob/digest
echo_wait $GREEN "--> Verified"
