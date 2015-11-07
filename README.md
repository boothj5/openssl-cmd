The examples:
* `1-symmetric.sh` - Simple symmetric key (shared secret) encryption.
* `2-asymmetric.sh` - Simple asymmetric key (public/private) encryption.
* `3-asymmetric-session-key.sh` - Asymmetric key encryption using symmetric key for message encryption.
* `4-asymmetric-session-key-signature.sh` - Same as `3-asymmetric-session-key.sh` with the addition of a digital signature for authentication and message integrity.

Notes:

* The `coreutils` package is needed which is available on most Linux distros.  On OSX to install with brew use `brew install coreutils`.
* Some commands could be combined into one, e.g. encryption and base64 encoding, or hashing and signing. They are kept separate in the examples to show each step and the inputs and outputs
* Although Private keys and Session keys are encrypted in some examples, the unencrypted version is not removed, again for illustration purposes.
* Whilst base64 encoding the messages is not strictly required for the examples to work, it is added since most real world examples will encode binary before sending.
