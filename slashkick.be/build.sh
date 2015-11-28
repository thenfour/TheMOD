#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null

# bash closurecompiler/build.sh

node r.js -o mainConfigFile="build.js"


popd >/dev/null
