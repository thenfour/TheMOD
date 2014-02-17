

#pragma once

#include "theMODUtil.hpp"

const uint ColorMixingSteps = 8;

namespace SquareField
{
	template<typename TConfig>
	void Render(uint frameTimeMS, double canvasWidth, double canvasHeight, const TConfig& config)
	{
		uint bottom = config.top + config.height;

		const double scaleMin = 0.5;
		const double scaleMax = 1.7;
		const double rotationMaximum = 0.5;// 0 - 1=90 deg.
		const double rotationSpeedX = 0.15;
		const double rotationSpeedY = 0.09;

		const double opacityMin = 0.3;
		const double opacityMax = 0.65;

		const double twinkleSpeed = 0.09;
		const double twinkleThreshold = 0.93;
		// these two will adjust the twinkle effect. it affects opacity of the square, and the color. both of these are 0-1.
		const double maxTwinkleOpacity = 0.5;
		const double twinkleBrightness = 0.5;

	 	if(config.xflip)
	 	{
	 		squareFieldXFlip(canvasWidth / 2);
	 	}
	 	else
	 	{
			canvasSave();
	 	}

		// when modulating envelopes, how much does x/y dimension affect the
		// envelope progression?
		// values 0-20 will be plasma-like; higher can start to look more sharp / twinkly
		double dimensionMult = 20;
		int previousRowWidth = -1;
		int rowWidth = -1;

	 	for(uint y = config.top; y < bottom; y += config.blockSizeY)
	 	{
	 		uint iy = (y - config.top) / config.blockSizeY;

	 		previousRowWidth = rowWidth;
	 		rowWidth = config.RowWidth(y, config.top, bottom, canvasWidth, canvasHeight);
	 		if(previousRowWidth == -1)
 				previousRowWidth = rowWidth;

	 		uint right = config.left + rowWidth;

	 		for(uint x = config.left; x < rowWidth; x += config.blockSizeX)
	 		{
	 			uint ix = (x - config.left) / config.blockSizeX;
				//squareFieldRenderSquare(0.5, 0.5, 0.5, 0.5, 0xff00ff, 0.5, 8);

	 			bool isOdd = ((ix & 1) == (iy & 1));// checkerboard

	 			if(!config.oddFillEnabled && isOdd)
					continue;
	 			if(!config.evenFillEnabled && !isOdd)
					continue;

				const TheModColorMixingTable<ColorMixingSteps>& fillColorTable(isOdd ? config.oddColorTable : config.evenColorTable);

	 			double xalphaVary = (config.opacityXEnv.height((dimensionMult * x) + frameTimeMS) + 1) / 2;
	 			double yalphaVary = (config.opacityYEnv.height((dimensionMult * y) + frameTimeMS) + 1) / 2;

	 			double userAlpha = config.Opacity(x, y, config.top, bottom, config.left, right, previousRowWidth, rowWidth, ix, iy);

				double aa = 1.0;// anti-alias damping
				if(((x - config.left) + config.blockSizeX) > rowWidth)
				{
					// "big" anti-alias this block.
					aa = double(rowWidth - (x - config.left)) / config.blockSizeX;
				}

 				double alpha = xalphaVary * yalphaVary * aa;

	 			// now scale alpha to opacityMin / Max
	 			double opacity = opacityMin + (alpha * (opacityMax - opacityMin));

				double blockScale = (scaleMin + ((scaleMax - scaleMin) * alpha * userAlpha));
				double thisBlockSizeX = blockScale * config.blockSizeX;

				// this is actually incorrect; for a true grid use blockSizeX / Y, but this gives a cool effect that things are sorta wavy / bulgy
				double xtrans = (double)x + ((double)thisBlockSizeX / 2);
				double ytrans = (double)y + ((double)config.blockSizeY / 2);

				double twinkleFactor = CachedRandEnvelope(ix, iy, twinkleSpeed).factor(frameTimeMS);
				TheModColor fillStyle;
				double finalOpacity;
				if(twinkleFactor < twinkleThreshold)
				{
					finalOpacity = opacity * userAlpha;
					fillStyle = fillColorTable.c1;
				}
				else
				{
					// scale it to 0-1
					twinkleFactor = (twinkleFactor - twinkleThreshold) / (1.0 - twinkleThreshold);

					double twinkleOpacity = twinkleFactor * maxTwinkleOpacity;

					finalOpacity = (1.0 - (opacity * userAlpha)) * twinkleOpacity;
					finalOpacity += (opacity * userAlpha);
					fillStyle = fillColorTable.GetColor(twinkleFactor * twinkleBrightness);
				}

				double rotation = 2.0 * pi() * finalOpacity;

				squareFieldRenderSquare(finalOpacity, xtrans, ytrans, rotation, fillStyle, -(thisBlockSizeX / 2), thisBlockSizeX);
				
			}// X
		}// Y

		canvasRestore();
	}
}



namespace NavBackgroundLayer
{
	struct SquareFieldConfig
	{
		TheModColorMixingTable<ColorMixingSteps> evenColorTable;
		TheModColorMixingTable<ColorMixingSteps> oddColorTable;

		const uint navWidth = 184;// it's cool to make this NOT an even multiple of blockSizeX, so the blocks get a different size because of our "big" anti-aliasing
		uint footerStartsAtY;// set this before rendering

		const uint top = 180;
		const bool xflip = false;
		const uint left = 0;
		uint height;// set this before rendering.
		const uint blockSizeX = 18;
		const uint blockSizeY = 18;
		const bool showTwinkle = true;
		const bool oddFillEnabled = true;
		const bool evenFillEnabled = true;
		const double opacitySpeedX = 0.15;
		const double opacitySpeedY = 0.15;
		const RandEnvelope opacityXEnv;
		const RandEnvelope opacityYEnv;

		SquareFieldConfig() :
			evenColorTable(lightPurple(), 0xffffff),
			oddColorTable(medPurple(), 0xffffff),
			opacityXEnv(145, opacitySpeedX),
			opacityYEnv(146, opacitySpeedY)
		{
		}

		uint RowWidth(uint y, uint top, uint bottom, uint canvasWidth, uint canvasHeight) const
		{
			if(y >= footerStartsAtY)
				return canvasWidth;
			double yprog = double(y - top) / (footerStartsAtY - top);
			yprog = pow(yprog, 25);
			return (navWidth) + ((canvasWidth - navWidth) * yprog);
		}

		double Opacity(uint x, uint y, uint top, uint bottom, uint left, uint right, uint previousRowWidth, uint thisRowWidth, uint ix, uint iy) const
		{
			if(y >= footerStartsAtY)
				return 1.0;

			uint xPositionOnRow = x - left;
			uint rowWidthDelta = thisRowWidth - previousRowWidth;
			if(xPositionOnRow < previousRowWidth)
				return 1.0;// it's still within the previous row; don't aa

			// how far along the NEW segment are we?
			double aaprog = double(xPositionOnRow - previousRowWidth) / rowWidthDelta;
			aaprog = 1.0 - aaprog;
			return pow(aaprog, 6);
		}
	};

	SquareFieldConfig config;// singleton basically.

	inline void Render(uint frameTimeMS, uint canvasWidth, uint canvasHeight)
	{
		config.footerStartsAtY = canvasHeight - 90;
		config.height = (canvasHeight - config.top - 43);

		SquareField::Render(frameTimeMS, canvasWidth, canvasHeight, config);
	}
}

extern "C" void cppRenderNavBackgroundLayer(uint frameTimeMS, uint width, uint height)
{
	NavBackgroundLayer::Render(frameTimeMS, width, height);
}


