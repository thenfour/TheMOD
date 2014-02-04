

var TheModEngine = function(divContainerID, sceneRenderer, targetFps, pixelSizeX, pixelSizeY)
{
	this.divContainer = document.getElementById(divContainerID);
	this.pixelSizeX = pixelSizeX;
	this.pixelSizeY = pixelSizeY;
	this.sceneRenderer = sceneRenderer;
	this.targetFps = targetFps;

	this.offscreenCanvasElement = document.createElement('canvas');
	this.onscreenCanvasElement = document.createElement('canvas');
	this.divContainer.appendChild(this.onscreenCanvasElement);

	this.showDebug = false;

	$(this.onscreenCanvasElement)
		//.css('width', "100%")
		//.css('height', "100%")

    .css('image-rendering', 'optimizeSpeed')
    .css('image-rendering', '-moz-crisp-edges')
    .css('image-rendering', '-webkit-optimize-contrast')
    .css('image-rendering', '-o-crisp-edges')
    .css('image-rendering', 'crisp-edges')
    .css('-ms-interpolation-mode', 'nearest-neighbor');

	$(this.onscreenCanvasElement)
    .css('image-rendering', 'optimizeSpeed')
    .css('image-rendering', '-moz-crisp-edges')
    .css('image-rendering', '-webkit-optimize-contrast')
    .css('image-rendering', '-o-crisp-edges')
    .css('image-rendering', 'crisp-edges')
    .css('-ms-interpolation-mode', 'nearest-neighbor');

	// defaults
	this.lastRenderInfo =	{
		//pixelSizeX: 2,
		//pixelSizeY: 2,
		mainOpacity: 1.0
	};

	this.startTime = new Date().getTime();

	if(!window.requestAnimFrame)
	{
		window.requestAnimFrame = (function(callback)
		{
		  return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame ||
		  function(callback) {
		    window.setTimeout(callback, 1000 / targetFps);
		  };
		})();
	}

	// keep canvas the size of the window
	var thisEngine = this;

	$(window).keydown(function(e){
		var code = e.keyCode || e.which;
		if(code == 32) {
			thisEngine.showDebug = !thisEngine.showDebug;
		}
	});

	$(window).bind('resize', function(){thisEngine.__onResize();});

	this.__onResize();

  // begin animation engine
  window.requestAnimFrame(function(){thisEngine.__animFrame();});
}

TheModEngine.prototype.__onResize = function()
{
	this.__updateCanvasSizes();
}

TheModEngine.prototype.__updateCanvasSizes = function()
{
	var containerWidth = $(this.divContainer).width();
	var containerHeight = $(this.divContainer).height();

	// internal size:
	this.offscreenCanvasElement.width = containerWidth / this.pixelSizeX;
	this.offscreenCanvasElement.height = containerHeight / this.pixelSizeY;

	// internal size:
	this.onscreenCanvasElement.width = containerWidth;
	this.onscreenCanvasElement.height = containerHeight;

	// display size:
  $(this.onscreenCanvasElement)
  	.css("width", containerWidth + "px")
  	.css("height", containerHeight + "px")
  	;
}

TheModEngine.prototype.__animFrame = function()
{
	// make sure canvases are the right size
	var renderInfo = this.sceneRenderer.GetFrameInfo;
	if(!renderInfo) renderInfo = this.lastRenderInfo;
	this.lastRenderInfo = renderInfo;

	var c = this.offscreenCanvasElement;

	var frame =
	{
		frameNumber: 1,
		timeDiff: 0,
		time: new Date().getTime() - this.startTime,
		lastTime: 0,
		frameRate: 0
	};
	if(this.lastFrame)
	{
		frame.frameNumber = this.lastFrame.frameNumber + 1;
		frame.timeDiff = frame.time - this.lastFrame.time;
		frame.lastTime = this.lastFrame.time;
		frame.frameRate = 1 / (frame.timeDiff / 1000);
	}
	this.lastFrame = frame;

	var width = c.width;
	var height = c.height;

	var ctx=c.getContext("2d");
	ctx.save();
	ctx.scale(1/this.pixelSizeX, 1/this.pixelSizeY);

	////////////////////////////////////////////////////////////////////////////////////////////////
	var width = this.onscreenCanvasElement.width;
	var height = this.onscreenCanvasElement.height;

	this.sceneRenderer.Render(frame, ctx, width, height);

	////////////////////////////////////////////////////////////////////////////////////////////////

	ctx.restore();

	////////////////////////////////////////////////////////////////////////////////////////////////
	// pixelate scale.
	ctx1 = this.onscreenCanvasElement.getContext("2d");
	ctx1.save();
	
	ctx1.mozImageSmoothingEnabled = false;
	ctx1.webkitImageSmoothingEnabled = false;
	ctx1.imageSmoothingEnabled = false;

	ctx1.drawImage(this.offscreenCanvasElement, 0, 0,
		this.offscreenCanvasElement.width, this.offscreenCanvasElement.height,
		0, 0, this.onscreenCanvasElement.width, this.onscreenCanvasElement.height);

	////////////////////////////////////////////////////////////////////////////////////////////////
	if(this.showDebug)
	{
		var frameElapse = (new Date().getTime() - this.startTime) - frame.time;
		var dbgString1 = Math.round(frame.frameRate) + " fps; time=" + frame.time + " (" + width + "," + height + ") " + ((frame.frameNumber % 2 == 0) ? "#" : " ");
		var dbgString2 = "frame overhead: " + frameElapse + "; frame# " + frame.frameNumber;
		var dbgString3 = "offscreen:(" + this.offscreenCanvasElement.width + "," + this.offscreenCanvasElement.height +
			") onscreen:(" + this.onscreenCanvasElement.width + ", " + this.onscreenCanvasElement.height +
			") window:("+ $(window).width() + "," + $(window).height() + ")";

	  ctx1.font = "18px calibri";
		ctx1.fillStyle="#fff";
		ctx1.lineWidth = 3;
		ctx1.strokeStyle = '#000';
	  ctx1.strokeText(dbgString1, 20, 20);
	  ctx1.strokeText(dbgString2, 20, 40);
	  ctx1.strokeText(dbgString3, 20, 60);
	  ctx1.fillText(dbgString1, 20, 20);
	  ctx1.fillText(dbgString2, 20, 40);
	  ctx1.fillText(dbgString3, 20, 60);
	}

	ctx1.restore();

	////////////////////////////////////////////////////////////////////////////////////////////////
	var thisEngine = this;

	setTimeout(function()
	{
	  window.requestAnimFrame(function(){thisEngine.__animFrame();});
	}, (1000 / this.targetFps));
}



