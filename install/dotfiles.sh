#!/bin/bash

set -e
set -u

USERNAME=""

for i in "$@"; do
  case $i in
    --username=*)
      USERNAME=${i#--username=}
      ;;
  esac
done

[ -z "${USERNAME}" ] && { echo 'Missing parameter --username, exiting.'; exit 1; }

OLD_PWD=$(pwd)

su ${USERNAME} --preserve-environment -c 'git clone git@github.com:lebris/dotfiles.git ~/.dotfiles --branch=powerline'
cd ~/.dotfiles
su ${USERNAME} --preserve-environment -c 'bash setup.sh'

cd ${OLD_PWD}
