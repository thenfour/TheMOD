

var LayerBackground = function()
{
	this.paperImg = new Image();
	this.paperImg.src = 'paper.jpg';
}

LayerBackground.prototype.render = function(stage, frame, layer)
{

	layer.add(new Kinetic.Rect({
		x:0,
		y:0,
		width:stage.width(),
		height:stage.height(),
		fill:backgroundColor
	}));

	/*backgroundLayer.add(new Kinetic.Rect({
		x:0,
		y:0,
		width:stage.width(),
		height:stage.height(),
		fillPatternImage: this.paperImg
	}));*/

};

