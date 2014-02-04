

var SunLayer = function()
{
	this.pointCount = 14;	
	this.bigPointRadius = 150;
	this.bigPointRadiusVariation = 40;

	this.littlePointRadius = 125;
	this.littlePointRadiusVariation = 20;

	this.innerPointRadius = 70;

	this.circleRadius = 55;
	this.circleStrokeWidth = 19;

	this.rotationEnv = new RandEnvelope(1246);
	this.bigRadiusEnv = new RandEnvelope(2622);
	this.littleRadiusEnv = new RandEnvelope(898);

	this.wiggleRand = new MersenneTwister(246246);

	this.OpeningTween = new Tween(2.8, null, Easing.Bounce.Out);
};


SunLayer.prototype.Render = function(frame, ctx, width, height)
{
	var x = width * 0.8;
	var y = 270 + this.OpeningTween.tween(frame, -300, 0);
	var mainRotation = (2*Math.PI) * this.rotationEnv.height(frame, 0.011);

	var pointCount = this.pointCount;
	var innerR = this.innerPointRadius;
	var smallR = this.littleRadiusEnv.vary(frame, 0.1, this.littlePointRadius, this.littlePointRadiusVariation);
	var bigR = this.bigRadiusEnv.vary(frame, 0.1, this.bigPointRadius, this.bigPointRadiusVariation);

	// make a star with alternating points.
	ctx.save();
	ctx.beginPath();
	ctx.translate(x,y);
	ctx.rotate(mainRotation);

	// start at the inner radius
	ctx.moveTo(0, -innerR);

	// for each iteration we draw 2 star points, which consist of 2 draw points each. so we have to draw 4 points each iteration, each at different angle along the circle.
	var rotateAmtPerPoint = (2*Math.PI) / (pointCount * 2);
	for(i = 0; i < pointCount / 2; ++ i)
	{
		ctx.rotate(rotateAmtPerPoint);
		ctx.lineTo(0, -bigR);
		ctx.rotate(rotateAmtPerPoint);
		ctx.lineTo(0, -innerR);
		ctx.rotate(rotateAmtPerPoint);
		ctx.lineTo(0, -smallR);
		ctx.rotate(rotateAmtPerPoint);
		ctx.lineTo(0, -innerR);
	}
	ctx.closePath();

	ctx.lineWidth = 2;
	ctx.strokeStyle='#fff';
	//ctx.stroke();

  // create radial gradient
  var grd = ctx.createRadialGradient(0, 0, 0, 0, 0, bigR);
  grd.addColorStop(0, '#ffc');
  grd.addColorStop(0.25, '#fed58c');
  grd.addColorStop(1, '#e19c26');

  ctx.fillStyle = grd;
  ctx.fill();

  // start over and create a cool circle in the middle.
  ctx.beginPath();
	ctx.arc(0,0,this.circleRadius, 0, 2*Math.PI);

	//ctx.fillStyle = grd;
  //ctx.fill();

  ctx.lineWidth = this.circleStrokeWidth;
  ctx.strokeStyle = '#fed58c';
  ctx.stroke();


	ctx.restore();

/*
	layer.add(new Kinetic.Circle({
		x:x,
		y:y,
		radius: this.circleRadius,
		fillRadialGradientStartRadius:0,
		fillRadialGradientEndRadius:this.littlePointRadius,
		fillRadialGradientColorStops:[0,'#fed58c',1,'#e19c26'],
		strokeWidth:this.circleStrokeWidth,
		stroke:'#fed58c'
	}));*/

};


