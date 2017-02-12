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
cd tmp

su ${USERNAME} --preserve-environment -c 'pip install --user powerline-status'

echo "Downloading fonts"
su ${USERNAME} --preserve-environment -c 'wget -q https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf'

echo "Installing font"
if [ ! -d ~/.fonts/ ]; then
    su ${USERNAME} --preserve-environment -c 'mkdir -p ~/.fonts/'
    echo "Directory ~/.fonts/ created"
fi
mv PowerlineSymbols.otf ~/.fonts/

echo "Updating font cache"
su ${USERNAME} -c 'fc-cache -vf ~/.fonts/'

echo "Installing the fontconfig file"
su ${USERNAME} --preserve-environment -c 'wget -q https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf'
if [ ! -d ~/.config/fontconfig/conf.d/ ]; then
    su ${USERNAME} --preserve-environment -c 'mkdir -p ~/.config/fontconfig/conf.d/'
    echo "Directory ~/.config/fontconfig/conf.d/ created"
fi
mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/

cd ${OLD_PWD}
unset OLD_PWD
