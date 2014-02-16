#!/bin/bash
# read README.md for requirements and info about this directory.
# to run this,
#
# clear; bash ./build.sh
#

DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null

INTERMEDIATE=$DIR/intermediate
OUTPUT=$DIR/output

EMCC_PATH=~/Downloads/emsdk_portable/emscripten/1.8.2/emcc
echo "Current directory      : " $DIR
echo "Emscripten emcc path   : " $EMCC_PATH
echo "Intermediate directory : " $INTERMEDIATE
echo "Output directory       : " $OUTPUT
echo .

echo "Creating intermediate & output directories..."
mkdir $INTERMEDIATE
mkdir $OUTPUT
echo .

# for each source file, run emcc -c to preprocess/compile to a .o file.

$EMCC_PATH theMODsite.cpp -s EXPORTED_FUNCTIONS="['_animFrame']" -O2 --js-library theMODexternalLib.js -c

# link .o files into output js.

# copy files to www

popd >/dev/null