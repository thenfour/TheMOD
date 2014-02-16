

var LogoLayer = function()
{
	this.LogoImg = new TheModImage('img/themod.png');
};

LogoLayer.prototype.Render = function(frame, ctx, width, height)
{
	ctx.drawImage(this.LogoImg.img, 0, -30);
};

