

var SunLayer = function()
{
	this.pointCount = 14;	
	this.bigPointRadius = 150;
	this.bigPointRadiusVariation = 45;

	this.littlePointRadius = 120;
	this.littlePointRadiusVariation = 15;

	this.innerPointRadius = 65;

	this.circleRadius = 45;
	this.circleStrokeWidth = 19;

	this.backCircleRadius = 95;
	this.baseY = 200;//320;

	this.rotationEnv = new RandEnvelope(1247);
	this.bigRadiusEnv = new RandEnvelope(2624);
	this.littleRadiusEnv = new RandEnvelope(899);

	this.OpeningTween = new Tween(4.8, null, Easing.Bounce.Out);
};


SunLayer.prototype.Render = function(frame, ctx, width, height)
{
	var x = width * 0.8;
	var y = this.baseY + this.OpeningTween.tween(frame, -300, 0);
	var mainRotation = (2*Math.PI) * this.rotationEnv.height(frame, 0.011);

	var pointCount = this.pointCount;
	var innerR = this.innerPointRadius;
	var smallR = this.littleRadiusEnv.vary(frame, 0.1, this.littlePointRadius, this.littlePointRadiusVariation);
	var bigR = this.bigRadiusEnv.vary(frame, 0.1, this.bigPointRadius, this.bigPointRadiusVariation);

	// make a star with alternating points.
	ctx.save();
	ctx.translate(x,y);
	ctx.rotate(mainRotation);

  ctx.shadowOffsetX = 4;
	ctx.shadowOffsetY = 5;
	ctx.shadowColor = 'rgba(0,0,0,0.2)';


  // draw back circle
  ctx.beginPath();
	ctx.arc(0,0,this.backCircleRadius, 0, 2*Math.PI);
  ctx.fillStyle = darkYellow;
  ctx.fill();

	// start at the inner radius
	ctx.beginPath();
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

	//ctx.lineWidth = 2;
	//ctx.strokeStyle='#fff';
	//ctx.stroke();

  // create radial gradient
  var grd = ctx.createRadialGradient(0, 0, 0, 0, 0, bigR);
  grd.addColorStop(0, '#ffc');
  grd.addColorStop(0.15, '#fed58c');
  grd.addColorStop(1, '#e19c26');

  ctx.fillStyle = grd;
  ctx.fill();

  // start over and create a cool circle in the middle.

  ctx.shadowOffsetX = 0;
	ctx.shadowOffsetY = 0;

  ctx.beginPath();
	ctx.arc(0,0,this.circleRadius, 0, 2*Math.PI);

  ctx.lineWidth = this.circleStrokeWidth;
  ctx.strokeStyle = '#ffe08c';
  ctx.stroke();

  // draw fore dark circle
  /*ctx.beginPath();
	ctx.arc(0,0,this.foreDarkCircleRadius, 0, 2*Math.PI);
  ctx.strokeStyle = darkYellow;
  ctx.lineWidth = this.foreDarkCircleStrokeWidth;
  ctx.stroke();*/

	ctx.restore();

};


