#!/bin/bash

KEY_OUT_PATH=keys

echo -e "\n### Creating RSA key pair for JWT. This will replace old keys (if exist; backup will be in $KEY_OUT_PATH/jwt.private.pem.bak)."
read -p "Create RSA key pair for JWT? (y/N) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  mkdir -p $KEY_OUT_PATH
  [ -f $KEY_OUT_PATH/jwt.private.pem ] && cp $KEY_OUT_PATH/jwt.private.pem $KEY_OUT_PATH/jwt.private.pem.bak
  rm $KEY_OUT_PATH/*
  openssl genrsa -out $KEY_OUT_PATH/jwt.private.pem 4096
  openssl rsa -in $KEY_OUT_PATH/jwt.private.pem -pubout -outform PEM -out $KEY_OUT_PATH/jwt.public.pem
  openssl rsa -in $KEY_OUT_PATH/jwt.private.pem -RSAPublicKey_out -outform DER -out $KEY_OUT_PATH/jwt.public.der # mqtt auth plugin requires RSAPublicKey format
fi

# reset ownership of public keys
[ -f $KEY_OUT_PATH/jwt.public.pem ] && chown $OWNER $KEY_OUT_PATH/jwt.public.pem
[ -f $KEY_OUT_PATH/jwt.public.der ] && chown $OWNER $KEY_OUT_PATH/jwt.public.der

# TODO: automate copy public key to
