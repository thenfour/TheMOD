// actually the pixelate effect is no longer used; it actually hurt performance instead of helped it.

// for performance reasons just keep a global engine. we don't expect to have more than one running on a single page.
var globalEngine = null;

function __globalAnimFrame()
{
	globalEngine.__animFrame();
}

var TheModEngine = function(divContainerID, sceneRenderer, fadeContainerID, audioInterface)
{
	globalEngine = this;

	this.audioInterface = audioInterface;

	this.divContainer = document.getElementById(divContainerID);
	this.fadeContainer = document.getElementById(fadeContainerID);
	var globalInfo = sceneRenderer.GetGlobalInfo();
	this.pixelSizeX = globalInfo.pixelSizeX;
	this.pixelSizeY = globalInfo.pixelSizeY;
	this.sceneRenderer = sceneRenderer;
	this.targetFps = globalInfo.targetFrameRate;
	this.avgFrameDuration = 0;

	this.frameDurations = [];

	//this.offscreenCanvasElement = document.createElement('canvas');
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
	//this.offscreenCanvasElement.width = containerWidth / this.pixelSizeX;
	//this.offscreenCanvasElement.height = containerHeight / this.pixelSizeY;

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
	//var c = this.offscreenCanvasElement;
	var c = this.onscreenCanvasElement;

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
	//ctx.scale(1/this.pixelSizeX, 1/this.pixelSizeY);

	////////////////////////////////////////////////////////////////////////////////////////////////
	//var width = this.onscreenCanvasElement.width;
	//var height = this.onscreenCanvasElement.height;

	var renderInfo = this.sceneRenderer.GetFrameInfo(frame, ctx);
	if(!renderInfo) renderInfo = this.lastRenderInfo;
	this.lastRenderInfo = renderInfo;

	var mainOpacity = renderInfo.mainOpacity;
	if(mainOpacity > 0.995)
	{
		$(this.fadeContainer)
			.css('opacity', '')
			.css('filter', '');
	}
	else
	{
		$(this.fadeContainer)
			.css('opacity', mainOpacity)
			.css('filter', 'alpha(opacity=' + Math.floor(mainOpacity * 10) + ');');
	}

	this.sceneRenderer.RenderPixelated(frame, ctx, width, height);

	////////////////////////////////////////////////////////////////////////////////////////////////

	//ctx.restore();

	////////////////////////////////////////////////////////////////////////////////////////////////
	// pixelate scale.
//	ctx1 = this.onscreenCanvasElement.getContext("2d");
//	ctx1.save();
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
	this.sceneRenderer.RenderFullRes(frame, ctx, width, height);

	////////////////////////////////////////////////////////////////////////////////////////////////
	if(this.showDebug)
	{
		var frameElapse = (new Date().getTime() - this.startTime) - frame.time;
		var frameDurationAvgCount = 100;

		this.frameDurations.push(frameElapse);
		this.avgFrameDuration += (frameElapse - this.avgFrameDuration) / (this.frameDurations.length);// adjust moving average without enumerating everything.

		if(this.frameDurations.length > frameDurationAvgCount)
		{
			var old = this.frameDurations.shift();
			this.avgFrameDuration -= (old - this.avgFrameDuration) / (this.frameDurations.length);// adjust moving average without enumerating everything.
		}

		var dbgStrings = [
			Math.round(frame.frameRate) + " fps; time=" + frame.time + " (" + width + "," + height + ") " + ((frame.frameNumber % 2 == 0) ? "#" : " "),
			"frame overhead: " + frameElapse + "; frame# " + frame.frameNumber,
			"frame overhead AVG: " + Math.round(this.avgFrameDuration * 10) / 10 + ", over " + this.frameDurations.length + " frames",
			"(" + this.onscreenCanvasElement.width + ", " + this.onscreenCanvasElement.height +  ")",
			'playing @ ' + Math.round(this.audioInterface.getCurrentSongPosition() * 10) / 10 + " of " + this.audioInterface.currentSong.Title
		];

	  ctx.font = "18px calibri";
		ctx.fillStyle="#fff";
		ctx.lineWidth = 3;
		ctx.strokeStyle = '#000';
		var y = 20;
		var lineHeight = 20;
		for(var i = 0; i < dbgStrings.length; ++ i)
		{
		  ctx.strokeText(dbgStrings[i], 20, y + (i * lineHeight));
		}
		for(var i = 0; i < dbgStrings.length; ++ i)
		{
		  ctx.fillText(dbgStrings[i], 20, y + (i * lineHeight));
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////

	ctx.restore();

	////////////////////////////////////////////////////////////////////////////////////////////////
	setTimeout(function()
	{
	  window.requestAnimFrame(__globalAnimFrame);
	}, (1000 / this.targetFps));
}



