


function RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, config)
{
	var rotationEnvX = new RandEnvelope(147);
	var rotationEnvY = new RandEnvelope(148);
	var opacityXEnv =	new RandEnvelope(145);
	var opacityYEnv = new RandEnvelope(146);
	var left = config.left;
	var top = config.top;
	var bottom = top + config.height;

	var blockSizeX = config.blockSizeX;// multiple of 2, for the rotation
	var blockSizeY = blockSizeX;// multiple of 2, for the rotation
	var scaleMin = 0.5;
	var scaleMax = 1.7;
	var rotationMaximum = 0.5;// 0 - 1=90 deg.
	var rotationSpeedX = 0.12;
	var rotationSpeedY = 0.06;

	var opacitySpeedX = 0.1;
	var opacitySpeedY = 0.1;
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

	for(var y = top; y < bottom; y += blockSizeY)
	{
		var iy = (y - top) / blockSizeY;

		var rowWidth = config.RowWidthFunction(y, top, bottom);
		var right = left + rowWidth;

		for(var x = left; x < rowWidth; x += blockSizeX)
		{
			var ix = (x - left) / blockSizeX;

			var fillColor = config.oddFillColor;
			if((ix & 1) == (iy & 1))// checkerboard
				fillColor = config.evenFillColor;
			if(!fillColor)
				continue;
			ctx.fillStyle = fillColor;

			ctx.save();

			var xalphaVary = (opacityXEnv.height({ time: (x * dimensionMult) + frame.time }, opacitySpeedX) + 1) / 2;
			var yalphaVary = (opacityYEnv.height({ time: (y * dimensionMult) + frame.time}, opacitySpeedY) + 1) / 2;

			var userAlpha = config.OpacityFunction(x, y, top, bottom, left, right);

			var alpha = xalphaVary * yalphaVary;

			// now scale alpha to opacityMin / Max
			var opacity = opacityMin + (alpha * (opacityMax - opacityMin));

			var aa = 1.0;// anti-alias damping
			if(((x - left) + blockSizeX) > rowWidth)
			{
				// "big" anti-alias this block.
				aa = (rowWidth - (x - left)) / blockSizeX;
				// aa should have a bit less effect
				aa = 1-((1-aa)*0.5);
			}

			var thisBlockSizeX = blockSizeX * (scaleMin + ((scaleMax - scaleMin) * alpha * aa));
			var thisBlockSizeY = blockSizeY * (scaleMin + ((scaleMax - scaleMin) * alpha * aa));

			ctx.translate(x + (thisBlockSizeX / 2), y + (thisBlockSizeY / 2));// this is actually incorrect; for a true grid use blockSizeX / Y, but this gives a cool effect that things are sorta wavy / bulgy
			//ctx.translate(x + (blockSizeX / 2), y + (blockSizeY / 2));
			
			ctx.rotate((Math.PI) *
				((rotationEnvX.height({ time: (x * dimensionMult) + frame.time}, rotationSpeedX)
				+ rotationEnvY.height({ time: (y * dimensionMult) + frame.time}, rotationSpeedY)) / 2)
				* rotationMaximum);

			ctx.globalAlpha = opacity * aa * userAlpha;

			ctx.fillRect(-(thisBlockSizeX / 2), -(thisBlockSizeY / 2), thisBlockSizeX, thisBlockSizeY);
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
	var navWidth = 160;
	var top = 200;

	RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, {
		xflip: false,
		evenFillColor: lightPurple,
		oddFillColor: medPurple,
		left: 0,
		top: top,
		height: canvasHeight - top - 43,
		blockSizeX: 18,
		RowWidthFunction: function(y, top, bottom){
			if(y >= footerStartsAtY)
				return canvasWidth;
			// use exponential function. scale y to 0-1
			var yprog = (y - top) / (bottom - top);
			yprog = Math.pow(yprog, 20);
			return navWidth + ((canvasWidth - navWidth) * yprog);
		},
		OpacityFunction: function(x, y){
			return 1.0;
		}
	});
};

