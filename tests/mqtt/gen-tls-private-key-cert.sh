#!/bin/bash

KEY_OUT_PATH=keys

mkdir -p $KEY_OUT_PATH
openssl req -x509 -out $KEY_OUT_PATH/tls.host.crt -keyout $KEY_OUT_PATH/tls.host.private.pem \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=localhost' -extensions EXT -config <( \
   printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
