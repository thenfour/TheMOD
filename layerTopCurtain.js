

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
	this.spread = 140;
	this.radiusVariance = 6;
	this.yVariance = 20;
	this.xVariance = 6;
	this.y = 120;
	this.circles = [];

	this.entranceTween1 = new Tween(3, null, Easing.Elastic.Out);
	this.entranceTween2 = new Tween(3.4, null, Easing.Elastic.Out);
	//this.entranceTween3 = new Tween(3.8, null, Easing.Elastic.Out);
};

TopBackCurtainLayer.prototype.__render = function(frame, ctx,
	strokeWidth, strokeColor, fillColor, radiusAdjust, circleCount, offsetX, offsetY, canvasWidth, canvasHeight, flipped)
{
	var ysafety = 25;

	ctx.save();
	if(flipped)
	{
	  ctx.translate(canvasWidth / 2, 0);
	  ctx.scale(-1, 1);
	  ctx.translate(-(canvasWidth / 2), 0);

		// in order to make the curtains line up properly when X-flipped i need to consider the width of the canvas.
		offsetX += (canvasWidth % this.spread);
		// and offset it so they are staggered instead of lining up
		offsetX -= (this.radius / 2);
	}
  ctx.translate(offsetX, offsetY);

	var circles = this.circles;

	ctx.beginPath();

	// move to the first location - let's just pick the left side of the first circle.
	ctx.moveTo(circles[0].x(frame) - (circles[0].radius(frame) - radiusAdjust), -strokeWidth - ysafety);
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

	ctx.lineTo(lastX, -strokeWidth - ysafety);
	ctx.closePath();

	if(fillColor)
	{
		ctx.fillStyle = fillColor;
		ctx.fill();
	}

	if(strokeColor)
	{
		ctx.strokeStyle = strokeColor;
		ctx.lineWidth = strokeWidth;
		ctx.stroke();
	}

	ctx.restore();
}


TopBackCurtainLayer.prototype.Render = function(frame, ctx, width, height, variation)
{
	var params;

	switch(variation)
	{
		case 0:
			var params = {
				flipped: false,
				offsetX: 0,
				offsetY: 0 + (this.entranceTween1.tween(frame, -250, 0)),
				stroke1Width: 12,
				stroke1Color: darkGray,
				stroke2Width: 10,
				stroke2Color: darkPurple,
				stroke3Width: 4,
				stroke3Color: '#000',
				stroke4Color: darkGray
			};
			break;
		case 1:
			var params = {
				flipped: true,
				offsetX: 0/*-(this.radius*.4)*/,
				offsetY: -40 + (this.entranceTween2.tween(frame, -250, 0)),
				stroke1Width: 14,
				stroke1Color: darkPurple,
				stroke2Width: 10,
				stroke2Color: lightPurple,
				stroke3Width: 8,
				stroke3Color: darkPurple,
				stroke4Color: lightPurple
			};
			break;
	}

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
		0,
		circleCount, params.offsetX, params.offsetY, width, height, params.flipped);

	this.__render(frame, ctx,
		params.stroke3Width,
		params.stroke3Color,
		params.stroke4Color,
		-(params.stroke3Width + params.stroke2Width),
		circleCount, params.offsetX, params.offsetY, width, height, params.flipped);

};

