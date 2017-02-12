#!/bin/sh

set -u
set -e

GITHUB_USERNAME=''
OAUTH_TOKEN=''

for i in "$@"; do
  case $i in
    --token=*)
      OAUTH_TOKEN=${i#--token=}
      ;;
    --github-username=*)
      GITHUB_USERNAME=${i#--github-username=}
      ;;
  esac
done

[ -z "${GITHUB_USERNAME}" ] && { echo 'Missing parameter --github-username, exiting.'; exit 1; }

if [ -z "${OAUTH_TOKEN}" ]; then
    OUTPUT=$(curl -s https://api.github.com/authorizations --user "${GITHUB_USERNAME}" --data '{"scopes":["write:public_key"],"note":"lebris ubuntu ssh key installer, delete me after generted public key has be registered. '$(date +%Y-%m-%d:%H:%M:%S)'"}')

    OAUTH_TOKEN=$(echo ${OUTPUT} | python -c 'import json, sys, pprint; output=json.loads( sys.stdin.read() ); print(output["token"])')
fi

[ -z "${OAUTH_TOKEN}" ] && { echo 'Unable to get a github oauth token.'; exit 1; }

echo ${OAUTH_TOKEN}
exit 0
