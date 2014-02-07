

var TopRightSquaresLayer = function()
{
	this.rotationEnvX = new RandEnvelope(147);
	this.rotationEnvY = new RandEnvelope(148);

	this.opacityXEnv =	new RandEnvelope(145);
	this.opacityYEnv = new RandEnvelope(146);
};

TopRightSquaresLayer.prototype.Render = function(frame, ctx, canvasWidth, canvasHeight)
{
	var width = canvasWidth;// / 2;

	RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, {
		xflip: true,
		evenFillColor: null,
		evenStrokeColor: null,
		evenStrokeWidth: 0,
		oddFillColor: '#ccc',
		oddStrokeColor: null,
		oddStrokeWidth: 2,
		left: 0,
		top: 0,
		height: 200,
		blockSizeX: 33,
		showTwinkle: true,
		
		RowWidthFunction: function(y, top, bottom){
			return width;
		},
		OpacityFunction: function(x, y, top, bottom, left, right){
			var yprog = 1 - ((y - top) / (bottom - top));
			var xprog = 1 - ((x - left) / (right - left));
			return 0.9 * (Math.pow(yprog, 2) * Math.pow(xprog, 2));
		}
	});
};

