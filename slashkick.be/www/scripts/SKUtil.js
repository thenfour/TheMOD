var SK = SK || {};




bind = function($this, fn)
{
	return fn.bind($this);
}


isCanvasSupported = function(){
  var elem = document.createElement('canvas');
  return !!(elem.getContext && elem.getContext('2d'));
}

isAudioSupported = function() {
	var elem = document.createElement('audio');
	return !!(elem.pause);
}

