// http://webglfundamentals.org/webgl/lessons/webgl-2d-matrices.html
bind = function($this, fn)
{
	return fn.bind($this);
}


var SlashKickApp = function()
{
	this.whenStarted = new Date();

  // Get A WebGL context
  this.canvas = document.getElementById("canvas");
  var canvas = this.canvas;
  this.gl = getWebGLContext(canvas);
  var gl = this.gl;
  if (!gl) {
    return;
  }

  // setup GLSL program
  this.program = createProgramFromScripts(gl, ["2d-vertex-shader", "2d-fragment-shader"]);
  var program = this.program;
  gl.useProgram(program);

  // look up where the vertex data needs to go.
  var positionLocation = gl.getAttribLocation(program, "a_position");

  // Create a buffer and put a single clipspace rectangle in
  // it (2 triangles)
  var buffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
    -1.0, -1.0,
     1.0, -1.0,
    -1.0,  1.0,
    -1.0,  1.0,
     1.0, -1.0,
     1.0,  1.0]), gl.STATIC_DRAW);

  gl.enableVertexAttribArray(positionLocation);
  gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0);

  // draw
  $(window).resize(bind(this, function() { this.onResize(); }));

  this.onResize();
	requestAnimationFrame(bind(this, function() { this.doAnimFrame(); }));
}

SlashKickApp.prototype.onResize = function()
{
	this.canvas.width = document.body.clientWidth;
	this.canvas.height = document.body.clientHeight;

	this.drawScene();
};


SlashKickApp.prototype.doAnimFrame = function()
{
  this.drawScene();
	requestAnimationFrame(bind(this, function() { this.doAnimFrame(); }));
}

SlashKickApp.prototype.drawScene = function()
{
	var gl = this.gl;


  // http://stackoverflow.com/questions/28584589/why-i-cant-use-uniform1f-instead-of-uniform4f-for-setting-a-vec4-uniform
  var d = new Date();
  var iGlobalTime = (d - this.whenStarted) / 1000.;// in seconds.
  var iDate = [d.year, d.month, d.day, d.seconds];
  var iResolution = [320, 200, 0];
  var iMouse = [0,0,0,0];

  var iGlobalTime_location = gl.getUniformLocation(this.program, "iGlobalTime");
  gl.uniform1f(iGlobalTime_location, iGlobalTime);

  var iDate_location = gl.getUniformLocation(this.program, "iDate");
  gl.uniform4f(iDate_location, iDate[0], iDate[1], iDate[2], iDate[3]);

  var iResolution_location = gl.getUniformLocation(this.program, "iResolution");
  gl.uniform3f(iResolution_location, iResolution[0], iResolution[1], iResolution[2]);

  var iMouse_location = gl.getUniformLocation(this.program, "iMouse");
  gl.uniform4f(iMouse_location, iMouse[0], iMouse[1], iMouse[2], iMouse[3]);

	gl.drawArrays(gl.TRIANGLES, 0, 6);
};


window.onload = function()
{
	window.slashKickApp = new SlashKickApp();
};



define("main", function(){});

