OpenSSL command line examples
=============================

Examples
--------

Before running an example, run `./clean.sh` to remove any files from a previous example. This is not done automatically so you can view the contents of the generated files using the display scripts (see below).

`1-symmetric.sh` - Simple symmetric key (shared secret) encryption.
- Alice and Bob both have agreed on and (somehow) shared a secret key between themselves.
- The secret key is used for encryption and decryption.

`2-asymmetric.sh` - Simple asymmetric key (public/private) encryption.
- Bob has a public/private keypair and shares the public key with Alice.
- Alice encrypts the message with Bob's public key.
- Bob decrypts the message with his private key.

`3-session-key.sh` - Asymmetric key encryption optimised by using symmetric key for message encryption.
- Bob has a public/private keypair and shares the public key with Alice.
- Alice generates a session key (symmetric).
- Alice encrypts the session key with Bob's public key.
- Alice encrypts the message with the session key.
- Alice sends both the encrypted session key and message to Bob.
- Bob decrypts the session key with his private key.
- Bob decrypts the message with the session key.

`4-signature.sh` - Asymmetric key encryption, with session key, and the addition of a digital signature.
- Bob has a public/private kepair and shares the public key with Alice.
- Alice has a public/private kepair and shares the public key with Bob.
- Alice generates a session key (symmetric).
- Alice encrypts the session key with Bob's public key.
- Alice encrypts the message with the session key.
- Alice creates a hash digest of the message.
- Alice signs the digest using her private key.
- Alice sends the encrypted session key, the encrypted message and her signature of the message.
- Bob decrypts the session key with his private key.
- Bob decrypts the message with the session key.
- Bob verifies Alice's signature with Alice's public key (ouput is the digest created by Alice).
- Bob creates a hash digest of the message using the same algorithm as Alice.
- Bob checks that his digest is the same as Alice's.

`5-certificate.sh` - Asymmetric key encryption, with session key, signature and trusted third party signed certificates.
- Trent is a Certificate Authority trusted by Alice and Bob.
- Trent has a public/private keypair which he self signs and sends to Alice and Bob.
- Alice and Bob store Trents self signed certificate in their local trusted certificate store.
- Bob has a public/private keypair.
- Bob generates a Certifiate Signing Request and sends it to Trent.
- Trent signs Bob's request and returns the Certificate to Bob.
- Bob sends his Certificate signed by Trent to Alice.
- Alice has a public/private keypair.
- Alice generates a Certificate Signing Request and sends it to Trent.
- Trent signs Alice's request and returns the Certificate to Alice.
- Alice sends her Certificate signed by Trent to Bob.
- Alice verifies Bob's certificate signed by Trent
- Alice generates a session key (symmetric).
- Alice encrypts the session key using the Bob's certificate signed by Trent.
- Alice encrypts the message with the session key.
- Alice creates a hash digest of the message.
- Alice signs the digest using her private key.
- Alice sends the encrypted session key, the encrypted message and her signature of the message.
- Bob verifies Alice's certificate signed by Trent.
- Bob decrypts the session key with his private key.
- Bob decrypts the message with the session key.
- Bob verifies Alice's signature with Alice's certificate signed by Trent (ouput is the digest created by Alice).
- Bob creates a hash digest of the message using the same algorithm as Alice.
- Bob checks that his digest is the same as Alice's.

Display scripts
---------------

After running any of the examples, use the following to view the contents of the various types of PEM files.

`show-privatekey.sh` examples:
```
./show-privatekey.sh bob/bob_priv_key.pem
./show-privatekey.sh bob/bob_priv_enc_key.pem
```

`show-publickey.sh` example:
```
./show-publickey.sh alice/alice_pub_key.pem
```

`show-csr.sh` example:
```
./show-csr.sh bob/bob_csr.pem
```

`show-certificate.sh` examples:
```
./show-certificate.sh alice/bob_certby_trent.pem
./show-certificate.sh trent/trent_certby_trent.pem
```

Notes
-----

* The `coreutils` package is needed which is available on most Linux distros.  On OSX to install with brew use `brew install coreutils`.
* Some commands could be combined into one, e.g. encryption and base64 encoding, or hashing and signing. They are kept separate in the examples to show each step and the inputs and outputs
* Although Private keys and Session keys are encrypted in some examples, the unencrypted version is not removed, again for illustration purposes.
* Whilst base64 encoding the messages is not strictly required for the examples to work, it is added since most real world examples will encode binary before sending.
* Encryption key sizes are small to speed up the examples.
