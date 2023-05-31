#!/bin/bash

# WIP
exit 0

echo -e "\n### Creating RSA key pair for JWT (conf/keys/jwt.priv.pem). This will replace old keys (if exist; backup will be in data/keys/jwt.priv.pem.bak)."
read -p "Create RSA key pair ? (y/N) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  [ -f ./data/keys/jwt.priv.pem ] && cp ./data/keys/jwt.priv.pem data/keys/jwt.priv.pem.bak
  rm ./data/keys/*
  openssl genrsa -out ./data/keys/jwt.priv.pem 4096
  openssl rsa -in ./data/keys/jwt.priv.pem -pubout -outform PEM -out ./data/keys/jwt.public.pem
  openssl rsa -in ./data/keys/jwt.priv.pem -RSAPublicKey_out -outform DER -out ./data/keys/jwt.public.der # mqtt auth plugin requires RSAPublicKey format
fi

# reset ownership of public keys
[ -f ./data/keys/jwt.public.pem ] && chown $OWNER ./data/keys/jwt.public.pem
[ -f ./data/keys/jwt.public.der ] && chown $OWNER ./data/keys/jwt.public.der

rm ./conf/sl-web-conf/*.pem 2>/dev/null
# copy public key to /conf/sha256(hostname).pem to be used for Atlassian Service Authentication Protocol (ASAP)
HOSTSHA256=$(echo -n $HOSTNAME | shasum -a 256)
cat ./data/keys/jwt.public.pem > ./conf/sl-web-conf/${HOSTSHA256%???}.pem
