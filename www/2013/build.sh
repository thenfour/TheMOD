#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null

bash closurecompiler/build.sh

popd >/dev/null
