#!/bin/bash

# Generates keypairs
# Encrypt private keys
# Use des3 symmetric session key
# Alice sends message to Bob

error_handler()
{
        ERR_CODE=$?
        echo "Error $ERR_CODE with command '$BASH_COMMAND' on line ${BASH_LINENO[0]}. Exiting."
        exit $ERR_CODE

}

trap error_handler ERR

# key generation
echo
echo "--> Generating Alice's private key"
echo
openssl genrsa -out alice/alice_priv_key.pem 4096

echo
echo "--> Extracting Alice's public key"
echo
openssl rsa -pubout -in alice/alice_priv_key.pem -out alice/alice_pub_key.pem

echo
echo "--> Encrypting Alice's private key"
echo
openssl rsa -in alice/alice_priv_key.pem -des3 -out alice/alice_priv_enc_key.pem

echo
echo "--> Generating Bob's private key"
echo
openssl genrsa -out bob/bob_priv_key.pem 4096

echo
echo "--> Extracting Bob's public key"
echo
openssl rsa -pubout -in bob/bob_priv_key.pem -out bob/bob_pub_key.pem

echo
echo "--> Encrypting Bobs's private key"
echo
openssl rsa -in bob/bob_priv_key.pem -des3 -out bob/bob_priv_enc_key.pem

# key exchange
echo "--> Exchaning public keys"
cp alice/alice_pub_key.pem bob/.
cp bob/bob_pub_key.pem alice/.

# Alice sends
echo "--> Alice creating session key"
openssl rand 8 -hex > alice/session_key

echo "--> Alice encrypting session key"
openssl rsautl -encrypt -inkey alice/bob_pub_key.pem -pubin -in alice/session_key -out alice/session_key_ciphertext

echo "--> Alice base64 encoding session key ciphertext"
base64 alice/session_key_ciphertext > alice/session_key_ciphertext.base64

echo "--> Alice encrypting plaintext with session key"
openssl enc -des3 -in alice/plaintext -out alice/ciphertext -pass file:alice/session_key

echo "--> Alice base64 encoding ciphertext"
base64 alice/ciphertext > alice/ciphertext.base64

echo "--> Alice sending message"
cp alice/ciphertext.base64 bob/.

echo "--> Alice sending session key"
cp alice/session_key_ciphertext.base64 bob/.

# Bob receives
echo "--> Bob base64 decoding ciphertext"
base64 -d bob/ciphertext.base64 > bob/ciphertext

echo "--> Bob base64 decoding session key ciphertext"
base64 -d bob/session_key_ciphertext.base64 > bob/session_key_ciphertext

echo "--> Bob decrypting session_key_ciphertext"
openssl rsautl -decrypt -inkey bob/bob_priv_enc_key.pem -in bob/session_key_ciphertext -out bob/session_key

echo "--> Bob decrypting ciphertext"
openssl enc -des3 -d -in bob/ciphertext -out bob/plaintext -pass file:bob/session_key

echo "--> Bob message received:"
cat bob/plaintext
