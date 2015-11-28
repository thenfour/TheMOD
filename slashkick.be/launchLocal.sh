#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null


bash node ./tools/startWebServer.js
#python -m SimpleHTTPServer 1337




popd >/dev/null
