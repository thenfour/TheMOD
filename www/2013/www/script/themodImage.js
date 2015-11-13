/*$.getScript("mersenne-twister.js");
$.getScript("themodutil.js");
$.getScript("themodImage.js");
*/

var TheModImage = function(src)
{
	// init image
	this.img = new Image();
	this.src = src + "?_=" + new Date().getTime();
	this.loaded = false;

	var thisImage = this;

	this.img.onload = function() {
	    thisImage.width = this.width;
	    thisImage.height = this.height;
	    thisImage.loaded = true;
	};

	this.img.src = this.src;
}


