#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null

node tools/r.js -o "tools/build.js"

popd >/dev/null
