
var TheModRenderer = function()
{
	this.backgroundLayer = new BackgroundLayer();
	this.logoLayer = new LogoLayer();
	this.topBackCurtain = new TopBackCurtainLayer();
	this.sunLayer = new SunLayer();

	this.fadeInTween = new Tween(0.8, null, Easing.Quadratic.InOut);
}

TheModRenderer.prototype.GetFrameInfo = function(frame, ctx)
{
	return {
		mainOpacity: this.fadeInTween.tween(frame, 0, 1)
	};
}

TheModRenderer.prototype.Render = function(frame, ctx, width, height, canvas)
{
	this.backgroundLayer.Render(frame, ctx, width, height);
  this.topBackCurtain.Render(frame, ctx, width, height, false);
	this.sunLayer.Render(frame, ctx, width, height);
  this.topBackCurtain.Render(frame, ctx, width, height, true);
  this.logoLayer.Render(frame, ctx, width, height);
}

