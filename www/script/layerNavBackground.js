// optimization:
// i might be able to pre-compute the squares onto their own canvas.
// the input dimensions are:
// time --> twinkle / alpha / size (fill color is computed based off these)
// 16 steps each  is 4096 images. At 18px squared, which with rotation and movement is like 30px squared, 30x30 = 900 pixels total, that's say 4,096,000 pixels.
// 4 million pixels isn't really that much. that's just a 2000x2000 image, about 16 MB. we can support one, even 2, of these.
//
// OK a lot of time is spent actually just processing the colors. 
// also, i can see that #abcdef colors are much faster than using rgba() colors.
/*

On optimization, I have tried a bunch of things;
* drawing direct to canvas but with scale() to work in smaller dimensions. this yields basically no gain because of sub-pixel just scales it back up. slightly slower.
* drawing to a separate canvas and drawImage scaled to the real one. This ends up being a lot of overhead that kills the performance.
* mirroring direct on canvas. only drawing half the squares, and drawImage to mirror it elsewhere on the screen. Losing a lot of beauty here, and it doesn't gain anything in performance,
  presumably because internally it must be copied first to a separate canvas and then back to the canvas. It's slower than just drawing all our squares.
* mirroring on a pre-made offscreen canvas. this doesn't gain anything either; you end up bitblting and you should just do the pixelated to separate canvas technique.
* don't use opacity; mix colors instead because the background is fixed, using global alpha. this is much faster! maybe i can now just precompute colors instead of square images.

I think indeed caching square images is going to be the best, as long as I can figure out a system that's not ridiculously memory intensive.
it will just be a lot of work to do this.


*/

//var specialWhite = { r:255,g:255,b:255 };
var opacitySpeedX = 0.15;
var opacitySpeedY = 0.15;
var opacityXEnv =	new RandEnvelope(145, opacitySpeedX);
var opacityYEnv = new RandEnvelope(146, opacitySpeedY);

function RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, config)
{
	var showTwinkle = true;//config.showTwinkle;

	var left = config.left;
	var top = config.top;
	var bottom = top + config.height;

	var returnRect = {
		left: left,
		right: left,// needs to be computed later.
		top: top,
		bottom: bottom
	};

	var blockSizeX = config.blockSizeX;// multiple of 2, for the rotation
	var blockSizeY = blockSizeX;// multiple of 2, for the rotation
	var scaleMin = 0.5;
	var scaleMax = 1.7;
	var rotationMaximum = 0.5;// 0 - 1=90 deg.
	var rotationSpeedX = 0.15;
	var rotationSpeedY = 0.09;

	var opacityMin = 0.3;
	var opacityMax = 0.65;

	//var evenFillColor = config.evenFillColor;
	//var oddFillColor = config.oddFillColor;

	var twinkleSpeed = 0.09;
	var twinkleThreshold = 0.93;
	// these two will adjust the twinkle effect. it affects opacity of the square, and the color. both of these are 0-1.
	var maxTwinkleOpacity = 0.5;
	var twinkleBrightness = 0.5;

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

	var time = frame.time;

	for(var y = top; y < bottom; y += blockSizeY)
	{
		var iy = (y - top) / blockSizeY;

		previousRowWidth = rowWidth;
		rowWidth = config.RowWidthFunction(y, top, bottom, canvasWidth);
		if(!previousRowWidth)
			previousRowWidth = rowWidth;

		var right = left + rowWidth;

		if(returnRect.right < right)
			returnRect.right = right;

		for(var x = left; x < rowWidth; x += blockSizeX)
		{
			var ix = (x - left) / blockSizeX;

			var fillColorTable = config.oddColorTable;
			if((ix & 1) == (iy & 1))// checkerboard
			{
				fillColorTable = config.evenColorTable;
			}

			if(!fillColorTable)
				continue;

			var xalphaVary = (opacityXEnv.height((x * dimensionMult) + time) + 1) / 2;
			var yalphaVary = (opacityYEnv.height((y * dimensionMult) + time) + 1) / 2;

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

			var blockScale = (scaleMin + ((scaleMax - scaleMin) * alpha * userAlpha));
			var thisBlockSizeX = blockSizeX * blockScale;
			//var thisBlockSizeY = blockSizeY * (scaleMin + ((scaleMax - scaleMin) * alpha * userAlpha));

			// this is actually incorrect; for a true grid use blockSizeX / Y, but this gives a cool effect that things are sorta wavy / bulgy
			var xtrans = x + (thisBlockSizeX / 2);
			var ytrans = y + (blockSizeY / 2);
			//ctx.translate(x + (blockSizeX / 2), y + (blockSizeY / 2));

			var twinkleFactor = CachedRandEnvelope(ix, iy, twinkleSpeed).factor(time);
			var fillStyle;
			var finalOpacity;
			if(twinkleFactor < twinkleThreshold)
			{
				finalOpacity = opacity * userAlpha;
				fillStyle = fillColorTable.c1;
			}
			else
			{
				// scale it to 0-1
				twinkleFactor = (twinkleFactor - twinkleThreshold) / (1 - twinkleThreshold);
				//twinkleFactor = twinkleFactor * twinkleFactor;

				var twinkleOpacity = twinkleFactor * maxTwinkleOpacity;

				finalOpacity = (1 - (opacity * userAlpha)) * twinkleOpacity;
				finalOpacity += (opacity * userAlpha);
				//fillStyle = MixColorsTwiceSpecial(fillColor, specialWhite, twinkleFactor * twinkleBrightness, config.backgroundColor, 1 - finalOpacity);
				fillStyle = fillColorTable.GetColor(twinkleFactor * twinkleBrightness);
			}

			var rotation = 6.283 * finalOpacity;// 2pi
			// we could maybe have some squares that rotate a different direction.
			//if(ix % 2 == 0)
			//	rotation = 6.283 - rotation;

			ctx.save();
			// things get really cool if you transpose rotate & translate here
			ctx.globalAlpha = finalOpacity;
			ctx.translate(xtrans, ytrans);
			ctx.rotate(rotation);
			ctx.beginPath();
			ctx.rect(-(thisBlockSizeX / 2), -(thisBlockSizeX / 2), thisBlockSizeX, thisBlockSizeX);
			ctx.fillStyle = fillStyle;
			ctx.fill();
			//ctx.drawImage(tbutton.img, x, y);

			ctx.restore();//*/
		}
	}

	ctx.restore();

	returnRect.width = returnRect.right - returnRect.left;
	returnRect.height = returnRect.bottom - returnRect.top;

	return returnRect;
}


var NavBackgroundLayer = function()
{
	this.evenColorTable = new TheModColorMixingTable(lightPurple, "#fff", 8);
	this.oddColorTable = new TheModColorMixingTable(medPurple, "#fff", 8);
};

NavBackgroundLayer.prototype.Render = function(frame, ctx, canvasWidth, canvasHeight)
{
	var footerStartsAtY = canvasHeight - 90;// virtual coords, not downsampled
	var navWidth = 184;// it's cool to make this NOT an even multiple of blockSizeX, so the blocks get a different size because of our "big" anti-aliasing
	var top = 180;

	return RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, {
		xflip: false,
		evenColorTable: this.evenColorTable,
		oddColorTable: this.oddColorTable,
		left: 0,
		top: top,
		height: (canvasHeight - top - 43),
		blockSizeX: 25,
		showTwinkle: true,

		RowWidthFunction: function(y, top, bottom){
			if(y >= footerStartsAtY)
				return canvasWidth;
			var yprog = (y - top) / (footerStartsAtY - top);
			yprog = Math.pow(yprog, 25);
			return (navWidth) + ((canvasWidth - navWidth) * yprog);
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

