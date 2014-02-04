

var LogoLayer = function()
{
	this.LogoImg = new TheModImage('themod.png');
};

LogoLayer.prototype.Render = function(frame, ctx, width, height)
{
	ctx.drawImage(this.LogoImg.img, 0, -20);
};

