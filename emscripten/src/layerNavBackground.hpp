

#pragma once

#include "theMODUtil.hpp"

namespace SquareField
{
	template<typename T>
	void Render(uint frameTimeMS, double canvasWidth, double canvasHeight, const T& config)
	{
		//var specialWhite = { r:255,g:255,b:255 };

		uint bottom = config.top + config.height;

		double scaleMin = 0.5;
		double scaleMax = 1.7;
		double rotationMaximum = 0.5;// 0 - 1=90 deg.
		double rotationSpeedX = 0.15;
		double rotationSpeedY = 0.09;

		double opacityMin = 0.3;
		double opacityMax = 0.65;

		double twinkleSpeed = 0.09;
		double twinkleThreshold = 0.93;
		// these two will adjust the twinkle effect. it affects opacity of the square, and the color. both of these are 0-1.
		double maxTwinkleOpacity = 0.5;
		double twinkleBrightness = 0.5;

		canvasSave();
	 	if(config.xflip)
	 	{
	 		canvasTranslate(canvasWidth / 2, 0);
	 		canvasScale(-1, 1);
	 		canvasTranslate(-(canvasWidth / 2), 0);
	 	}

		// when modulating envelopes, how much does x/y dimension affect the
		// envelope progression?
		// values 0-20 will be plasma-like; higher can start to look more sharp / twinkly
		double dimensionMult = 20;
		uint previousRowWidth = -1;
		uint rowWidth = -1;

// 	var time = frame.time;

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

	 			bool isOdd = ((ix & 1) == (iy & 1));// checkerboard

	 			if(!config.oddFillEnabled && isOdd)
					continue;
	 			if(!config.evenFillEnabled && !isOdd)
					continue;

				const TheModColorMixingTable& fillColorTable(isOdd ? config.oddColorTable : config.evenColorTable);

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
				//var thisBlockSizeY = blockSizeY * (scaleMin + ((scaleMax - scaleMin) * alpha * userAlpha));

				// this is actually incorrect; for a true grid use blockSizeX / Y, but this gives a cool effect that things are sorta wavy / bulgy
				double xtrans = (double)x + ((double)thisBlockSizeX / 2);
				double ytrans = (double)y + ((double)config.blockSizeY / 2);
				//ctx.translate(x + (blockSizeX / 2), y + (blockSizeY / 2));

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
					//twinkleFactor = twinkleFactor * twinkleFactor;

					double twinkleOpacity = twinkleFactor * maxTwinkleOpacity;

					finalOpacity = (1.0 - (opacity * userAlpha)) * twinkleOpacity;
					finalOpacity += (opacity * userAlpha);
					//fillStyle = MixColorsTwiceSpecial(fillColor, specialWhite, twinkleFactor * twinkleBrightness, config.backgroundColor, 1 - finalOpacity);
					fillStyle = fillColorTable.GetColor(twinkleFactor * twinkleBrightness);
				}

				double rotation = 2.0 * pi() * finalOpacity;
				// we could maybe have some squares that rotate a different direction.
				//if(ix % 2 == 0)
				//	rotation = 6.283 - rotation;

				canvasSave();
// 			ctx.save();
// 			// things get really cool if you transpose rotate & translate here
				canvasSetGlobalAlpha(finalOpacity);
// 			ctx.globalAlpha = finalOpacity;
				canvasTranslate(xtrans, ytrans);
// 			ctx.translate(xtrans, ytrans);
				canvasRotate(rotation);
// 			ctx.rotate(rotation);
				canvasBeginPath();
// 			ctx.beginPath();
				canvasRect(-(thisBlockSizeX / 2), -(thisBlockSizeX / 2), thisBlockSizeX, thisBlockSizeX);
// 			ctx.rect(-(thisBlockSizeX / 2), -(thisBlockSizeX / 2), thisBlockSizeX, thisBlockSizeX);
				canvasSetFillStyle(fillStyle);
// 			ctx.fillStyle = fillStyle;
				canvasFill();
// 			ctx.fill();
// 			//ctx.drawImage(tbutton.img, x, y);

				canvasRestore();
// 			ctx.restore();//*/
			}// X
// 		}
		}// Y
// 	}

		canvasRestore();
// 	ctx.restore();

// 	returnRect.width = returnRect.right - returnRect.left;
// 	returnRect.height = returnRect.bottom - returnRect.top;

// 	return returnRect;
// }
	}

}



namespace NavBackgroundLayer
{
	struct SquareFieldConfig
	{
		TheModColorMixingTable evenColorTable;
		TheModColorMixingTable oddColorTable;

		uint navWidth;// it's cool to make this NOT an even multiple of blockSizeX, so the blocks get a different size because of our "big" anti-aliasing
		uint top;
		bool xflip;
		uint left;
		uint height;// set this before rendering.
		uint blockSizeX;
		uint blockSizeY;
		bool showTwinkle;
		uint footerStartsAtY;// set this before rendering
		bool oddFillEnabled = true;
		bool evenFillEnabled = true;
		double opacitySpeedX = 0.15;
		double opacitySpeedY = 0.15;
		RandEnvelope opacityXEnv;
		RandEnvelope opacityYEnv;

		SquareFieldConfig() :
			evenColorTable(lightPurple(), 0xffffff, 8),
			oddColorTable(medPurple(), 0xffffff, 8),
			navWidth(184),
			top(180),
			xflip(false),
			left(0),
			blockSizeX(18),
			blockSizeY(18),
			showTwinkle(true),
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


