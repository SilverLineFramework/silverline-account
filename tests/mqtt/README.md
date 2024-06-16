# Silverline MQTT Auth Tests

We currently use the RS256 algorithm for signing and verifying JWTs, and so a private key is used to sign the JWT and it's public key is be used to verify the signature.

## Generate Server TLS Certificate

- Install a certificate to encrypt the transport layer between client nodes and the server.
- There are two main routes depending on what is easy, but #1 is preferred.
  1. Generate a CA-signed certificate using Let's Encrypt, or another domain-approved process that is standard for your organization.
  1. Generate a self-signed certificate for `localhost` testing, you can do this with:
    ```shell
    ./gen-tls-private-key-cert.sh
    ```
- Place the cert and key somewhere safe on the server rather than `./keys`.

## Generate Server JWT Secret

- Generate a set of keys to use to sign and verify JWTs using RS232.
- Use this script to generate JWT keys:
  ```shell
  ./gen-jwt-secret-key.sh
  ```
- Place the jwt keys somewhere safe on the server rather than `./keys`.

## Install Server MQTT Broker and Auth Plugin

- Install MQTT server: [Mosquitto](https://mosquitto.org)
- Install Rust authentication plugin: [mosquitto-jwt-auth](https://github.com/wiomoc/mosquitto-jwt-auth)
  - Configure MQTT server to use the options from [`server/mosquitto-jwt-auth.conf`](server) using the [configuration file format](https://mosquitto.org/man/mosquitto-conf-5.html).
- **OPTIONAL**: Debug logging of the server using the `log_type debug` config option will allow you to see pub/sub `DENIED` messages, higher logging levels may also work.

## Generate Client Test JWT (Permissive Root Test)

- Create a test JWT that will give test clients access to the full topic tree for all publish and subscribe messages
- Run the test script to create a root JWT, and save the terminal output in in a file, like `jwt_test_root.jwt`:
  ```shell
  python3 gen-jwt.py cli -k ./keys/jwt.private.pem -p '#' -s '#' > ./keys/jwt_test_root.jwt
  ```
  or in json format:
    ```shell
  python3 gen-jwt.py cli -k ./keys/jwt.private.pem -p '#' -s '#' -j > ./keys/jwt_test_root.json
  ```
- The JWT will be 3 `base64` formatted strings separated by a period (`.`), like this:
  ```
  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
  ```

## Generate Client 2nd Test JWT Secret (Restrictive Test)

- Create a test JWT will give test clients access to limited topics, and denials on other topics can be tested (**NOTE**: multiple topics can be added).
- Run the test script, and save the terminal output in in a file, like `jwt_test_restrict.jwt`.
  ```shell
  python3 gen-jwt.py cli -k ./keys/jwt.private.pem -p 'realm/proc/stdin/#' -s 'realm/proc/debug/#' 'realm/proc/stdout/#' > ./keys/jwt_test_restrict.jwt
  ```
- **FUTURE WORK:** Eventually we will deploy a Silverline User Authentication Server with a secure UI and endpoints to generate these JWTs against a User DB ACL.

## Test Client-Server Setup

- **HINT:** A quick test of TLS configuration by making client connections to the test broker https://test.mosquitto.org
- Use one of the Python/Java/C [client connection samples](client) (most languages list APIs for JWTs at https://jwt.io) to consume the JWT:
  - Username: The `sub` field of the JWT (by default, the JWTs generated via the provided script will use `cli` as username)
  - Password: The `base64` encoded, formatted JWT **(NOTE: The JWT is supplied in the password field during MQTT Connect)**
  - Client Certificate: `false` (we use the JWT instead)
  - Transport Encryption: `true`
  - TLS Version: `1.2`
  - Verify (self-signed): `disable` TLS domain check and TLS certificate chain verification
- You will need to copy one of the JWTs generated above to your client device to be saved on your local file system or environment.

## Debug Client JWT header, payload, and signature

- A remote test of JWT structure can be assessed by pasting the JWT into the page at https://jwt.io.
- A number of VS Code JWT Decoder plug ins can also help. We tried out [jflbr.jwt-decoder](https://marketplace.visualstudio.com/items?itemName=jflbr.jwt-decoder).
- A local test of the payload can be shown via the helper JWT display script `show-jwt.sh`, using a file containing the JWT, or the full JWT:
  ```shell
  ./show-jwt.sh ./jwt_test_root.txt
  ```
  or
  ```shell
  ./show-jwt.sh eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
  ```
  displays:
  ```
  {
    "alg": "HS256",
    "typ": "JWT"
  }
  {
    "sub": "1234567890",
    "name": "John Doe",
    "iat": 1516239022
  }
  Signature: SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
  ```
