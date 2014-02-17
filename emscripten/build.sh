#!/bin/bash
# read README.md for requirements and info about this directory.
# to run this,
#
# clear; bash ./build.sh
#

DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null


#-----------------------------------------
# config here:
EMCC_PATH=~/Downloads/emsdk_portable/emscripten/1.8.2/emcc

# we will assume ".cpp" file extension.
declare -a SourceFiles=(theMODsite theMODtest)

# functions that you are exporting from C++, to be called by javascript
declare -a Exports=(_animFrame _cppRender _cppTest _cppInit _cppRenderSunLayer _cppRenderNavBackgroundLayer)

OUTPUTFILE=theMODems.js

EXTERNLIBRARYFILE=theMODexternalLib.js

#-----------------------------------------

SRC=$DIR/src
INTERMEDIATE=$DIR/intermediate
OUTPUT=$DIR/output
WWW=$DIR/../www/emscripten

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
OFiles=""
for var in "${SourceFiles[@]}"
do
  #echo "${var}"
	$EMCC_PATH $SRC/${var}.cpp -O2 -c -o $INTERMEDIATE/${var}.o -std=c++11
	OFiles="$OFiles $INTERMEDIATE/${var}.o"
done

# link .o files into output js.
echo "Linking... "
FormattedExports=""
for var in "${Exports[@]}"
do
	FormattedExports="$FormattedExports, '${var}'"
done

$EMCC_PATH $OFiles --js-library $SRC/$EXTERNLIBRARYFILE -s EXPORTED_FUNCTIONS="[${FormattedExports:2}]" -o $OUTPUT/$OUTPUTFILE

# copy files to www
echo "Copying to WWW..."
cp $OUTPUT/$OUTPUTFILE $WWW/$OUTPUTFILE

echo 
echo visit:
echo http://localhost:8080/default.html
echo 

popd >/dev/null
