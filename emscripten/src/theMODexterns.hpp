
#pragma once

#include <string>
#include "theMODUtil.hpp"

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

	void canvasSetGlobalAlpha(double x);
	void __canvasSetFillStyle(unsigned int s);

	void __canvasSetStrokeStyle(unsigned int s);
	void canvasFillRect(double x, double y, double w, double h);
	void canvasRect(double x, double y, double w, double h);

	void canvasSave();
	void canvasRestore();
	void canvasTranslate(double x, double y);
	void canvasRotate(double r);
	void canvasScale(double x, double y);
	void canvasSetShadowOffsetX(double y);
	void canvasSetShadowOffsetY(double y);
	void canvasBeginPath();
	void canvasArc(double x, double y, double radius, double startAngle, double endAngle);
	void canvasFill();
	void canvasMoveTo(double x, double y);
	void canvasLineTo(double x, double y);
	void canvasClosePath();
	void canvasSetLineWidth(double w);
	void canvasStroke();

	void canvasSetSunLayerShadowColor();// // 	ctx.shadowColor = 'rgba(0,0,0,0.2)';
	void canvasSetSunLayerGradientFill(double bigR);//
	//   var grd = ctx.createRadialGradient(0, 0, 0, 0, 0, bigR);
//   grd.addColorStop(0, '#ffc');
//   grd.addColorStop(0.15, '#fed58c');
//   grd.addColorStop(1, '#e19c26');

//   ctx.fillStyle = grd;


}

inline void canvasSetFillStyle(const TheModColor& s)
{
	__canvasSetFillStyle(s.rgb() | 0x01000000);
}

inline void canvasSetStrokeStyle(const TheModColor& s)
{
	__canvasSetStrokeStyle(s.rgb() | 0x01000000);
}



