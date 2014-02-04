

var BackgroundLayer = function()
{
	this.paperImg = new TheModImage('paper.jpg');
}

BackgroundLayer.prototype.Render = function(frame, ctx, width, height)
{
	ctx.rect(0,0,width, height);
	if(this.paperImg.loaded)
	{
		var paperPattern = ctx.createPattern(this.paperImg.img, "repeat");
		ctx.fillStyle = paperPattern;
	}
	else
	{
		ctx.fillStyle = '#080';
	}
	ctx.fill();
};

