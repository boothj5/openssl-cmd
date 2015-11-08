#!/bin/bash

# Access coreutils on OSX, install with 'brew install coreutils'
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

. ./common.sh

trap error_handler ERR
trap exit_handler EXIT

create_dirs

echo_bob "Bob: Generate PRIVATE KEY"
wait_key
openssl genrsa -out bob/bob_priv_key.pem 1024
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

echo_alice "Alice: Generate PRIVATE KEY"
wait_key
openssl genrsa -out alice/alice_priv_key.pem 1024
cat_unsafe alice/alice_priv_key.pem

echo_alice "Alice: Encrypt PRIVATE_KEY"
openssl rsa -in alice/alice_priv_key.pem -des3 -out alice/alice_priv_enc_key.pem
cat_safe alice/alice_priv_enc_key.pem

echo_alice "Alice: Extract PUBLIC KEY from PRIVATE KEY"
openssl rsa -pubout -in alice/alice_priv_enc_key.pem -out alice/alice_pub_key.pem
cat_safe alice/alice_pub_key.pem

echo_alice "Alice: Send PUBLIC KEY to Bob"
wait_key
echo "cp alice/alice_pub_key.pem bob/."
cp alice/alice_pub_key.pem bob/.

echo_alice "Alice: Create message"
wait_key
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat_unsafe alice/plaintext

echo_alice "Alice: Create SESSION KEY"
wait_key
openssl rand 8 -hex > alice/session_key
cat_unsafe alice/session_key

echo_alice "Alice: Encrypt plaintext with SESSION KEY"
wait_key
openssl enc -des3 -in alice/plaintext -out alice/ciphertext -pass file:alice/session_key
base64 -w 0 alice/ciphertext > alice/ciphertext.base64
cat_safe alice/ciphertext.base64
echo ""

echo_alice "Alice: Encrypt SESSION KEY with Bob's PUBLIC KEY"
wait_key
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/session_key -out alice/session_key_ciphertext
base64 -w 0 alice/session_key_ciphertext > alice/session_key_ciphertext.base64
cat_safe alice/session_key_ciphertext.base64
echo ""

echo_alice "Alice: generate digest from plaintext"
wait_key
sha256sum alice/plaintext | awk '{print $1}' > alice/digest
cat_safe alice/digest

echo_alice "Alice: Sign digest with PRIVATE KEY"
openssl rsautl -sign -inkey alice/alice_priv_enc_key.pem -in alice/digest -out alice/signature
base64 -w 0 alice/signature > alice/signature.base64
cat_safe alice/signature.base64
echo ""

echo_alice "Alice send message"
wait_key
payload_create alice/message \
    alice/ciphertext.base64 \
    alice/session_key_ciphertext.base64 \
    alice/signature.base64
cp alice/message bob/.
cat_safe bob/message
echo ""

echo_bob "Bob: Decrypt SESSION KEY with PRIVATE KEY"
payload_get_session_key alice/message bob/session_key_ciphertext.base64
base64 --decode bob/session_key_ciphertext.base64 > bob/session_key_ciphertext
openssl rsautl -decrypt -inkey bob/bob_priv_enc_key.pem -in bob/session_key_ciphertext -out bob/session_key
cat_unsafe bob/session_key

echo_bob "Bob: Decrypt ciphertext with SESSION KEY"
wait_key
payload_get_message alice/message bob/ciphertext.base64
base64 --decode bob/ciphertext.base64 > bob/ciphertext
openssl enc -des3 -d -in bob/ciphertext -out bob/plaintext -pass file:bob/session_key
cat_unsafe bob/plaintext

echo_bob "Bob: Verify signature with Alice's PUBLIC KEY"
wait_key
payload_get_signature alice/message bob/signature.base64
base64 --decode bob/signature.base64 > bob/signature
openssl rsautl -verify -in bob/signature -inkey bob/alice_pub_key.pem -pubin > bob/verify_digest
cat_safe bob/verify_digest

echo_bob "Bob: Generate digest from plaintext"
wait_key
sha256sum bob/plaintext | awk '{print $1}' > bob/digest
cat_safe bob/digest

echo_bob "Bob: Compare digests"
wait_key
cmp --silent bob/verify_digest bob/digest
echo_bob "Bob: Message integrity verified"
