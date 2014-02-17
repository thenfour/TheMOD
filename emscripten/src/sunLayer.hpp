
#pragma once

#include "themodTween.hpp"

namespace SunLayer
{
	static const uint pointCount = 14;
	static const uint bigPointRadius = 150;
	static const uint bigPointRadiusVariation = 45;

	static const uint littlePointRadius = 120;
	static const uint littlePointRadiusVariation = 15;

	static const uint innerPointRadius = 65;

	static const uint circleRadius = 45;
	static const uint circleStrokeWidth = 19;

	static const uint backCircleRadius = 95;
	static const uint baseY = 180;

	static RandEnvelope rotationEnv(1247, 0.011);
	static RandEnvelope bigRadiusEnv(2624, 0.1);
	static RandEnvelope littleRadiusEnv(899, 0.1);

	static Tween<Easing::BounceOut> OpeningTween(4.8, 0);

	inline void RenderSunLayer(uint frameTimeMS, uint width, uint height)
	{
		double x = 0.8 * width;
		double y = baseY + OpeningTween.tween(frameTimeMS, -300, 0);

		double mainRotation = pi() * 2 * rotationEnv.height(frameTimeMS);

	 	double innerR = innerPointRadius;
		double smallR = littleRadiusEnv.vary(frameTimeMS, littlePointRadius, littlePointRadiusVariation);
		double bigR = bigRadiusEnv.vary(frameTimeMS, bigPointRadius, bigPointRadiusVariation);

		// make a star with alternating points.
		canvasSave();
		canvasTranslate(x, y);
		canvasRotate(mainRotation);
		canvasSetShadowOffsetY(5);
		canvasSetSunLayerShadowColor();

		// draw back circle
		canvasBeginPath();
		canvasArc(0,0,backCircleRadius, 0, 2*pi());
		canvasSetFillStyle(darkYellow());
		canvasFill();

		// start at the inner radius
		canvasBeginPath();
		canvasMoveTo(0, -innerR);

		// for each iteration we draw 2 star points, which consist of 2 draw points each. so we have to draw 4 points each iteration, each at different angle along the circle.
		double rotateAmtPerPoint = (pi()*2) / (pointCount * 2);
		for(uint i = 0; i < pointCount / 2; ++ i)
		{
			canvasRotate(rotateAmtPerPoint);
			canvasLineTo(0, -bigR);
			canvasRotate(rotateAmtPerPoint);
			canvasLineTo(0, -innerR);
			canvasRotate(rotateAmtPerPoint);
			canvasLineTo(0, -smallR);
			canvasRotate(rotateAmtPerPoint);
			canvasLineTo(0, -innerR);
		}
		canvasClosePath();

		canvasSetSunLayerGradientFill(bigR);
		canvasFill();

		// start over and create a cool circle in the middle.

		canvasSetShadowOffsetX(0);
		canvasSetShadowOffsetY(0);

		canvasBeginPath();
		canvasArc(0,0,circleRadius, 0, pi()*2);

		canvasSetLineWidth(circleStrokeWidth);
		canvasSetStrokeStyle(0xffe08c);
		canvasStroke();

		canvasRestore();
	}
};

extern "C" void cppRenderSunLayer(uint frameTime, uint width, uint height)
{
	SunLayer::RenderSunLayer(frameTime, width, height);
}
