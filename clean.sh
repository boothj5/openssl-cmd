#!/bin/bash

rm -f alice/alice_priv_key.pem
rm -f alice/alice_priv_enc_key.pem
rm -f alice/alice_pub_key.pem
rm -f alice/bob_pub_key.pem

rm -f bob/bob_priv_enc_key.pem
rm -f bob/bob_priv_key.pem
rm -f bob/bob_pub_key.pem
rm -f bob/alice_pub_key.pem

rm -f alice/plaintext
rm -f alice/ciphertext
rm -f alice/ciphertext.base64
rm -f alice/message

rm -f bob/ciphertext.base64
rm -f bob/ciphertext
rm -f bob/plaintext
rm -f bob/message

rm -f alice/session_key
rm -f alice/session_key_ciphertext
rm -f alice/session_key_ciphertext.base64

rm -f bob/session_key
rm -f bob/session_key_ciphertext
rm -f bob/session_key_ciphertext.base64

rm -f alice/digest
rm -f alice/signature
rm -f alice/signature.base64

rm -f bob/signature
rm -f bob/signature.base64
rm -f bob/verify_digest
rm -f bob/digest

tree
