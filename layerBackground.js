

var BackgroundLayer = function()
{
}

BackgroundLayer.prototype.Render = function(frame, ctx, width, height)
{
	var footerSizeY = 37;

	//ctx.globalAlpha = 1.0;
	ctx.fillStyle = darkDarkPurple;
	ctx.fillRect(0,0,width, height - footerSizeY);

	// ------------------------------------------
	//ctx.fillStyle = '#000';
	ctx.clearRect(0, height - footerSizeY, width, height);
};

