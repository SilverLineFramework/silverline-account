#!/bin/bash

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

rm ./conf/arena-web-conf/*.pem 2>/dev/null
# copy public key to /conf/sha256(hostname).pem to be used for Atlassian Service Authentication Protocol (ASAP)
HOSTSHA256=$(echo -n $HOSTNAME | shasum -a 256)
cat ./data/keys/jwt.public.pem > ./conf/arena-web-conf/${HOSTSHA256%???}.pem

echo -e "\n### Creating Service Tokens. This will replace service tokens in secret.env (if exists; backup will be in secret.env.bak)."
read -p "Create Service Tokens ? (y/N) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  grep -v '^SERVICE_' secret.env > secret.tmp # remove all service tokens
  cp secret.env secret.env.bak
  cp secret.tmp secret.env
  services=("arena_persist" "arena_arts" "py_runtime" "mqttbr")
  for s in "${services[@]}"
  do
    tn="SERVICE_${s^^}_JWT"
    echo "$tn=$(python /utils/genjwt.py -i $HOSTNAME -k ./data/keys/jwt.priv.pem $s)" >> secret.env
  done
  # generate a token for cli tools (for developers) and announce it in slack
  cli_token_json=$(python /utils/genjwt.py -i $HOSTNAME -k ./data/keys/jwt.priv.pem -j cli)
  echo $cli_token_json > ./data/keys/cli_token.json
  if [[ ! -z "$SLACK_DEV_CHANNEL_WEBHOOK" ]]; then
    username=$(echo $cli_token_json | python3 -c "import sys, json; print(json.load(sys.stdin)['username'])")
    cli_token=$(echo $cli_token_json | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
    alias_name="${HOSTNAME%%.*}"
    curl_data="{\"text\":\"New MQTT token for $HOSTNAME\", \"attachments\": [ {\"text\":\"\`\`\`alias ${alias_name}_pub='mosquitto_pub -h $HOSTNAME -p 8883 -u $username -P $cli_token'\`\`\`\"}, {\"text\":\"\`\`\`alias ${alias_name}_sub='mosquitto_sub -h $HOSTNAME -p 8883 -u $username -P $cli_token'\`\`\`\"} ]}"
    curl -X POST -H 'Content-type: application/json' --data "$curl_data" $SLACK_DEV_CHANNEL_WEBHOOK
  fi
  echo -e "\n Service tokens created. !NOTE!: For new service tokens to be used, you need to (re)create config files (answer Y to question about creating config files)."
fi
