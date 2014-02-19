#!/bin/bash
#set -x #echo on

DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null
# we are in the build directory.
# lets get in the www directory.
cd ../www

pwd

#---------------------------------------------------------------
# these should be relative to the scripts directory.
declare -a SCRIPTS=( \
	"jquery-1.11.0.min.js" \
	"jquery.mousewheel.js" \
	"jquery.jscrollpane.min.js" \
	"mersenne-twister.js" \
	"themodImage.js" \
	"themodTween.js" \
	"themodutil.js" \
	"theModFakeStorage.js" \
	"theModCMS.js" \
	"theModAudio.js" \
	"themodengine.js" \
	"layerBackground.js" \
	"layerTopCurtain.js" \
	"layerLogo.js" \
	"layerSun.js" \
	"layerScroller.js" \
	"layerNavBackground.js" \
	"layerTopRightSquares.js" \
	"themodrenderer.js" \
	"theMODmain.js" \
)

#---------------------------------------------------------------

echo "Minifying / optimizing / combining scripts..."


# generate command line args
#set -x #echo on
ClosureJS=""
ScriptTags=""
for var in "${SCRIPTS[@]}"
do
	ClosureJS+=" --js script/${var}"
	ScriptTags+="<script src=\"script\\/${var}\"><\\/script>"
done

# java -jar ../closurecompiler/compiler.jar \
# 	--js_output_file min/theMOD.min.js \
#  	--warning_level=QUIET --jscomp_off=suspiciousCode \
# 	$ClosureJS



echo "Creating default.dev.html"
sed -e "s/THEMODSCRIPTSHERE/$ScriptTags/g" default.src.html >default.dev.html

# echo "Creating default.html"
#     <script src="script/theMODmain.js"></script>
sed -e $"s/THEMODSCRIPTSHERE/<script src=\"min\/theMOD.min.js\"><\/script>/g" default.src.html >default.html

echo "Done!"

popd >/dev/null



