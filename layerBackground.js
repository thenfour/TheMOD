

var BackgroundLayer = function()
{
}

BackgroundLayer.prototype.Render = function(frame, ctx, width, height)
{
	var footerSizeY = 37;

	ctx.fillStyle = darkDarkPurple;
	ctx.fillRect(0,0,width, height - footerSizeY);

	ctx.clearRect(0, height - footerSizeY, width, height);
};

