#!/bin/bash

set -e
set -u

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


USERNAME=""
USER_EMAIL=""
GITHUB_USERNAME=""

for i in "$@"; do
  case $i in
    --username=*)
      USERNAME=${i#--username=}
      ;;
    --email=*)
      USER_EMAIL=${i#--email=}
      ;;
    --github-username=*)
      GITHUB_USERNAME=${i#--github-username=}
      ;;
  esac
done

[ -z "${USERNAME}" ] && { echo 'Missing parameter --username, exiting.'; exit 1; }
[ -z "${USER_EMAIL}" ] && { echo 'Missing parameter --email, exiting.'; exit 1; }
[ -z "${GITHUB_USERNAME}" ] && { echo 'Missing parameter --github-username, exiting.'; exit 1; }

# USERNAME=$1
RED="\e[31m"
GREEN="\e[32m"
RESTORE="\e[0m"

/bin/echo -e "$GREEN### Updating packages list ###$RESTORE"
apt-get -qq update

/bin/echo -e "$GREEN### Installing the usual usefull stuff ###$RESTORE"
apt-get -qq install -y git \
                   curl \
                   wget \
                   vim \
                   htop \
                   tmux \
                   indicator-multiload

OLD_PWD=$(pwd)
cd $(dirname $0)

mkdir -p $(dirname $0)/tmp
chown -Rf ${USERNAME}: $(dirname $0)/tmp

/bin/echo -e  $GREEN'### Getting github Oauth authorization (for registering the futurly generated ssh key) ###'$RESTORE
GITHUB_OAUTH_TOKEN=$(sh ./github-oauth.sh --github-username=${GITHUB_USERNAME})
echo $GITHUB_OAUTH_TOKEN
/bin/echo -e  $GREEN"### Github Oauth access token ok ! ###"$RESTORE

# docker
STUFF_TO_INSTALL='
python-pip
gogh
ssh
dotfiles
powerline
'

for i in ${STUFF_TO_INSTALL}; do
    if [ ! -f "$(pwd)/install/$i.sh" ]; then
        /bin/echo -e "$RED\Unknown install $i$RESTORE"
        exit 1
    fi

    /bin/echo -e "$GREEN### Installing $i ###$RESTORE"
    sh install/$i.sh --username="${USERNAME}" --github-oauth-token="${GITHUB_OAUTH_TOKEN}" --email="${USER_EMAIL}"
done
