

var CurtainCircle = function(_x, _y, _radius, _xLeeway, _yLeeway, _radiusLeeway, _parentSeed)
{
	this._x = _x;
	this._y = _y;
	this._radius = _radius;
	this._xLeeway = _xLeeway;
	this._yLeeway = _yLeeway;
	this._radiusLeeway = _radiusLeeway;

	this.radiusEnv = new RandEnvelope(_parentSeed + 1);
	this.xEnv = new RandEnvelope(_parentSeed + 2);
	this.yEnv = new RandEnvelope(_parentSeed + 3);
};
CurtainCircle.prototype.x = function(frame)
{
	return this.xEnv.vary(frame, 0.04, this._x, this._xLeeway);
};
CurtainCircle.prototype.y = function(frame)
{
	return this.yEnv.vary(frame, 0.05, this._y, this._yLeeway);
};
CurtainCircle.prototype.radius = function(frame)
{
	return this.radiusEnv.vary(frame, 0.03, this._radius, this._radiusLeeway);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var TopBackCurtainLayer = function()
{
	this.radius = 100;
	this.spread = 160;
	this.radiusVariance = 6;
	this.yVariance = 20;
	this.xVariance = 6;
	this.y = 120;
	this.circles = [];
	this.strokeWidth1 = 9;
	this.strokeWidth2 = 9;
	this.strokeWidth3 = 3;

	this.cloudColor = lightPurple;
	this.highlightColor = black;

	this.altCloudColor = lightYellow;
	this.altHighlightColor = lightYellow;
};

TopBackCurtainLayer.prototype.__render = function(frame, ctx,
	strokeWidth, strokeColor, fillColor, radiusAdjust, circleCount, offsetY, canvasWidth, canvasHeight, flipped)
{
	ctx.save();
	if(flipped)
	{
	  ctx.translate(canvasWidth / 2, 0);
	  ctx.scale(-1, 1);
	  ctx.translate(-(canvasWidth / 2), 0);
	}
  ctx.translate(0, offsetY);

	var circles = this.circles;

	ctx.beginPath();

	// move to the first location - let's just pick the left side of the first circle.
	ctx.moveTo(circles[0].x(frame) - (circles[0].radius(frame) - radiusAdjust), -strokeWidth);
	ctx.lineTo(
		circles[0].x(frame) - (circles[0].radius(frame) - radiusAdjust),
		circles[0].y(frame)
		);

	var circle0;
	var circle1;
	var circle2;
	var lastX = 0;
	for(var i = 1; i < (circleCount - 1); ++ i)
	{
		circle0 = circles[i-1];
		circle1 = circles[i];
		circle2 = circles[i + 1];

		p1 = CircleCircleIntersectionLower(
			{x:circle0.x(frame), y:circle0.y(frame)}, circle0.radius(frame) + radiusAdjust,
			{x:circle1.x(frame), y:circle1.y(frame)}, circle1.radius(frame) + radiusAdjust
			);

		p2 = CircleCircleIntersectionLower(
			{x:circle1.x(frame), y:circle1.y(frame)}, circle1.radius(frame) + radiusAdjust,
			{x:circle2.x(frame), y:circle2.y(frame)}, circle2.radius(frame) + radiusAdjust
			);

		// center, start angle, end angle
		var o = { x: circle1.x(frame), y:circle1.y(frame) };

		ctx.arc(circle1.x(frame), circle1.y(frame), circle1.radius(frame) + radiusAdjust,
			angleOnCircle(o, p1),
			angleOnCircle(o, p2),
			true
			);
		
		lastX = p2.x;
	}

	ctx.lineTo(lastX, -strokeWidth);
	ctx.closePath();

	ctx.fillStyle = fillColor;
	ctx.fill();

	ctx.strokeStyle = strokeColor;
	ctx.lineWidth = strokeWidth;
	ctx.stroke();

	ctx.restore();
}


TopBackCurtainLayer.prototype.Render = function(frame, ctx, width, height, alt)
{
	var params = !alt ?
	{
		flipped: false,
		offsetY: 0,
		stroke1Width: 14,
		stroke1Color: lightPurple,
		stroke2Width: 10,
		stroke2Color: darkPurple,
		stroke3Width: 4,
		stroke3Color: '#000',
		stroke4Color: lightPurple
	}
	: 
	{
		flipped: true,
		offsetY: -60,
		stroke1Width: 8,
		stroke1Color: darkPurple,
		stroke2Width: 4,
		stroke2Color: '#000',
		stroke3Width: 2,
		stroke3Color: lightYellow,
		stroke4Color: lightPurple
	};

	// take worst case scenario
	// and add some for some dummies on the edges of the array, and to ensure we have a few running always for bounds
	var circleCount = 3 + Math.ceil(Math.abs(width / (this.spread - this.radiusVariance)));
	// make sure we have enough circles in our array.
	for(var i = this.circles.length - 1; i < circleCount; ++ i)
	{
		this.circles.push(new CurtainCircle(i * this.spread, this.y, this.radius, this.xVariance, this.yVariance, this.radiusVariance, i));
	}

	this.__render(frame, ctx,
		params.stroke1Width,
		params.stroke1Color,
		params.stroke2Color,
		0, circleCount, params.offsetY, width, height, params.flipped);

	this.__render(frame, ctx,
		params.stroke3Width,
		params.stroke3Color,
		params.stroke4Color,
		-(params.stroke3Width + params.stroke2Width), circleCount, params.offsetY, width, height, params.flipped);

};

