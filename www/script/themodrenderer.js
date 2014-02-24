

var TheModRenderer = function()
{
	this.backgroundLayer = new BackgroundLayer();
	this.logoLayer = new LogoLayer();
	this.topBackCurtain = new TopBackCurtainLayer();
	this.sunLayer = new SunLayer();
	this.scroller = new ScrollerLayer();
	this.navBackground = new NavBackgroundLayer();
	this.topRightSquares = new TopRightSquaresLayer();

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
		targetFrameRate: 15,
		pixelSizeX: 1,
		pixelSizeY: 1
	};
}

var _tMctx = null;

TheModRenderer.prototype.RenderPixelated = function(frame, ctx, width, height, c, cpp)
{
	_tMctx = ctx;
	this.backgroundLayer.Render(frame, ctx, width, height);

	//if(cpp)
	//	_cppRenderNavBackgroundLayer(frame.time, width, height);
	//else
	this.navBackground.Render(frame, ctx, width, height);

  this.topBackCurtain.Render(frame, ctx, width, height, 0);

	//if(cpp)
	//	_cppRenderSunLayer(frame.time, width, height);
	//else
	this.sunLayer.Render(frame, ctx, width, height);

  this.topBackCurtain.Render(frame, ctx, width, height, 1);

  //if(cpp)
  //	_cppRenderTopRightSquaresLayer(frame.time, width, height);
  //else
  this.topRightSquares.Render(frame, ctx, width, height);
  
  this.logoLayer.Render(frame, ctx, width, height);
  this.scroller.Render(frame, ctx, width, height);

  _tMctx = null;
}

