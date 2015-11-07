The examples:
* `1-simple.sh` - The most basic exmaple of public/private key encryption.
* `2-encrypt-priv.sh` - Same as `1-simple.sh` with the addition of encrypting the private keys with a passphrase.
* `3-session-key.sh` - Example using a generated symmetric session key for encrpytion of the plaintext.
* `3-signing.sh` - Same as `3-session-key.sh` with the addition of a digital signature of a digest of the plaintext. 

Notes:

* The `coreutils` package is needed which is available on most Linux distros.  On OSX to install with brew use `brew install coreutils`.
* Some commands could be combined into one, e.g. encryption and base64 encoding, or hashing and signing. They are kept separate in the examples to show each step and the inputs and outputs
* Although Private keys and Session keys are encrypted in some examples, the unencrypted version is not removed, again for illustration purposes.
