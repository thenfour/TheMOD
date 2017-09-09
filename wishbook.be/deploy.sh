#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null

# use tridentloop shortened uname
read -p "Username: " FTPUSER
read -p "Key path: " KEYPATH
scp -i "$KEYPATH" -r www-release/* "$FTPUSER@tridentloop.com:www/wishbook.be/"

open http://wishbook.be

popd >/dev/null
