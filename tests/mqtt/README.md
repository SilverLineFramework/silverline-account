# Silverline MQTT Auth Tests

We currently use the RS256 algorithm for signing and verifying JWTs, and so a private key is used to sign the JWT and a different public key is be used to verify the signature.

## Test Server Setup

- First, setup the MQTT broker service on your server.
- Install MQTT server: [Mosquitto](https://mosquitto.org)
- Install Rust authentication plugin: [mosquitto-jwt-auth](https://github.com/wiomoc/mosquitto-jwt-auth)
- Configure MQTT server to use the options from `server/mosquitto-jwt-auth.conf` using the [configuration file format](https://mosquitto.org/man/mosquitto-conf-5.html).
- **OPTIONAL**: Debug logging of the server using the `log_type debug` config option will allow you to see pub/sub `DENIED` messages, higher logging levels may also work.

## Generate Server TLS Certificate

- Install a certificate to encrypt the transport layer between client nodes and the server.
- There are two main routes depending on what is easy, but #1 is preferred.
  1. Generate a CA-signed certificate using Let's Encrypt, or another domain-approved process that is standard for your organization.
  1. Generate a self-signed certificate.
- TODO: add commands, to use this script
- Place the certificate somewhere safe on the server. (TODO: where?)

## Generate Server JWT Secret

- Generate a set of keys to use to sign and verify JWTs using RS232.
- TODO: add commands, to use this script
- Place the jwt keys somewhere safe on the server. (TODO: where?)

## Generate Test Client JWT (Permissive Root Test)

- Create a test JWT that will give test clients access to the full topic tree for all publish ans subscribe messages
- Run the test script: `python gen-jwt.py -p #, -s #`
- The JWT will be 3 base64 formatted strings separated by a period (`.`), like this:
    ```
    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
    ```
- Save the terminal output in in a file, like `jwt_test_root.txt`.

## Generate 2nd Test Client JWT Secret (Restrictive Test)

- Run the test script `python gen-jwt.py -p realm/proc/stdin, -s realm/proc/stdout`.
- Create a test JWT will give test clients access to limited topics, and denials on other topics can be tested.
- Eventually we will deploy a Silverline User Authentication Server with a secure UI and endpoints to generate these JWTs against a User DB ACL.
- Save the terminal output in in a file, like `jwt_test_restrict.txt`.

## Test Client Setup

- Use one of the Python/Java/C client connection samples to consume the JWT:
  - Username: The `sub` field of the JWT
  - Password: The base64-encoded, formatted JWT
  - Client Certificate: `false` (we use the JWT instead)
  - Transport Encryption: `true`
  - TLS Version: 1.2
  - Verify (self-signed): disable TLS domain check and TLS certificate chain verification
- You will need to copy one of the JWTs generated above to your client device to be saved on your local file system or environment.
