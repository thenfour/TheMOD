

var NavBackgroundLayer = function()
{
	this.rotationEnvX = new RandEnvelope(147);
	this.rotationEnvY = new RandEnvelope(148);

	this.opacityXEnv =	new RandEnvelope(145);
	this.opacityYEnv = new RandEnvelope(146);
};

NavBackgroundLayer.prototype.Render = function(frame, ctx, canvasWidth, canvasHeight)
{
	var top = 200;
	var width = 160;
	var bottom = canvasHeight - 60;
	var blockSizeX = 18;// multiple of 2, for the rotation
	var blockSizeY = 18;// multiple of 2, for the rotation
	var blockSizeAnimScaleX = 3.5;// how much is the block scaled by alpha?
	var blockSizeAnimScaleY = 3.5;// how much is the block scaled by alpha?
	var rotationMaximum = .5;// 0 - 1=90 deg.
	var rotationSpeedX = 0.12;
	var rotationSpeedY = 0.06;

	var opacitySpeedX = 0.1;
	var opacitySpeedY = 0.1;
	var opacityMin = 0.2;
	var opacityMax = 0.5;


	//var halfBlockSizeX = blockSizeX / 2;
	//var halfBlockSizeY = blockSizeY / 2;

	// when modulating envelopes, how much does x/y dimension affect the
	// envelope progression?
	// values 0-20 will be plasma-like; higher can start to look more sharp / twinkly
	var dimensionMult = 22;

	for(var y = top; y < bottom; y += blockSizeY)
	{
		var iy = (y - top) / blockSizeY;
		for(var x = 0; x < width; x += blockSizeX)
		{
			var ix = (x / blockSizeX);
			// do we skip this one?
			if((ix % 2) == (iy % 2))
				ctx.fillStyle = darkPurple;
			else
				ctx.fillStyle = lightPurple;

			ctx.save();

			var alpha = (this.opacityXEnv.height({ time: (x * dimensionMult) + frame.time }, opacitySpeedX)
					+ this.opacityYEnv.height({ time: (y * dimensionMult) + frame.time}, opacitySpeedY)) / 2;
			if(alpha < 0) alpha = 0;
			if(alpha > 1) alpha = 1;

			// now scale alpha to opacityMin / Max
			alpha = opacityMin + (alpha * (opacityMax - opacityMin));

			var thisBlockSizeX = blockSizeX * alpha * blockSizeAnimScaleX;
			var thisBlockSizeY = blockSizeY * alpha * blockSizeAnimScaleY;

			ctx.translate(x + (thisBlockSizeX / 2), y + (thisBlockSizeY / 2));
			
			ctx.rotate((Math.PI) *
				((this.rotationEnvX.height({ time: (x * dimensionMult) + frame.time}, rotationSpeedX)
				+ this.rotationEnvY.height({ time: (y * dimensionMult) + frame.time}, rotationSpeedY)) / 2)
				* rotationMaximum);

			ctx.globalAlpha = alpha;

			ctx.fillRect(-(thisBlockSizeX / 2), -(thisBlockSizeY / 2), thisBlockSizeX, thisBlockSizeY);
			ctx.restore();
		}
	}
};

