#!/bin/bash

# Credits for jwtd(): https://prefetch.net/blog/2020/07/14/decoding-json-web-tokens-jwts-from-the-linux-command-line
jwtd() {
  if [[ -x $(command -v jq) ]]; then
    jq -R 'split(".") | .[0],.[1] | @base64d | fromjson' <<< "${1}"
    # echo "Expires: $(date -d @$(echo "${1}" | awk -F'.' '{print $2}' | jq -r '.exp'))"
    echo "Signature: $(echo "${1}" | awk -F'.' '{print $3}')"
  fi
}

# first param can be a filename caontaining the jwt or the full jwt string
if test -f "$1"; then
  jwt=`cat $1`
  jwtd $jwt
else
  jwtd $1
fi
