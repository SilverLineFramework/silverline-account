#!/usr/bin/env python3

import argparse
import json
from datetime import datetime, timedelta

import jwt


def generate_token(username, alg, kid, days, keypath, jsonOut, sub_topics, pub_topics):
    now = datetime.utcnow()
    claim = {
        "sub": username,
        "subs": sub_topics[0],
        "publ": pub_topics[0],
        'iat': now,
        'exp': now + timedelta(days=days)
    }
    with open(keypath, 'r') as keyfile:
        key = keyfile.read()
    if kid:
        token = jwt.encode(claim, key, algorithm=alg, headers={"kid": kid})
    else:
        token = jwt.encode(claim, key, algorithm=alg)
    outStr = token
    if jsonOut:
        jsonOutObj = {
            "username": username,
            "token": outStr
        }
        outStr = json.dumps(jsonOutObj)
    print(outStr)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=(
        "Generate JWT service tokens w/ pub/sub rights to all topics and 1 year (default) expiry"))
    parser.add_argument('username',
                        help='MQTT username for this service')
    parser.add_argument('-a', dest='alg', type=str, default="RS256",
                        help='Algorithm in header')
    parser.add_argument('-i', dest='kid', type=str,
                        help='Key id in header')
    parser.add_argument('-k', dest='keypath', type=str, default="mqtt.pem",
                        help='Private RSA key file to use (default: "mqtt.pem")')
    parser.add_argument('-d', dest='days', type=int, default="365",
                        help='Number of days the token will be valid (default: 365 days)')
    parser.add_argument('-j', dest='json',  default=False,
                        help='Generate json with username (default: false)')
    parser.add_argument('-s', dest='sub',  nargs='+', default='#',
                        help='Subscribe topic permission (default: #)')
    parser.add_argument('-p', dest='pub',  nargs='+', default='#',
                        help='Publish topic permission (default: #)')
    args = parser.parse_args()
    # print(args)

    generate_token(args.username, args.alg, args.kid, args.days, args.keypath,
                   args.json, sub_topics=[args.sub], pub_topics=[args.pub])
