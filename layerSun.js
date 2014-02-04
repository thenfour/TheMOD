

var LayerSun = function()
{
	this.pointCount = 7;
	
	this.bigPointRadius = 140;
	this.littlePointRadius = 105;
	this.innerPointRadius = 60;

	this.circleRadius = 55;
	this.circleStrokeWidth = 19;

	this.rotationEnv = new RandEnvelope(1246);
	this.bigRadiusEnv = new RandEnvelope(2622);
	this.littleRadiusEnv = new RandEnvelope(898);
};


LayerSun.prototype.render = function(stage, frame, layer)
{
	var x = stage.width() * 0.8;
	var y = 300;
	var rotation = 360 * this.rotationEnv.height(frame.time, 0.011);
	layer.add(new Kinetic.Star({
		x:x,
		y:y,
		numPoints: this.pointCount,
		innerRadius: this.innerPointRadius,
		outerRadius: this.bigPointRadius,
		rotation: rotation,
//		fillRadialGradientStartRadius:0,
	//	fillRadialGradientEndRadius:this.bigPointRadius,
	//	fillRadialGradientColorStops:[0,'#fed58c',1,'#e19c26'],
		fill:'#e19c26'//,
		//strokeWidth:2,
		//stroke:'#fed58c'
	}));

	layer.add(new Kinetic.Star({
		x:x,
		y:y,
		rotation: rotation + (360 / this.pointCount / 2),
		numPoints: this.pointCount,
		innerRadius: this.innerPointRadius,
		outerRadius: this.littlePointRadius,
		fill:'#fed58c',
		//fillRadialGradientStartRadius:0,
		//fillRadialGradientEndRadius:this.littlePointRadius,
		//fillRadialGradientColorStops:[0,'#fed58c',1,'#e19c26']//,
	}));

	layer.add(new Kinetic.Circle({
		x:x,
		y:y,
		radius: this.circleRadius,
		fillRadialGradientStartRadius:0,
		fillRadialGradientEndRadius:this.littlePointRadius,
		fillRadialGradientColorStops:[0,'#fed58c',1,'#e19c26'],//,
		strokeWidth:this.circleStrokeWidth,
		stroke:'#fed58c'
	}));
};
