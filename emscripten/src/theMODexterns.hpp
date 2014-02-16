
#pragma once

#include <string>

/*

NOTE: These declarations must match those in theMODexternalLib.js

todo: figure out what kind of datatypes are supported...
https://github.com/kripken/emscripten/wiki/Interacting-with-code#calling-js-functions-as-function-pointers-from-c

- int / float / == obvious.
- pointers = numbers
- javascript strings must be converted to pointers for compiled code
	the relevant functions are Pointer_stringify which given a pointer returns a JavaScript string,

	and the other direction can be accomplished by

	allocate(intArrayFromString(someString), 'i8', ALLOC_STACK)


	which will convert a JavaScript string someString to a pointer. Note that conversion to a pointer allocates
	memory (that's the call to allocate there).

*/


extern "C"
{
	void jsalert(std::string s);

	//void canvasTranslate(double x, double y);
	//void canvasRotate(double r);
	//void canvasScale(double s);
	void canvasSetGlobalAlpha(double x);
	void __canvasSetFillStyle(unsigned int s);
	void __canvasSetStrokeStyle(unsigned int s);
	void canvasFillRect(double x, double y, double w, double h);
}

inline void canvasSetFillStyle(unsigned int s)
{
	__canvasSetFillStyle(s | 0x01000000);
}

inline void canvasSetStrokeStyle(unsigned int s)
{
	__canvasSetStrokeStyle(s | 0x01000000);
}



