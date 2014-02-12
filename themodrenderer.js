
var TheModRenderer = function()
{
	this.downsampleFactor = 2.0;

	this.backgroundLayer = new BackgroundLayer();
	this.logoLayer = new LogoLayer();
	this.topBackCurtain = new TopBackCurtainLayer();
	this.sunLayer = new SunLayer();
	this.scroller = new ScrollerLayer();
	this.navBackground = new NavBackgroundLayer(this.downsampleFactor);
	this.topRightSquares = new TopRightSquaresLayer(this.downsampleFactor);

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

TheModRenderer.prototype.EnsureDownsampledCanvas = function(frame, ctx, width, height)
{
	if(!this.downsampledCanvasA)
	{
		this.downsampledCanvasA = document.createElement('canvas');

		$(this.downsampledCanvasA)
	    .css('image-rendering', 'optimizeSpeed')
	    .css('image-rendering', '-moz-crisp-edges')
	    .css('image-rendering', '-webkit-optimize-contrast')
	    .css('image-rendering', '-o-crisp-edges')
	    .css('image-rendering', 'crisp-edges')
	    .css('-ms-interpolation-mode', 'nearest-neighbor');
	}
	var desiredWidth = width / this.downsampleFactor;
	var desiredHeight = height / this.downsampleFactor;

	if(this.downsampledCanvasA.width != desiredWidth)
		this.downsampledCanvasA.width = desiredWidth;
	if(this.downsampledCanvasA.height != desiredHeight)
		this.downsampledCanvasA.height = desiredHeight;

	return { width: desiredWidth, height: desiredHeight };
}

TheModRenderer.prototype.RenderPixelated = function(frame, ctx, width, height)
{
	ctx.mozImageSmoothingEnabled = false;
	ctx.webkitImageSmoothingEnabled = false;
	ctx.imageSmoothingEnabled = false;

	var downsampleFactor = this.downsampleFactor;
	var downsampled = (downsampleFactor != 1);

	this.backgroundLayer.Render(frame, ctx, width, height);

	var navRect = null;
	var topRightSquaresRect = null;

	if(!downsampled)
		this.navBackground.Render(frame, ctx, width, height, 1);
	else
	{
		var d = this.EnsureDownsampledCanvas(frame, ctx, width, height);
		var ctxds = this.downsampledCanvasA.getContext('2d');
		ctxds.mozImageSmoothingEnabled = false;
		ctxds.webkitImageSmoothingEnabled = false;
		ctxds.imageSmoothingEnabled = false;

		ctxds.clearRect(0, 0, d.width, d.height);
		//ctxds.fillStyle="#00f";
		//ctxds.fillRect(0,0,width, height);

		navRect = this.navBackground.Render(frame, ctxds, d.width, d.height, downsampleFactor);
		topRightSquaresRect = this.topRightSquares.Render(frame, ctxds, d.width, d.height, downsampleFactor);

		ctx.drawImage(this.downsampledCanvasA,
			navRect.left, navRect.top, navRect.width, navRect.height,
			navRect.left * downsampleFactor, navRect.top * downsampleFactor, navRect.width * downsampleFactor, navRect.height * downsampleFactor);
//*/
		//ctx.drawImage(this.downsampledCanvasA, 0, 0);
	}

  this.topBackCurtain.Render(frame, ctx, width, height, 0);
	this.sunLayer.Render(frame, ctx, width, height);
  this.topBackCurtain.Render(frame, ctx, width, height, 1);

	if(!downsampled)
		this.topRightSquares.Render(frame, ctx, width, height, 1);
	else
	{
		ctx.drawImage(this.downsampledCanvasA,
			topRightSquaresRect.left, topRightSquaresRect.top, topRightSquaresRect.width, topRightSquaresRect.height,
			topRightSquaresRect.left * downsampleFactor, topRightSquaresRect.top * downsampleFactor, topRightSquaresRect.width * downsampleFactor, topRightSquaresRect.height * downsampleFactor);
	}
}


TheModRenderer.prototype.RenderFullRes = function(frame, ctx, width, height)
{
  this.logoLayer.Render(frame, ctx, width, height);
  this.scroller.Render(frame, ctx, width, height);
}

