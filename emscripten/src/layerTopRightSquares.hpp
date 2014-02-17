
/*
var TopRightSquaresLayer = function()
{
	this.oddColorTable = new TheModColorMixingTable("#ccc", "#fff", 8);

	this.config = {
		xflip: true,
		evenColorTable: null,
		oddColorTable: this.oddColorTable,
		left: 0,
		top: 0,
		height: 200,
		blockSizeX: 30,
		showTwinkle: true,
		
		RowWidthFunction: function(y, top, bottom, canvasWidth){
			return canvasWidth;
		},
		OpacityFunction: function(x, y, top, bottom, left, right, previousRowWidth, thisRowWidth, ix, iy){
			var yprog = 1 - ((y - top) / (bottom - top));
			var xprog = 1 - ((x - left) / (right - left));
			return 0.9 * (Math.pow(yprog, 2) * Math.pow(xprog, 2));
		}
	};
};

TopRightSquaresLayer.prototype.Render = function(frame, ctx, canvasWidth, canvasHeight)
{
	return RenderSquarePattern(frame, ctx, canvasWidth, canvasHeight, this.config);
};

*/


