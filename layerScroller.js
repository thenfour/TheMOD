

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
	this.textSegments = [];
	this.scrollerVirtualX = 1.4 * (-$(window).width() / this.fontstretchX);// start the scroller past the 
	this.scrollerVirtualX = 0;
	this.leftTextSegmentIndex = 0;
};

ScrollerLayer.prototype.Render = function(frame, ctx, canvasWidth, canvasHeight)
{
	fontstretchX = 1.5;

	scrollerSpeedEnv = new RandEnvelope(30333);
	scrollerPathEnv = new RandEnvelope(30334);

	scrollerPaddingBottom = 48;

	yVarHeight = 7;
	yVarSpeed = 0.9;
	yVarTimeFactor = 1.1;
	charsPerSegment = 8;
	scrollText = "// greetz fly out 2 sdcompo: sonicade, organic_io, chotoro, chunter, nt, airmann, ambtax1, keith303, mickrip, mios, ruthlinde, and more funky tunes by norfair, carlos, j'écoute, coda, virt...  and of course the band: tenfour, angelo, damiano, iënad, wilfried.  #musicdsp peepz: timbre, mnl, Jazzdude, mrl_, Ad0, flapjackers, vocodork, trip-        #winprog peepz: forgey, magey, maharg, drano, spec, furan, GarMan, programmax, mblagden, Ad0 (again??)................ oldschool cheers for the means to great music: NoiseTracker, Impulse Tracker, FastTracker.  and newschool cheers to the ultimate tracker ever: Renoise. Renoise.           RENOISE!                                                                                                                                                                ";

	speed = scrollerSpeedEnv.vary(frame, 1, 60, 0);// pixels per second

	ctx.save();
	ctx.scale(fontstretchX, 1);
	canvasWidth /= fontstretchX;

  ctx.font = "12px '8bitoperator'";
  ctx.textBaseline="bottom"; 
  ctx.shadowOffsetX = 2;
	ctx.shadowOffsetY = 2;
	ctx.shadowColor = '#000';
  ctx.fillStyle = '#777';//lightPurple;

	var totalScrollWidth = null;// = this.__ensureTextSegmentsInitialized(ctx, frame);

	var newTextSegments = [];
	var newTotalScrollWidth = 0;
	for(var i = 0; i < scrollText.length; i += charsPerSegment)
	{
		var text = scrollText.substr(i, charsPerSegment);
		var width = Math.round(ctx.measureText(text).width);// this call causes the page to seem like it's constantly loading. I don't know what's going on.
		// so we don't have to recalculate this every single frame, test the first one. if it's the same as what we already have, just assume all the rest are too.
		if((i == 0) && (this.textSegments.length > 0) && (this.textSegments[0].width == width))
		{
			totalScrollWidth = this.totalScrollWidth;// it's the same!
			break;
		}
		newTextSegments.push({
			text: text,
			width: width,
			virtualLeft: newTotalScrollWidth,
			virtualRight: newTotalScrollWidth + width
		});
		newTotalScrollWidth += width;
	}
	if(!totalScrollWidth)// if "we had to calculate stuff instead of grabbing it from cache"
	{
		totalScrollWidth = this.totalScrollWidth = newTotalScrollWidth;
		this.textSegments = newTextSegments;
	}

	if(this.textSegments.length > 0)
	{
		this.scrollerVirtualX += (frame.timeDiff / 1000 * speed) % totalScrollWidth;

		// find the first item to draw, by traversing segments until we find one that will be rendered.

		var segmentIndex = this.leftTextSegmentIndex;
		for(; segmentIndex < this.textSegments.length; ++ segmentIndex)
		{
			if(this.textSegments[segmentIndex].virtualRight > this.scrollerVirtualX)
				break;
		}

		firstSegmentIndex = segmentIndex % this.textSegments.length;
		this.leftTextSegmentIndex = firstSegmentIndex;
		var xoffset = this.scrollerVirtualX - this.textSegments[firstSegmentIndex].virtualLeft;

		segmentIndex = firstSegmentIndex;
		for(var x = -xoffset; x < canvasWidth;)
		{
			var segmentInfo = this.textSegments[segmentIndex];
			yVariation = scrollerPathEnv.vary({
				time: (this.scrollerVirtualX + x) + (frame.time * yVarTimeFactor)
			}, yVarSpeed, 0, yVarHeight);

			ctx.fillText(segmentInfo.text, x, yVariation + canvasHeight - scrollerPaddingBottom);

			x += segmentInfo.width;
			segmentIndex = (segmentIndex + 1) % this.textSegments.length;
		}
	}
	ctx.restore();
}



