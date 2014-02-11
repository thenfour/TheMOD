// optimization:
// of the 8 ms to render, about 6 of it is in translate/rotate/rect/fill.
// maybe go 2x2?

function RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, config)
{
	var rotationEnvX = CachedRandEnvelope(147, 0);
	var rotationEnvY = CachedRandEnvelope(148, 0);
	var opacityXEnv =	CachedRandEnvelope(145, 0);
	var opacityYEnv = CachedRandEnvelope(146, 0);

	var showTwinkle = true;//config.showTwinkle;

	var left = config.left;
	var top = config.top;
	var bottom = top + config.height;

	var blockSizeX = config.blockSizeX;// multiple of 2, for the rotation
	var blockSizeY = blockSizeX;// multiple of 2, for the rotation
	var scaleMin = 0.5;
	var scaleMax = 1.7;
	var rotationMaximum = 0.5;// 0 - 1=90 deg.
	var rotationSpeedX = 0.15;
	var rotationSpeedY = 0.09;

	var opacitySpeedX = 0.15;
	var opacitySpeedY = 0.15;
	var opacityMin = 0.3;
	var opacityMax = 0.65;

	var evenFillColor = ParseHTMLColor(config.evenFillColor);
	var oddFillColor = ParseHTMLColor(config.oddFillColor);

	ctx.save();
	if(config.xflip)
	{
		ctx.translate(canvasWidth / 2, 0);
		ctx.scale(-1, 1);
		ctx.translate(-(canvasWidth / 2), 0);
	}

	// when modulating envelopes, how much does x/y dimension affect the
	// envelope progression?
	// values 0-20 will be plasma-like; higher can start to look more sharp / twinkly
	var dimensionMult = 20;
	var previousRowWidth = null;
	var rowWidth = null;

	for(var y = top; y < bottom; y += blockSizeY)
	{
		var iy = (y - top) / blockSizeY;

		previousRowWidth = rowWidth;
		rowWidth = config.RowWidthFunction(y, top, bottom, canvasWidth);
		if(!previousRowWidth)
			previousRowWidth = rowWidth;

		var right = left + rowWidth;

		for(var x = left; x < rowWidth; x += blockSizeX)
		{
			var ix = (x - left) / blockSizeX;

			var fillColor = oddFillColor;
			if((ix & 1) == (iy & 1))// checkerboard
			{
				fillColor = evenFillColor;
			}

			if(!fillColor)
				continue;

			var xalphaVary = (opacityXEnv.height({ time: (x * dimensionMult) + frame.time }, opacitySpeedX) + 1) / 2;
			var yalphaVary = (opacityYEnv.height({ time: (y * dimensionMult) + frame.time }, opacitySpeedY) + 1) / 2;

			var userAlpha = config.OpacityFunction(x, y, top, bottom, left, right, previousRowWidth, rowWidth, ix, iy);

			var aa = 1.0;// anti-alias damping
			if(((x - left) + blockSizeX) > rowWidth)
			{
				// "big" anti-alias this block.
				aa = (rowWidth - (x - left)) / blockSizeX;
			}

			var alpha = xalphaVary * yalphaVary * aa;

			// now scale alpha to opacityMin / Max
			var opacity = opacityMin + (alpha * (opacityMax - opacityMin));

			var thisBlockSizeX = blockSizeX * (scaleMin + ((scaleMax - scaleMin) * alpha * userAlpha));
			var thisBlockSizeY = blockSizeY * (scaleMin + ((scaleMax - scaleMin) * alpha * userAlpha));

			// this is actually incorrect; for a true grid use blockSizeX / Y, but this gives a cool effect that things are sorta wavy / bulgy
			var xtrans = x + (thisBlockSizeX / 2);
			var ytrans = y + (blockSizeY / 2);

			//ctx.translate(x + (blockSizeX / 2), y + (blockSizeY / 2));
		
			var twinkleSpeed = 0.15;
			var twinkleThreshold = 0.86;
			// these two will adjust the twinkle effect. it affects opacity of the square, and the color. both of these are 0-1.
			var maxTwinkleOpacity = 0.5;
			var twinkleBrightness = 0.5;

			var twinkleFactor = CachedRandEnvelope(ix, iy).factor(frame, twinkleSpeed);
			var fillStyle;
			if(twinkleFactor < twinkleThreshold)
			{
				var finalOpacity = opacity * userAlpha;
				fillStyle = ColorToRGBASpecial(fillColor, finalOpacity);
			}
			else
			{
				// scale it to 0-1
				twinkleFactor = (twinkleFactor - twinkleThreshold) / (1 - twinkleThreshold);

				var twinkleOpacity = twinkleFactor * maxTwinkleOpacity;

				var finalOpacity = (1 - (opacity * userAlpha)) * twinkleOpacity;
				finalOpacity += (opacity * userAlpha);
				fillStyle = MixColorsAndAddAlphaSpecial(fillColor, { r:255,g:255,b:255 }, twinkleFactor * twinkleBrightness, finalOpacity);
			}

			var rotation = (Math.PI) *
				((rotationEnvX.height({ time: (x * dimensionMult) + frame.time}, rotationSpeedX)
				+ rotationEnvY.height({ time: (y * dimensionMult) + frame.time}, rotationSpeedY)) / 2)
				* rotationMaximum;

			ctx.save();
			// things get really cool if you transpose rotate & translate here
			ctx.translate(xtrans, ytrans);
			ctx.rotate(rotation);
			ctx.beginPath();
			ctx.rect(-(thisBlockSizeX / 2), -(thisBlockSizeY / 2), thisBlockSizeX, thisBlockSizeY);
			ctx.fillStyle = fillStyle;
			ctx.fill();

			ctx.restore();
		}
	}

	ctx.restore();
}


var NavBackgroundLayer = function()
{
};

NavBackgroundLayer.prototype.Render = function(frame, ctx, canvasWidth, canvasHeight)
{
	var footerStartsAtY = canvasHeight - 90;
	var navWidth = 168;// it's cool to make this NOT an even multiple of blockSizeX, so the blocks get a different size because of our "big" anti-aliasing
	var top = 200;

	RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, {
		xflip: false,
		evenFillColor: lightPurple,
		//evenStrokeColor: null,//'#666',
		//evenStrokeWidth: 1,
		oddFillColor: medPurple,
		//oddStrokeColor: null,
		//oddStrokeWidth: 0,
		left: 0,
		top: top,
		height: canvasHeight - top - 43,
		blockSizeX: 18,
		showTwinkle: true,

		RowWidthFunction: function(y, top, bottom){
			if(y >= footerStartsAtY)
				return canvasWidth;
			var yprog = (y - top) / (footerStartsAtY - top);
			yprog = Math.pow(yprog, 25);
			return navWidth + ((canvasWidth - navWidth) * yprog);
		},

		OpacityFunction: function(x, y, top, bottom, left, right, previousRowWidth, thisRowWidth, ix, iy){
			if(y >= footerStartsAtY)
				return 1.0;

			var xPositionOnRow = x - left;
			var rowWidthDelta = thisRowWidth - previousRowWidth;
			if(xPositionOnRow < previousRowWidth)
				return 1.0;// it's still within the previous row; don't aa

			// how far along the NEW segment are we?
			var aaprog = (xPositionOnRow - previousRowWidth) / rowWidthDelta;
			aaprog = 1 - aaprog;
			return Math.pow(aaprog, 6);
		}
	});
};

