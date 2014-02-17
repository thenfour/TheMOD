
#pragma once

#include "layerNavBackground.hpp"

namespace TopRightSquaresLayer
{
	struct SquareFieldConfig
	{
		TheModColorMixingTable evenColorTable;
		TheModColorMixingTable oddColorTable;

		uint top = 0;
		uint left = 0;
		uint height = 200;// set this before rendering.
		bool xflip = true;
		uint blockSizeX = 30;
		uint blockSizeY = 30;
		bool showTwinkle = true;
		bool oddFillEnabled = true;
		bool evenFillEnabled = false;
		double opacitySpeedX = 0.15;
		double opacitySpeedY = 0.15;
		RandEnvelope opacityXEnv;
		RandEnvelope opacityYEnv;

		SquareFieldConfig() :
			evenColorTable(lightPurple(), 0xffffff, 8),
			oddColorTable(0xcccccc, 0xffffff, 8),
			opacityXEnv(145, opacitySpeedX),
			opacityYEnv(146, opacitySpeedY)
		{
		}

		uint RowWidth(uint y, uint top, uint bottom, uint canvasWidth, uint canvasHeight) const
		{
			return canvasWidth;
		}

		double Opacity(uint x, uint y, uint top, uint bottom, uint left, uint right, uint previousRowWidth, uint thisRowWidth, uint ix, uint iy) const
		{
			double yprog = 1.0 - (double(y - top) / (bottom - top));
			double xprog = 1.0 - (double(x - left) / (right - left));
			return 0.9 * (pow(yprog, 2) * pow(xprog, 2));
		}
	};

	SquareFieldConfig config;// singleton basically.

	inline void Render(uint frameTimeMS, uint canvasWidth, uint canvasHeight)
	{
		SquareField::Render(frameTimeMS, canvasWidth, canvasHeight, config);
	}
}


extern "C" void cppRenderTopRightSquaresLayer(uint frameTimeMS, uint width, uint height)
{
	TopRightSquaresLayer::Render(frameTimeMS, width, height);
}


