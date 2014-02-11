
var TheModRenderer = function()
{
	this.backgroundLayer = new BackgroundLayer();
	this.logoLayer = new LogoLayer();
	this.topBackCurtain = new TopBackCurtainLayer();
	this.sunLayer = new SunLayer();
	this.scroller = new ScrollerLayer();
	this.navBackground = new NavBackgroundLayer();
	this.topRightSquares = new TopRightSquaresLayer();

	//this.downsampleFactor = 3.0;

	this.fadeInTween = new Tween(1.6, null, Easing.Quadratic.InOut);
}

TheModRenderer.prototype.GetFrameInfo = function(frame, ctx)
{
	return {
		mainOpacity: this.fadeInTween.tween(frame, 0, 1)
	};
}

TheModRenderer.prototype.GetGlobalInfo = function()
{
	return {
		targetFrameRate: 24,
		pixelSizeX: 1,
		pixelSizeY: 1
	};
}
/*
TheModRenderer.prototype.EnsureDownsampledCanvas = function(frame, ctx, width, height)
{
	if(!this.downsampledCanvasA)
	{
		this.downsampledCanvasA = document.createElement('canvas');
	}
	var desiredWidth = width / this.downsampleFactor;
	var desiredHeight = height / this.downsampleFactor;

	if(this.downsampledCanvasA.width != desiredWidth)
		this.downsampledCanvasA.width = desiredWidth;
	if(this.downsampledCanvasA.height != desiredHeight)
		this.downsampledCanvasA.height = desiredHeight;
	return { width: desiredWidth, height: desiredHeight };
}
*/
TheModRenderer.prototype.RenderPixelated = function(frame, ctx, width, height)
{
	//var downsampled = true;

	this.backgroundLayer.Render(frame, ctx, width, height);

	//if(!downsampled)
		this.navBackground.Render(frame, ctx, width, height, 1);
	/*else
	{
		var d = this.EnsureDownsampledCanvas(frame, ctx, width, height);
		var ctxds = this.downsampledCanvasA.getContext('2d');
		ctxds.scale(1/this.downsampleFactor, 1/this.downsampleFactor);

		ctxds.clearRect(0, 0, width, height);
		//ctxds.fillStyle="#00f";
		//ctxds.fillRect(0,0,width, height);

		this.navBackground.Render(frame, ctxds, width, height, this.downsampleFactor);
		ctx.drawImage(this.downsampledCanvasA, 0, 0, d.width, d.height, 0, 0, width, height);
		//ctx.drawImage(this.downsampledCanvasA, 0, 0);
	}*/

  this.topBackCurtain.Render(frame, ctx, width, height, 0);
	this.sunLayer.Render(frame, ctx, width, height);
  this.topBackCurtain.Render(frame, ctx, width, height, 1);

	//if(!downsampled)
		this.topRightSquares.Render(frame, ctx, width, height, 1);
	/*else
	{
		ctxds.clearRect(0, 0, width, height);
		//ctxds.fillStyle="#00f";
		//ctxds.fillRect(0,0,width, height);

		this.topRightSquares.Render(frame, ctxds, width, height, this.downsampleFactor);
		ctx.drawImage(this.downsampledCanvasA, 0, 0, d.width, d.height, 0, 0, width, height);
		//ctx.drawImage(this.downsampledCanvasA, 0, 0);
	}*/
}


TheModRenderer.prototype.RenderFullRes = function(frame, ctx, width, height)
{
  this.logoLayer.Render(frame, ctx, width, height);
  this.scroller.Render(frame, ctx, width, height);
}

