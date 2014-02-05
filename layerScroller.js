

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
	this.points = [];
	this.textSegments = null;
	this.scrollerVirtualX = -200;

	this.scrollerSpeedEnv = new RandEnvelope(30333);
	this.scrollerPathEnv = new RandEnvelope(30334);

	this.scrollText = "greetz to the sdcompo team:  " +
		"sonicade, organic_io, chotoro, chunter, nt, airmann, ambtax1, keith303, mickrip, mios, ruthlinde, " +
		"and more funky tunes by norfair, carlos, j'ecoute, coda, virt..." + 
		"and the band: angelo, damiano, ienad, wilfried.        ";
};

ScrollerLayer.prototype.__ensureTextSegmentsInitialized = function(ctx, charsPerSegment)
{
	var newTextSegments = [];
	var newTotalScrollWidth = 0;
	for(var i = 0; i < this.scrollText.length; i += charsPerSegment)
	{
		var text = this.scrollText.substr(i, charsPerSegment);
		var width = Math.round(ctx.measureText(text).width);
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
	var strokeWidth = 2;
	var strokeColor = null;
	var fillColor = darkPurple;
	var pointSpacing = 80;
	var pointCount = 3 + canvasWidth / pointSpacing;
	var scrollerAreaHeight = 63;
	var y = canvasHeight - scrollerAreaHeight;
	var pointYVariation = 8;
	var pointXVariation = 5;
	var speed = this.scrollerSpeedEnv.vary(frame, 1, 30, 0);// pixels per second
	var scrollerPaddingBottom = 2;
	var fontstretchX = 1.5;
	var yVarHeight = 8;
	var yVarSpeed = 0.7;
	var yVarTimeFactor = 2;
	var charsPerSegment = 5;

	for(var i = this.points.length - 1; i < pointCount; ++ i)
	{
		this.points.push(new ScrollerPoint(i*pointSpacing, pointXVariation, 0, pointYVariation, i + 143535));
	}

	ctx.save();
	ctx.beginPath();

	// let it be filled by sweeping out the bottom rect
	ctx.moveTo(canvasWidth + strokeWidth, y);
	ctx.lineTo(canvasWidth + strokeWidth, canvasHeight + strokeWidth);
	ctx.lineTo(-strokeWidth, canvasHeight + strokeWidth);
	ctx.lineTo(-strokeWidth, y);

	for(var i = 0; i < pointCount - 1; ++ i)
	{
		p1x = this.points[i].x(frame);
		p1y = y + this.points[i].y(frame);
		p2x = this.points[i+1].x(frame);
		p2y = y + this.points[i+1].y(frame);
		var xc = (p1x + p2x) / 2;
		var yc = (p1y + p2y) / 2;
		ctx.quadraticCurveTo(p1x, p1y, xc, yc);
	}

	ctx.closePath();

	if(strokeColor)
	{
		ctx.strokeStyle = strokeColor;
		ctx.lineWidth = strokeWidth;
		ctx.stroke();
	}

	if(fillColor)
	{
		ctx.fillStyle = fillColor;
		ctx.fill();
	}

	// draw some scrolled text ------------------------------------------
	ctx.save();
	ctx.scale(fontstretchX, 1);
	canvasWidth /= fontstretchX;

  ctx.font = "18px aansa";
  ctx.textBaseline="bottom"; 

	var totalScrollWidth = this.__ensureTextSegmentsInitialized(ctx, charsPerSegment);

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

	segmentIndex = firstSegmentIndex;
	for(var x = -xoffset; x < canvasWidth;)
	{
		var segmentInfo = this.textSegments[segmentIndex];
		yVariation = this.scrollerPathEnv.vary({
			time: (this.scrollerVirtualX + x) + (frame.time * yVarTimeFactor)
		}, yVarSpeed, 0, yVarHeight);

		ctx.strokeStyle = '#000';
		ctx.lineWidth = 2;
		ctx.strokeText(segmentInfo.text, x, yVariation + canvasHeight - scrollerPaddingBottom);

		x += segmentInfo.width;
		segmentIndex = (segmentIndex + 1) % this.textSegments.length;
	}

	segmentIndex = firstSegmentIndex;
	for(var x = -xoffset; x < canvasWidth;)
	{
		var segmentInfo = this.textSegments[segmentIndex];
		yVariation = this.scrollerPathEnv.vary({
			time: (this.scrollerVirtualX + x) + (frame.time * yVarTimeFactor)
		}, yVarSpeed, 0, yVarHeight);

	  ctx.fillStyle = lightPurple;
		ctx.fillText(segmentInfo.text, x, yVariation + canvasHeight - scrollerPaddingBottom);

		x += segmentInfo.width;
		segmentIndex = (segmentIndex + 1) % this.textSegments.length;
	}

	ctx.restore();
	//  ------------------------------------------ ------------------------------------------

	ctx.restore();
}



