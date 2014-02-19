#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null
# we are in the build directory.

# lets get in the www directory.
cd ../www

# this would be useful if we use the closure library for dependencies. right now we're too simple to care about this.
# python script/closure-library/closure/bin/build/closurebuilder.py \
# 	--root=script \
# #	--namespace="theMOD.main" \
# 	--output_mode=compiled \
# 	--compiler_jar=../closurecompiler/compiler.jar \
# 	--output_file=min/theMOD.min.js \
# 	--compiler-flags=--js=

echo "Calling closure compiler...."

java -jar ../closurecompiler/compiler.jar --js_output_file min/theMOD.min.js \
	--warning_level=QUIET --jscomp_off=suspiciousCode \
	--js "script/jquery-1.11.0.min.js" \
	--js "script/jquery.mousewheel.js" \
	--js "script/jquery.jscrollpane.min.js" \
	--js "script/mersenne-twister.js" \
	--js "script/themodImage.js" \
	--js "script/themodTween.js" \
	--js "script/themodutil.js" \
	--js "script/theModFakeStorage.js" \
	--js "script/theModCMS.js" \
	--js "script/theModAudio.js" \
	--js "script/themodengine.js" \
	--js "script/layerBackground.js" \
	--js "script/layerTopCurtain.js" \
	--js "script/layerLogo.js" \
	--js "script/layerSun.js" \
	--js "script/layerScroller.js" \
	--js "script/layerNavBackground.js" \
	--js "script/layerTopRightSquares.js" \
	--js "script/themodrenderer.js" \
	--js "script/theMODmain.js"

echo "Done!"



popd >/dev/null
