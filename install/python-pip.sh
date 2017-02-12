#!/bin/bash

set -e
set -u

OLD_PWD=$(pwd)
cd tmp

wget --quiet -O get-pip.py https://bootstrap.pypa.io/get-pip.py
chmod +x get-pip.py

python get-pip.py

cd ${OLD_PWD}
unset OLD_PWD
