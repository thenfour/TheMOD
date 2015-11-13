#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null
# we are in the build directory.

# lets get in the www directory.
#cd ../www

node r.js -o theMOD-buildProfile.js


popd >/dev/null
