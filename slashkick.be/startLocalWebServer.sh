#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
echo $DIR
pushd $DIR >/dev/null


node "./tools/startWebServer.js"
#python -m SimpleHTTPServer 1337




popd >/dev/null
