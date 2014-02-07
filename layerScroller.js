

//////////////////////////////////////////////////////////////////////////
var ScrollerPoint = function(_x, _xLeeway, _y, _yLeeway, _parentSeed)
{
	this._x = _x;
	this._y = _y;

	this._xLeeway = _xLeeway;
	this._yLeeway = _yLeeway;

	this.xEnv = new RandEnvelope(_parentSeed + 2);
	this.yEnv = new RandEnvelope(_parentSeed + 3);
};

ScrollerPoint.prototype.x = function(frame)
{
	return this.xEnv.vary(frame, 0.1, this._x, this._xLeeway);
};

ScrollerPoint.prototype.y = function(frame)
{
	return this.yEnv.vary(frame, 0.2, this._y, this._yLeeway);
};

//////////////////////////////////////////////////////////////////////////
var ScrollerLayer = function()
{
	this.fontstretchX = 1.5;


	this.points = [];
	this.textSegments = [];
	this.scrollerVirtualX = -$(window).width() / 1.5;

	this.scrollerSpeedEnv = new RandEnvelope(30333);
	this.scrollerPathEnv = new RandEnvelope(30334);

	this.scrollText = "// greetz fly out 2 sdcompo:  " +
		"sonicade, organic_io, chotoro, chunter, nt, airmann, ambtax1, keith303, mickrip, mios, ruthlinde, " +
		"and more funky tunes by norfair, carlos, j'écoute, coda, virt...  " + 
		"and of course the band: angelo, damiano, iënad, wilfried. " +
		"#musicdsp peepz: timbre, mnl, Jazzdude, mrl_, Ad0, flapjackers, vocodork, trip-         " +
		"#winprog peepz: forgey, magey, maharg, drano, spec, furan, GarMan, programmax, mblagden, Ad0 (again??)." +
		"................ oldschool cheers for the means to great music: NoiseTracker, Impulse Tracker, FastTracker2, "
		+ "and newschool cheers to the ultimate tracker ever: Renoise. Renoise.           RENOISE!!!!"
		+ "                                                                                 "
		+ "                                                                                 "
		;
};

ScrollerLayer.prototype.__ensureTextSegmentsInitialized = function(ctx, frame, charsPerSegment)
{
	if(frame.frameNumber < 10)// for some reason, calling measureText too early in the page's rendering will cause oddball behavior in chorme explained below.
		return 0;
	var newTextSegments = [];
	var newTotalScrollWidth = 0;
	for(var i = 0; i < this.scrollText.length; i += charsPerSegment)
	{
		var text = this.scrollText.substr(i, charsPerSegment);
		var width = Math.round(ctx.measureText(text).width);// this call causes the page to seem like it's constantly loading. I don't know what's going on.
		newTextSegments.push({
			text: text,
			width: width,
			virtualLeft: newTotalScrollWidth,
			virtualRight: newTotalScrollWidth + width
		});

		// so we don't have to recalculate this every single frame, test the first one. if it's the same as what we already have, just assume all the rest are too.
		if(i == 0 && this.textSegments && this.textSegments.length > 0)
		{
			if(this.textSegments[0].width == newTextSegments[0].width)
			{
				return this.totalScrollWidth;// it's the same!
			}
		}

		newTotalScrollWidth += width;
	}

	this.totalScrollWidth = newTotalScrollWidth;
	this.textSegments = newTextSegments;
	return this.totalScrollWidth;
}
 

ScrollerLayer.prototype.Render = function(frame, ctx, canvasWidth, canvasHeight)
{
	//var scrollerAreaHeight = 82;
	//var filledAreaPaddingBottom = 43;
	var scrollerPaddingBottom = 48;

	//var strokeWidth = 8;
	//var strokeColor = null;
	//var fillColor = null;//darkPurple;
	//var pointSpacing = 30;
	//var pointCount = 3 + canvasWidth / pointSpacing;
	//var pointYVariation = 6;
	//var pointXVariation = 5;
	var speed = this.scrollerSpeedEnv.vary(frame, 1, 60, 0);// pixels per second

	var yVarHeight = 5;
	var yVarSpeed = 0.7;
	var yVarTimeFactor = 1.1;
	var charsPerSegment = 5;

	//var y = canvasHeight - scrollerAreaHeight;
/*
	for(var i = this.points.length - 1; i < pointCount; ++ i)
	{
		this.points.push(new ScrollerPoint(i*pointSpacing, pointXVariation, 0, pointYVariation, i + 143535));
	}
*/
	/*if(fillColor)
	{
		ctx.fillStyle = fillColor;
		var fillTop = canvasHeight - scrollerAreaHeight;
		var fillBottom = canvasHeight - filledAreaPaddingBottom;
		ctx.fillRect(0, canvasHeight - scrollerAreaHeight, canvasWidth, fillBottom - fillTop);
	}*/


	// draw some scrolled text ------------------------------------------
	ctx.save();
	ctx.globalAlpha = 1.0;
	ctx.scale(this.fontstretchX, 1);
	canvasWidth /= this.fontstretchX;

  ctx.font = "12px '8bitoperator'";
  ctx.textBaseline="bottom"; 
  ctx.shadowOffsetX = 2;
	ctx.shadowOffsetY = 2;
	ctx.shadowColor = '#000';
	
	var totalScrollWidth = this.__ensureTextSegmentsInitialized(ctx, frame, charsPerSegment);
	if(this.textSegments.length > 0)
	{
		this.scrollerVirtualX += (frame.timeDiff / 1000 * speed) % totalScrollWidth;

		// find the first item to draw, by traversing segments until we find one that will be rendered.

		var segmentIndex = 0;
		for(; segmentIndex < this.textSegments.length; ++ segmentIndex)
		{
			if(this.textSegments[segmentIndex].virtualRight > this.scrollerVirtualX)
				break;
		}

		firstSegmentIndex = segmentIndex % this.textSegments.length;
		var xoffset = this.scrollerVirtualX - this.textSegments[firstSegmentIndex].virtualLeft;
		var segmentIndex;

/*
		segmentIndex = firstSegmentIndex;
		for(var x = -xoffset; x < canvasWidth;)
		{
			var segmentInfo = this.textSegments[segmentIndex];
			yVariation = this.scrollerPathEnv.vary({
				time: (this.scrollerVirtualX + x) + (frame.time * yVarTimeFactor)
			}, yVarSpeed, 0, yVarHeight);

			ctx.strokeStyle = '#000';
			ctx.lineWidth = 4;
			ctx.strokeText(segmentInfo.text, x, yVariation + canvasHeight - scrollerPaddingBottom);

			x += segmentInfo.width;
			segmentIndex = (segmentIndex + 1) % this.textSegments.length;
		}
*/

		segmentIndex = firstSegmentIndex;
		for(var x = -xoffset; x < canvasWidth;)
		{
			var segmentInfo = this.textSegments[segmentIndex];
			yVariation = this.scrollerPathEnv.vary({
				time: (this.scrollerVirtualX + x) + (frame.time * yVarTimeFactor)
			}, yVarSpeed, 0, yVarHeight);

		  ctx.fillStyle = '#666';//lightPurple;
			ctx.fillText(segmentInfo.text, x, yVariation + canvasHeight - scrollerPaddingBottom);

			x += segmentInfo.width;
			segmentIndex = (segmentIndex + 1) % this.textSegments.length;
		}
	}
	ctx.restore();
	//  ------------------------------------------ ------------------------------------------

}



