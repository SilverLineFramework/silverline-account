#!/usr/bin/env python3

import argparse
import json
from datetime import datetime, timedelta

import jwt


def generate_token(username, kid, days, keypath, jsonOut, sub_topics, pub_topics):
    now = datetime.utcnow()
    claim = {
        "sub": username,
        "subs": sub_topics,
        "publ": pub_topics,
        'iat': now,
        'exp': now + timedelta(days=days)
    }
    with open(keypath, 'r') as keyfile:
        key = keyfile.read()
    token = jwt.encode(claim, key, algorithm='RS256', headers={"kid": kid})
    outStr = token.decode()
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
    parser.add_argument('username', help='MQTT username for this service')
    parser.add_argument('-i', dest='kid', required=True,
                        help='Key id in header (required)')
    parser.add_argument('-k', dest='keypath', default="mqtt.pem",
                        help='Private RSA key file to use (default: "mqtt.pem")')
    parser.add_argument('-d', dest='days', type=int, default="365",
                        help='Number of days the token will be valid (default: 365 days)')
    parser.add_argument('-j', dest='json', action='store_true', default=False,
                        help='Generate json with username (default: false)')
    parser.add_argument('-s', dest='sub', action='store_true', default='#',
                        help='Subscribe topic permission (default: #)')
    parser.add_argument('-p', dest='pub', action='store_true', default='#',
                        help='Publish topic permission (default: #)')
    args = parser.parse_args()

    generate_token(args.username, args.kid, args.days, args.keypath,
                   args.json, sub_topics=[args.sub], pub_topics=[args.pub])
