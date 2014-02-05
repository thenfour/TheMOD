
var TheModRenderer = function()
{
	this.backgroundLayer = new BackgroundLayer();
	this.logoLayer = new LogoLayer();
	this.topBackCurtain = new TopBackCurtainLayer();
	this.sunLayer = new SunLayer();
	this.scroller = new ScrollerLayer();

	this.fadeInTween = new Tween(1.2, null, Easing.Quadratic.InOut);
}

TheModRenderer.prototype.GetFrameInfo = function(frame, ctx)
{
	return {
		mainOpacity: this.fadeInTween.tween(frame, 0, 1)
	};
}

TheModRenderer.prototype.RenderPixelated = function(frame, ctx, width, height)
{
	this.backgroundLayer.Render(frame, ctx, width, height);
  this.topBackCurtain.Render(frame, ctx, width, height, 0);
	this.sunLayer.Render(frame, ctx, width, height);
  this.topBackCurtain.Render(frame, ctx, width, height, 1);
}


TheModRenderer.prototype.RenderFullRes = function(frame, ctx, width, height)
{
  this.logoLayer.Render(frame, ctx, width, height);
  this.scroller.Render(frame, ctx, width, height);
}

