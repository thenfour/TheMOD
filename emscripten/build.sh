#!/bin/bash
# read README.md for requirements and info about this directory.
# to run this,
#
# clear; bash ./build.sh
#

DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null

SRC=$DIR/src
INTERMEDIATE=$DIR/intermediate
OUTPUT=$DIR/output
WWW=$DIR/../www/emscripten

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
echo "Building..."
$EMCC_PATH $SRC/theMODsite.cpp -O2 -c -o $INTERMEDIATE/theMODsite.o

# link .o files into output js.
echo "Linking..."
$EMCC_PATH $INTERMEDIATE/theMODsite.o --js-library $SRC/theMODexternalLib.js -s EXPORTED_FUNCTIONS="['_animFrame']" -o $OUTPUT/theMODems.js

# copy files to www
echo "Copying to WWW..."
cp $OUTPUT/theMODems.js $WWW/theMODems.js

popd >/dev/null