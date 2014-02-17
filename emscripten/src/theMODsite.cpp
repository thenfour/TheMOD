

#include <emscripten.h>
#include "theMODexterns.hpp"
#include "theMODUtil.hpp"
#include "sunLayer.hpp"
#include "layerNavBackground.hpp"
#include "layerTopRightSquares.hpp"


extern "C" double cppTest(const wchar_t* str)
{
	return 1.0;//p.length();
}

extern "C" void cppInit()
{
}

extern "C" void cppRender(unsigned int frameTime, unsigned int width, unsigned int height)
{
}

