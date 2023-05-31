#!/bin/bash

# WIP
exit 0

echo -e "\n### Creating Service Tokens. This will replace service tokens in secret.env (if exists; backup will be in secret.env.bak)."
read -p "Create Service Tokens ? (y/N) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  grep -v '^SERVICE_' secret.env > secret.tmp # remove all service tokens
  cp secret.env secret.env.bak
  cp secret.tmp secret.env
  services=("py_runtime" "mqttbr")
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
