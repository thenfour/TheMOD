

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

var ScrollerLayer = function()
{
	this.points = [];
};

ScrollerLayer.prototype.Render = function(frame, ctx, canvasWidth, canvasHeight)
{
	var strokeWidth = 2;
	//var strokeColor = darkGray;
	var strokeColor = null;
	var fillColor = darkPurple;
	var pointSpacing = 80;
	var pointCount = 3 + canvasWidth / pointSpacing;
	var scrollerAreaHeight = 40;
	var y = canvasHeight - scrollerAreaHeight;
	var pointYVariation = 8;
	var pointXVariation = 5;

	/*
		pixel manipulation way too slow.

		var c = document.createElement('canvas');
		c.width = canvasWidth / 8;
		c.height = scrollerAreaHeight;
		var ctx2 = c.getContext('2d');

		var imageData = ctx2.getImageData(0, 0, canvasWidth / 8, scrollerAreaHeight);
		var data = imageData.data;
		var len = data.length;

		for (var i = 0; i < len; ++ i)
		{
		 data[i] = { R:255, G:0, B:0, A:255 };
		}

		ctx2.putImageData(imageData, 0, y);
	*/

	for(var i = this.points.length - 1; i < pointCount; ++ i)
	{
		this.points.push(new ScrollerPoint(i*pointSpacing, pointXVariation, 0, pointYVariation, i + 13535));
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

	// text metrics: http://www.html5canvastutorials.com/tutorials/html5-canvas-text-metrics/

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

	ctx.restore();
}



