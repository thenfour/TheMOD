


function RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, config)
{
	var rotationEnvX = new RandEnvelope(147);
	var rotationEnvY = new RandEnvelope(148);
	var opacityXEnv =	new RandEnvelope(145);
	var opacityYEnv = new RandEnvelope(146);

	var showTwinkle = config.showTwinkle;

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
	var dimensionMult = 22;
	var previousRowWidth = null;
	var rowWidth = null;

	for(var y = top; y < bottom; y += blockSizeY)
	{
		var iy = (y - top) / blockSizeY;

		previousRowWidth = rowWidth;
		rowWidth = config.RowWidthFunction(y, top, bottom);
		if(!previousRowWidth)
			previousRowWidth = rowWidth;

		var right = left + rowWidth;

		for(var x = left; x < rowWidth; x += blockSizeX)
		{
			var ix = (x - left) / blockSizeX;

			var fillColor = config.oddFillColor;
			var strokeColor = config.oddStrokeColor;
			var strokeWidth = config.oddStrokeWidth;
			if((ix & 1) == (iy & 1))// checkerboard
			{
				fillColor = config.evenFillColor;
				strokeColor = config.evenStrokeColor;
				strokeWidth = config.evenStrokeWidth;
			}

			if(!fillColor && !strokeColor)
				continue;

			ctx.save();

			var xalphaVary = (opacityXEnv.height({ time: (x * dimensionMult) + frame.time }, opacitySpeedX) + 1) / 2;
			var yalphaVary = (opacityYEnv.height({ time: (y * dimensionMult) + frame.time}, opacitySpeedY) + 1) / 2;

			var userAlpha = config.OpacityFunction(x, y, top, bottom, left, right, previousRowWidth, rowWidth);

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

			ctx.translate(x + (thisBlockSizeX / 2), y + (blockSizeY / 2));// this is actually incorrect; for a true grid use blockSizeX / Y, but this gives a cool effect that things are sorta wavy / bulgy
			//ctx.translate(x + (blockSizeX / 2), y + (blockSizeY / 2));
			
			ctx.rotate((Math.PI) *
				((rotationEnvX.height({ time: (x * dimensionMult) + frame.time}, rotationSpeedX)
				+ rotationEnvY.height({ time: (y * dimensionMult) + frame.time}, rotationSpeedY)) / 2)
				* rotationMaximum);

			//ctx.fillRect(-(thisBlockSizeX / 2), -(thisBlockSizeY / 2), thisBlockSizeX, thisBlockSizeY);
			ctx.beginPath();
			ctx.rect(-(thisBlockSizeX / 2), -(thisBlockSizeY / 2), thisBlockSizeX, thisBlockSizeY);

			if(fillColor && !showTwinkle)
			{
				ctx.fillStyle = ColorToRGBA(fillColor, opacity * userAlpha);
				ctx.fill();
			}
			if(showTwinkle)
			{
				var twinkleSpeed = 0.18;
				var twinkleThreshold = 0.86;
				var maxTwilightStrokeWidth = 6;
				var maxTwinkleOpacity = 0.3;

				var twinkleFactor = CachedRandEnvelope(ix, iy).factor(frame, twinkleSpeed);
				if(twinkleFactor < twinkleThreshold)
				{
					ctx.fillStyle = ColorToRGBA(fillColor, opacity * userAlpha);
					ctx.fill();
				}
				else
				{
					// scale it to 0-1
					twinkleFactor = (twinkleFactor - twinkleThreshold) / (1 - twinkleThreshold);

					var twinkleOpacity = twinkleFactor * maxTwinkleOpacity;
					var halfTwilightStrokeWidth = twinkleOpacity * (maxTwilightStrokeWidth / 2);//1;

					// this puts the stroke INSIDE the underlying.
					var finalOpacity = (1 - (opacity * userAlpha)) * twinkleOpacity;
					finalOpacity += (opacity * userAlpha);
					ctx.fillStyle = MixColorsAndAddAlpha(fillColor, "#fff", twinkleFactor, finalOpacity);
					ctx.fill();
				}
			}

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
		evenStrokeColor: null,//'#666',
		evenStrokeWidth: 1,
		oddFillColor: medPurple,
		oddStrokeColor: null,
		oddStrokeWidth: 0,
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

		OpacityFunction: function(x, y, top, bottom, left, right, previousRowWidth, thisRowWidth){
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

