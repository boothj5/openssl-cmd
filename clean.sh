#!/bin/bash

rm -f alice/alice_priv_key.pem
rm -f alice/alice_priv_enc_key.pem
rm -f alice/alice_pub_key.pem
rm -f alice/bob_pub_key.pem

rm -f bob/bob_priv_enc_key.pem
rm -f bob/bob_priv_key.pem
rm -f bob/bob_pub_key.pem
rm -f bob/alice_pub_key.pem

rm -f alice/ciphertext
rm -f alice/ciphertext.base64

rm -f bob/ciphertext.base64
rm -f bob/ciphertext
rm -f bob/plaintext
