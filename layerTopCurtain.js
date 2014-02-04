

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
CurtainCircle.prototype.x = function(timeMS)
{
	return this.xEnv.vary(timeMS, 0.04, this._x, this._xLeeway);
};
CurtainCircle.prototype.y = function(timeMS)
{
	return this.yEnv.vary(timeMS, 0.05, this._y, this._yLeeway);
};
CurtainCircle.prototype.radius = function(timeMS)
{
	return this.radiusEnv.vary(timeMS, 0.03, this._radius, this._radiusLeeway);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var TopBackCurtainLayer = function()
{
	this.radius = 100;
	this.spread = 140;
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
};

TopBackCurtainLayer.prototype.__render = function(frame, ctx, strokeWidth, fillColor, strokeColor, radiusAdjust, circleCount)
{
	var t = frame.time;
	var circles = this.circles;

	ctx.beginPath();

	// move to the first location - let's just pick the left side of the first circle.
	ctx.moveTo(circles[0].x(frame.time) - (circles[0].radius(frame.time) - radiusAdjust), -strokeWidth);
	ctx.lineTo(
				circles[0].x(frame.time) - (circles[0].radius(frame.time) - radiusAdjust),
				circles[0].y(frame.time)
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
					{x:circle0.x(t), y:circle0.y(t)}, circle0.radius(t) + radiusAdjust,
					{x:circle1.x(t), y:circle1.y(t)}, circle1.radius(t) + radiusAdjust
					);

				p2 = CircleCircleIntersectionLower(
					{x:circle1.x(t), y:circle1.y(t)}, circle1.radius(t) + radiusAdjust,
					{x:circle2.x(t), y:circle2.y(t)}, circle2.radius(t) + radiusAdjust
					);

				// center, start angle, end angle
				var o = { x: circle1.x(t), y:circle1.y(t) };

				ctx.arc(circle1.x(t), circle1.y(t), circle1.radius(t) + radiusAdjust,
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
}


TopBackCurtainLayer.prototype.Render = function(frame, ctx, width, height)
{
	// take worst case scenario
	// and add some for some dummies on the edges of the array, and to ensure we have a few running always for bounds
	var circleCount = 3 + Math.ceil(Math.abs(width / (this.spread - this.radiusVariance)));
	// make sure we have enough circles in our array.
	for(var i = this.circles.length - 1; i < circleCount; ++ i)
	{
		this.circles.push(new CurtainCircle(i * this.spread, this.y, this.radius, this.xVariance, this.yVariance, this.radiusVariance, i));
	}

	this.__render(frame, ctx, this.strokeWidth1, null, this.cloudColor, 0, circleCount);
	this.__render(frame, ctx, this.strokeWidth3, this.cloudColor, this.highlightColor, -(this.strokeWidth3 + this.strokeWidth2), circleCount);
};

