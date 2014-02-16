
// implement javascript calls here that you want to call from C++.
// _tMctx is a global that refers to the canvas we're currently drawing on.

LibraryManager.library.jsalert = function(s) { /*alert(s);*/ };
LibraryManager.library.__canvasSetFillStyle = function(s) { _tMctx.fillStyle="#".concat(s.toString(16).slice(1)); };
LibraryManager.library.__canvasSetStrokeStyle = function(s) { _tMctx.fillStyle="#".concat(s.toString(16).slice(1)); };
LibraryManager.library.canvasFillRect = function(x,y,w,h) { _tMctx.fillRect(x,y,w,h); };
LibraryManager.library.canvasSetGlobalAlpha = function(x) { _tMctx.globalAlpha=x; };
