// actualyl the pixelate effect is no longer used; it actually hurt performance instead of helped it.

var TheModEngine = function(divContainerID, sceneRenderer)
{
	this.divContainer = document.getElementById(divContainerID);
	var globalInfo = sceneRenderer.GetGlobalInfo();
	this.pixelSizeX = globalInfo.pixelSizeX;
	this.pixelSizeY = globalInfo.pixelSizeY;
	this.sceneRenderer = sceneRenderer;
	this.targetFps = globalInfo.targetFrameRate;

	this.frameDurations = [];

	this.offscreenCanvasElement = document.createElement('canvas');
	this.onscreenCanvasElement = document.createElement('canvas');
	this.divContainer.appendChild(this.onscreenCanvasElement);

	this.showDebug = false;

	$(this.onscreenCanvasElement)
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

	this.lastRenderInfo =	{
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
	var c = this.offscreenCanvasElement;
	c = this.onscreenCanvasElement;

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

	var renderInfo = this.sceneRenderer.GetFrameInfo(frame, ctx);
	if(!renderInfo) renderInfo = this.lastRenderInfo;
	this.lastRenderInfo = renderInfo;

	this.sceneRenderer.RenderPixelated(frame, ctx, width, height);

	////////////////////////////////////////////////////////////////////////////////////////////////

	ctx.restore();

	////////////////////////////////////////////////////////////////////////////////////////////////
	// pixelate scale.
	ctx1 = this.onscreenCanvasElement.getContext("2d");
	ctx1.save();
	/*
	ctx1.fillStyle = '#000';
	ctx1.fillRect(0,0,this.onscreenCanvasElement.width, this.onscreenCanvasElement.height);
	ctx1.globalAlpha = renderInfo.mainOpacity;

	ctx1.mozImageSmoothingEnabled = false;
	ctx1.webkitImageSmoothingEnabled = false;
	ctx1.imageSmoothingEnabled = false;

	ctx1.drawImage(this.offscreenCanvasElement, 0, 0,
		this.offscreenCanvasElement.width, this.offscreenCanvasElement.height,
		0, 0, this.onscreenCanvasElement.width, this.onscreenCanvasElement.height);
*/
	////////////////////////////////////////////////////////////////////////////////////////////////
	this.sceneRenderer.RenderFullRes(frame, ctx1, width, height);

	////////////////////////////////////////////////////////////////////////////////////////////////
	var frameElapse = (new Date().getTime() - this.startTime) - frame.time;
	var frameDurationAvg = 30;

	this.frameDurations.push(frameElapse);

	if(this.frameDurations.length > frameDurationAvg)
		this.frameDurations.shift();


	////////////////////////////////////////////////////////////////////////////////////////////////
	if(this.showDebug)
	{
		var avgFrameRate = 0;
		for(var i = 0; i < this.frameDurations.length; ++ i)
		{
			avgFrameRate += this.frameDurations[i];
		}
		avgFrameRate /= frameDurationAvg;

		var dbgString1 = Math.round(frame.frameRate) + " fps; time=" + frame.time + " (" + width + "," + height + ") " + ((frame.frameNumber % 2 == 0) ? "#" : " ");
		var dbgString2 = "frame overhead: " + frameElapse + "; frame# " + frame.frameNumber;
		var dbgString3 = "frame overhead AVG: " + Math.round(avgFrameRate) + " over " + frameDurationAvg + " frames";
		var dbgString4 = "offscreen:(" + this.offscreenCanvasElement.width + "," + this.offscreenCanvasElement.height +
			") onscreen:(" + this.onscreenCanvasElement.width + ", " + this.onscreenCanvasElement.height +
			") window:("+ $(window).width() + "," + $(window).height() + ")";

	  ctx1.font = "18px calibri";
		ctx1.fillStyle="#fff";
		ctx1.lineWidth = 3;
		ctx1.strokeStyle = '#000';
	  ctx1.strokeText(dbgString1, 20, 20);
	  ctx1.strokeText(dbgString2, 20, 40);
	  ctx1.strokeText(dbgString3, 20, 60);
	  ctx1.strokeText(dbgString4, 20, 80);
	  ctx1.fillText(dbgString1, 20, 20);
	  ctx1.fillText(dbgString2, 20, 40);
	  ctx1.fillText(dbgString3, 20, 60);
	  ctx1.fillText(dbgString4, 20, 80);
	}

	////////////////////////////////////////////////////////////////////////////////////////////////

	ctx1.restore();

	////////////////////////////////////////////////////////////////////////////////////////////////
	var thisEngine = this;

	setTimeout(function()
	{
	  window.requestAnimFrame(function(){thisEngine.__animFrame();});
	}, (1000 / this.targetFps));
}



