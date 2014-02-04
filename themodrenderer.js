
var TheModRenderer = function()
{
	this.logoLayer = new LogoLayer();
	this.topBackCurtain = new TopBackCurtainLayer();
}

TheModRenderer.prototype.GetFrameInfo = function(frame, ctx)
{
	return {
		mainOpacity: .8
	};
}

TheModRenderer.prototype.Render = function(frame, ctx, width, height)
{
  this.topBackCurtain.Render(frame, ctx, width, height);
  this.logoLayer.Render(frame, ctx, width, height);
}

