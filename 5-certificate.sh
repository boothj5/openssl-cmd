#!/bin/bash

# Access coreutils on OSX, install with 'brew install coreutils'
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

. ./common.sh

trap error_handler ERR
trap exit_handler EXIT

create_dirs

echo_trent "Trent: Generate PRIVATE KEY"
wait_key
openssl genrsa -out trent/trent_priv_key.pem 1024
cat_unsafe trent/trent_priv_key.pem

echo_trent "Trent: Encrypt PRIVATE_KEY"
wait_key
openssl rsa -in trent/trent_priv_key.pem -des3 -out trent/trent_priv_enc_key.pem -passout pass:trentpassword
cat_safe trent/trent_priv_enc_key.pem

echo_trent "Trent: Extract PUBLIC KEY from PRIVATE KEY"
wait_key
openssl rsa -pubout -in trent/trent_priv_enc_key.pem -out trent/trent_pub_key.pem -passin pass:trentpassword
cat_safe trent/trent_pub_key.pem

echo_trent "Trent: Create certficiate signing request"
wait_key
openssl req -new -key trent/trent_priv_enc_key.pem -out trent/trent_csr.pem -passin pass:trentpassword
cat_safe trent/trent_csr.pem

echo_trent "Trent: Self sign CSR"
wait_key
openssl x509 -req -days 3650 -in trent/trent_csr.pem -signkey trent/trent_priv_enc_key.pem -out trent/trent_certby_trent.pem -passin pass:trentpassword
cat_safe trent/trent_certby_trent.pem

echo_trent "Trent: Send self signed certificate to Alice and Bob"
wait_key
echo "cp trent/trent_certby_trent.pem alice/."
echo "cp trent/trent_certby_trent.pem bob/."
cp trent/trent_certby_trent.pem alice/.
cp trent/trent_certby_trent.pem bob/.

echo_alice "Alice: Add Trent's self signed certificate to trusted certificates"
wait_key
echo "cat alice/trent_certby_trent.pem > alice/trusted_certs"
cat alice/trent_certby_trent.pem > alice/trusted_certs

echo_bob "Bob: Add Trent's self signed certificate to trusted certificates"
wait_key
echo "cat bob/trent_certby_trent.pem > bob/trusted_certs"
cat bob/trent_certby_trent.pem > bob/trusted_certs

echo_bob "Bob: Generate PRIVATE KEY"
wait_key
openssl genrsa -out bob/bob_priv_key.pem 1024
cat_unsafe bob/bob_priv_key.pem

echo_bob "Bob: Encrypt PRIVATE_KEY"
wait_key
openssl rsa -in bob/bob_priv_key.pem -des3 -out bob/bob_priv_enc_key.pem -passout pass:bobpassword
cat_safe bob/bob_priv_enc_key.pem

echo_bob "Bob: Extract PUBLIC KEY from PRIVATE KEY"
wait_key
openssl rsa -pubout -in bob/bob_priv_enc_key.pem -out bob/bob_pub_key.pem -passin pass:bobpassword
cat_safe bob/bob_pub_key.pem

echo_bob "Bob: Create certificate signing request"
wait_key
openssl req -new -key bob/bob_priv_enc_key.pem -out bob/bob_csr.pem -passin pass:bobpassword
cat_safe bob/bob_csr.pem

echo_bob "Bob: Send CSR to Trent"
wait_key
echo "cp bob/bob_csr.pem trent/."
cp bob/bob_csr.pem trent/.

echo_trent "Trent: Sign Bob's CSR"
wait_key
openssl x509 -req -days 3650 -in trent/bob_csr.pem -CA trent/trent_certby_trent.pem -CAkey trent/trent_priv_enc_key.pem -CAcreateserial -out trent/bob_certby_trent.pem -passin pass:trentpassword
cat_safe trent/bob_certby_trent.pem

echo_trent "Trent: Send Bob's signed certificate to Bob"
wait_key
echo "cp trent/bob_certby_trent.pem bob/."
cp trent/bob_certby_trent.pem bob/.

echo_bob "Bob: Send certificate signed by Trent to Alice"
wait_key
echo "cp bob/bob_certby_trent.pem alice/."
cp bob/bob_certby_trent.pem alice/.

echo_alice "Alice: Generate PRIVATE KEY"
wait_key
openssl genrsa -out alice/alice_priv_key.pem 1024
cat_unsafe alice/alice_priv_key.pem

echo_alice "Alice: Encrypt PRIVATE_KEY"
wait_key
openssl rsa -in alice/alice_priv_key.pem -des3 -out alice/alice_priv_enc_key.pem -passout pass:alicepassword
cat_safe alice/alice_priv_enc_key.pem

