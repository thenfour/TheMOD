
// implement javascript calls here that you want to call from C++.
// _tMctx is a global that refers to the canvas we're currently drawing on.


LibraryManager.library.jsalert = function(s) { 
};

LibraryManager.library.__canvasSetFillStyle = function(s) {
	_tMctx.fillStyle="#".concat(s.toString(16).slice(1));
};

LibraryManager.library.__canvasSetStrokeStyle = function(s) {
	_tMctx.strokeStyle="#".concat(s.toString(16).slice(1));
};
LibraryManager.library.canvasRect = function(x,y,w,h) {
	_tMctx.rect(x,y,w,h);
};
LibraryManager.library.canvasFillRect = function(x,y,w,h) {
	_tMctx.fillRect(x,y,w,h);
};
LibraryManager.library.canvasSetGlobalAlpha = function(x) {
	_tMctx.globalAlpha=x;
};
LibraryManager.library.canvasSave = function(){
	_tMctx.save();
};
LibraryManager.library.canvasRestore = function(){
	_tMctx.restore();
};
LibraryManager.library.canvasTranslate = function(x, y){
	_tMctx.translate(x,y);
};
LibraryManager.library.canvasScale = function(x, y){
	_tMctx.scale(x,y);
};

LibraryManager.library.canvasRotate = function(r){
	_tMctx.rotate(r);
};
LibraryManager.library.canvasSetShadowOffsetX = function(x){
	_tMctx.shadowOffsetX = x;
};
LibraryManager.library.canvasSetShadowOffsetY = function(y){
	_tMctx.shadowOffsetY = y;
};

LibraryManager.library.canvasBeginPath = function(){
	_tMctx.beginPath();
};
LibraryManager.library.canvasArc = function(x,y,r,sa,ea){
	_tMctx.arc(x,y,r,sa,ea);
};
LibraryManager.library.canvasFill = function(){
	_tMctx.fill();
};
LibraryManager.library.canvasMoveTo = function(x, y){
	_tMctx.moveTo(x,y);
};


LibraryManager.library.canvasLineTo = function(x, y){
	_tMctx.lineTo(x,y);
};
LibraryManager.library.canvasClosePath = function(){
	_tMctx.closePath();
};
LibraryManager.library.canvasSetLineWidth = function(w){
	_tMctx.lineWidth=w;
};


LibraryManager.library.canvasStroke = function() {
	_tMctx.stroke();
};

LibraryManager.library.canvasSetSunLayerShadowColor = function() {
	_tMctx.shadowColor = 'rgba(0,0,0,0.2)';
};

LibraryManager.library.canvasSetSunLayerGradientFill = function(bigR) {
  var grd = _tMctx.createRadialGradient(0, 0, 0, 0, 0, bigR);
  grd.addColorStop(0, '#ffc');
  grd.addColorStop(0.15, '#fed58c');
  grd.addColorStop(1, '#e19c26');
	_tMctx.fillStyle = grd;
};

