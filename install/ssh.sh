#!/bin/sh

set -e
set -u

USERNAME=""
USER_EMAIL=""
GITHUB_OAUTH_TOKEN=""

for i in "$@"; do
  case $i in
    --username=*)
      USERNAME=${i#--username=}
      ;;
    --email=*)
      USER_EMAIL=${i#--email=}
      ;;
    --github-oauth-token=*)
      GITHUB_OAUTH_TOKEN=${i#--github-oauth-token=}
      ;;
  esac
done

[ -z "${USERNAME}" ] && { echo 'Missing parameter --username, exiting.'; exit 1; }
[ -z "${GITHUB_OAUTH_TOKEN}" ] && { echo 'Missing parameter --github-oauth-token, exiting.'; exit 1; }

PASSPHRASE=''
FILENAME=~/.ssh/id_rsa

echo "Generating ssh key"
ssh-keygen -N "${PASSPHRASE}" -f ${FILENAME} -t rsa -b 4096 -C "${USER_EMAIL}"
set -x
chown -R ${USERNAME}: ${FILENAME}
set +x
echo "SSH Key generated !"

echo "Adding github.com to known_hosts"
ssh-keyscan github.com >> ~/.ssh/known_hosts

echo "Registering the public key to your github account."

SANITIZED_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub | head -c -1 | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
HOSTNAME=$(hostname -s)
JSON_DATA='{"title": "'${USERNAME}'@'${HOSTNAME}'", "key":'${SANITIZED_PUBLIC_KEY}'}'

curl  -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" --data "${JSON_DATA}" https://api.github.com/user/keys
echo "Public registered to your github account !"