echo_alice "Alice: Extract PUBLIC KEY from PRIVATE KEY"
wait_key
openssl rsa -pubout -in alice/alice_priv_enc_key.pem -out alice/alice_pub_key.pem -passin pass:alicepassword
cat_safe alice/alice_pub_key.pem

echo_alice "Alice: Create certificate signing request"
wait_key
openssl req -new -key alice/alice_priv_enc_key.pem -out alice/alice_csr.pem -passin pass:alicepassword
cat_safe alice/alice_csr.pem

echo_alice "Alice: Send CSR to Trent"
wait_key
echo "cp alice/alice_csr.pem trent/."
cp alice/alice_csr.pem trent/.

echo_trent "Trent: Sign Alice's CSR"
wait_key
openssl x509 -req -days 3650 -in trent/alice_csr.pem -CA trent/trent_certby_trent.pem -CAkey trent/trent_priv_enc_key.pem -CAcreateserial -out trent/alice_certby_trent.pem -passin pass:trentpassword
cat_safe trent/alice_certby_trent.pem

echo_trent "Trent: Send Alice's signed certificate to Alice"
wait_key
echo "cp trent/alice_certby_trent.pem alice/."
cp trent/alice_certby_trent.pem alice/.

echo_alice "Alice: Send certificate signed by Trent to Bob"
wait_key
echo "cp alice/alice_certby_trent.pem bob/."
cp alice/alice_certby_trent.pem bob/.

echo_alice "Alice: Create message"
wait_key
echo "Hello this is a private message from Alice to Bob..." > alice/plaintext
cat_unsafe alice/plaintext

echo_alice "Alice: Verify Bob's certificate signed by Trent"
wait_key
openssl verify -verbose -trusted alice/trusted_certs alice/bob_certby_trent.pem > alice/verify_bob.out
cat alice/verify_bob.out
if grep -q error alice/verify_bob.out; then
   echo_error "Alice: Verify failed"
   exit 0
fi
echo_alice "Alice: Verify success"

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

echo_alice "Alice: Encrypt SESSION KEY with Bob's certificate"
wait_key
openssl rsautl -encrypt -inkey alice/bob_certby_trent.pem -certin -in alice/session_key -out alice/session_key_ciphertext
base64 -w 0 alice/session_key_ciphertext > alice/session_key_ciphertext.base64
cat_safe alice/session_key_ciphertext.base64
echo ""

echo_alice "Alice: generate digest from plaintext"
wait_key
sha256sum alice/plaintext | awk '{print $1}' > alice/digest
cat_safe alice/digest

echo_alice "Alice: Sign digest with PRIVATE KEY"
wait_key
openssl rsautl -sign -inkey alice/alice_priv_enc_key.pem -in alice/digest -out alice/signature -passin pass:alicepassword
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

echo_bob "Bob: Verify Alice's certificate signed by Trent"
wait_key
openssl verify -verbose -trusted bob/trusted_certs bob/alice_certby_trent.pem > bob/verify_alice.out
cat bob/verify_alice.out
if grep -q error bob/verify_alice.out; then
   echo_error "Bob: Verify failed"
   exit 0
fi
echo_bob "Bob: Verify success"

echo_bob "Bob: Decrypt SESSION KEY with PRIVATE KEY"
wait_key
payload_get_session_key alice/message bob/session_key_ciphertext.base64
base64 --decode bob/session_key_ciphertext.base64 > bob/session_key_ciphertext
openssl rsautl -decrypt -inkey bob/bob_priv_enc_key.pem -in bob/session_key_ciphertext -out bob/session_key -passin pass:bobpassword
cat_unsafe bob/session_key

echo_bob "Bob: Decrypt ciphertext with SESSION KEY"
wait_key
payload_get_message alice/message bob/ciphertext.base64
base64 --decode bob/ciphertext.base64 > bob/ciphertext
openssl enc -des3 -d -in bob/ciphertext -out bob/plaintext -pass file:bob/session_key
cat_unsafe bob/plaintext

echo_bob "Bob: Verify signature with Alice's certificate signed by Trent"
wait_key
payload_get_signature alice/message bob/signature.base64
base64 --decode bob/signature.base64 > bob/signature
openssl rsautl -verify -in bob/signature -inkey bob/alice_certby_trent.pem -certin > bob/verify_digest
cat_safe bob/verify_digest

echo_bob "Bob: Generate digest from plaintext"
wait_key
sha256sum bob/plaintext | awk '{print $1}' > bob/digest
cat_safe bob/digest

echo_bob "Bob: Compare digests"
wait_key
cmp --silent bob/verify_digest bob/digest
echo_bob "Bob: Message integrity verified"

# openssl verify -verbose -trusted alice/trusted_certs alice/bob_certby_trent.pem

# openssl x509 -in trent/trent_cert_bob.pem -noout -pubkey > trent/bobpub.pem

