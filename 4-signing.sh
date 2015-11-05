#!/bin/bash

# Generates keypairs
# Encrypt private keys
# Use des3 symmetric session key
# Include signature
# Alice sends message to Bob

error_handler()
{
    ERR_CODE=$?
    tput setaf 1
    echo "Error $ERR_CODE with command '$BASH_COMMAND' on line ${BASH_LINENO[0]}. Exiting."
    tput sgr0
    exit $ERR_CODE
}

trap error_handler ERR

# key generation
tput setaf 2
echo "--> Generating Alice's private key"
tput sgr0
openssl genrsa -out alice/alice_priv_key.pem 4096

tput setaf 2
echo "--> Extracting Alice's public key"
tput sgr0
openssl rsa -pubout -in alice/alice_priv_key.pem -out alice/alice_pub_key.pem

tput setaf 2
echo "--> Encrypting Alice's private key"
tput sgr0
openssl rsa -in alice/alice_priv_key.pem -des3 -out alice/alice_priv_enc_key.pem

tput setaf 2
echo "--> Generating Bob's private key"
tput sgr0
openssl genrsa -out bob/bob_priv_key.pem 4096

tput setaf 2
echo "--> Extracting Bob's public key"
tput sgr0
openssl rsa -pubout -in bob/bob_priv_key.pem -out bob/bob_pub_key.pem

tput setaf 2
echo "--> Encrypting Bobs's private key"
tput sgr0
openssl rsa -in bob/bob_priv_key.pem -des3 -out bob/bob_priv_enc_key.pem

# key exchange
tput setaf 2
echo "--> Exchaning public keys"
tput sgr0
cp alice/alice_pub_key.pem bob/.
cp bob/bob_pub_key.pem alice/.

# Alice sends
tput setaf 2
echo "--> Alice creating session key"
tput sgr0
openssl rand 8 -hex > alice/session_key

tput setaf 2
echo "--> Alice encrypting session key"
tput sgr0
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/session_key -out alice/session_key_ciphertext

tput setaf 2
echo "--> Alice encrypting plaintext with session key"
tput sgr0
openssl enc -des3 -in alice/plaintext -out alice/ciphertext -pass file:alice/session_key

tput setaf 2
echo "--> Alice creating digest"
tput sgr0
sha256sum alice/plaintext | awk '{print $1}' > alice/digest

tput setaf 2
echo "--> Alice signing digest"
tput sgr0
openssl rsautl -sign -inkey alice/alice_priv_enc_key.pem -in alice/digest -out alice/signature

tput setaf 2
echo "--> Alice base64 encodes"
tput sgr0
base64 alice/ciphertext > alice/ciphertext.base64
base64 alice/session_key_ciphertext > alice/session_key_ciphertext.base64
base64 alice/signature > alice/signature.base64

tput setaf 2
echo "--> Alice sending message"
tput sgr0
cp alice/ciphertext.base64 bob/.
cp alice/session_key_ciphertext.base64 bob/.
cp alice/signature.base64 bob/.

# Bob receives
tput setaf 2
echo "--> Bob base64 decodes"
tput sgr0
base64 -d bob/ciphertext.base64 > bob/ciphertext
base64 -d bob/session_key_ciphertext.base64 > bob/session_key_ciphertext
base64 -d bob/signature.base64 > bob/signature

tput setaf 2
echo "--> Bob verifying signature"
tput sgr0
openssl rsautl -verify -in bob/signature -inkey bob/alice_pub_key.pem -pubin > bob/verify_digest

tput setaf 2
echo "--> Bob decrypting session_key_ciphertext"
tput sgr0
openssl rsautl -decrypt -inkey bob/bob_priv_enc_key.pem -in bob/session_key_ciphertext -out bob/session_key

tput setaf 2
echo "--> Bob decrypting ciphertext"
tput sgr0
openssl enc -des3 -d -in bob/ciphertext -out bob/plaintext -pass file:bob/session_key

tput setaf 2
echo "--> Bob message received:"
tput sgr0
cat bob/plaintext

tput setaf 2
echo "--> Bob creating digest"
tput sgr0
sha256sum bob/plaintext | awk '{print $1}' > bob/digest

tput setaf 2
echo "--> Bob verifying message integrity"
tput sgr0
cmp --silent bob/verify_digest bob/digest
