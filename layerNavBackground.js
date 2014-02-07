


function RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, config)
{
	var rotationEnvX = new RandEnvelope(147);
	var rotationEnvY = new RandEnvelope(148);
	var opacityXEnv =	new RandEnvelope(145);
	var opacityYEnv = new RandEnvelope(146);

	var showHighlights = true;
	var highlightEnvX = new RandEnvelope(155);
	var highlightEnvY = new RandEnvelope(165);
	var highlightSpeedX = .3;
	var highlightSpeedY = .3;
	var highlightBlockSizeFactorX = 2.0;
	var highlightBlockSizeFactorY = 2.0;

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

			ctx.globalAlpha = opacity * userAlpha;

			//ctx.fillRect(-(thisBlockSizeX / 2), -(thisBlockSizeY / 2), thisBlockSizeX, thisBlockSizeY);
			ctx.beginPath();
			ctx.rect(-(thisBlockSizeX / 2), -(thisBlockSizeY / 2), thisBlockSizeX, thisBlockSizeY);

			if(fillColor)
			{
				ctx.fillStyle = fillColor;
				ctx.fill();
			}
			if(strokeColor)
			{
				ctx.lineWidth = strokeWidth;
				ctx.strokeStyle = strokeColor;
				ctx.stroke();
			}

			if(showHighlights)
			{
				var highlightX = (highlightEnvX.height({ time: (x * dimensionMult) + frame.time }, highlightSpeedX) + 1) / 2;
				var highlightY = (highlightEnvY.height({ time: (y * dimensionMult) + frame.time }, highlightSpeedY) + 1) / 2;
				//var highlightZ = (highlightEnvY.height({ time: (y*x * dimensionMult * 2) + frame.time }, highlightSpeedY) + 1) / 2;
				// mix X and Y highlights
				var highlightBrightness = (highlightX + highlightY) / 2;
				// fit it to a curve like photoshop
				highlightBrightness = Math.sin(highlightBrightness * Math.PI / 2);
				//highlightBrightness = Math.pow(highlightBrightness, 2);
				if(highlightBrightness > 0.95)
				{
					var highlightBlockSizeX = thisBlockSizeX * highlightBlockSizeFactorX;
					var highlightBlockSizeY = thisBlockSizeY * highlightBlockSizeFactorY;
					ctx.fillStyle = 'rgba(255,255,255,' + highlightBrightness + ')';
					ctx.fillRect(-(highlightBlockSizeX / 2), -(highlightBlockSizeY / 2), highlightBlockSizeX, highlightBlockSizeY);
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

