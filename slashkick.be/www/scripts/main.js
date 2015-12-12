// http://webglfundamentals.org/webgl/lessons/webgl-2d-matrices.html
// http://codepen.io/anon/pen/eNVWWB
// uniforms types https://github.com/mrdoob/three.js/wiki/Uniforms-types

bind = function($this, fn)
{
	return fn.bind($this);
}

var SlashKickApp = function()
{
  this.startTime = Date.now();
  this.camera = new THREE.Camera();
  this.camera.position.z = 0;

  this.scene = new THREE.Scene();


	var texloader = new THREE.TextureLoader();

  var geometry = new THREE.PlaneBufferGeometry( 2, 2 );

  this.uniforms = {
    iGlobalTime: { type: "f", value: 1.0 },
    iResolution: { type: "v3", value: new THREE.Vector3() },
    iDate: { type: "v4", value: new THREE.Vector4() },
    iMouse: { type: "v4", value: new THREE.Vector4() },
    iFFT: { type: "f", value: 0 },
    kickTexture: { type: "t", value: texloader.load('images/KICK.png') }
  };

  var material = new THREE.ShaderMaterial( {
    uniforms: this.uniforms,
    vertexShader: document.getElementById( 'vertexShader' ).textContent,
    fragmentShader: document.getElementById( 'fragmentShader' ).textContent
  } );

  var mesh = new THREE.Mesh( geometry, material );
  this.scene.add( mesh );

  this.renderer = new THREE.WebGLRenderer();
  var cont = document.getElementById("glBody");
  cont.appendChild( this.renderer.domElement );

  this.onWindowResize();

  window.addEventListener( 'resize', bind(this, function() { this.onWindowResize(); }), false );

	this.doAnimFrame();
}


SlashKickApp.prototype.uvToWindowCoords = function(uv, iResolution)
{
	var ret = { x : uv.x, y : uv.y };

	ret.y += ret.x * .3333;

	// add padding to correct aspect.
	if(iResolution.x > iResolution.y)
		ret.x /= iResolution.x / iResolution.y;
	else
		ret.y *= iResolution.x / iResolution.y;

	ret.y -= -.3;
	ret.x -= .3;

	ret.x /= 2.1;
	ret.y /= 2.1;

	ret.x += .5;
	ret.x *= iResolution.x;
	ret.y += .5;
	ret.y *= iResolution.y;

	ret.y = iResolution.y - ret.y;
	return ret;
};

SlashKickApp.prototype.onWindowResize = function()
{
	var x = window.innerWidth;
	var y = window.innerHeight;
	this.uniforms.iResolution.value.x = x;
	this.uniforms.iResolution.value.y = y;
	this.uniforms.iResolution.value.z = 0;
	this.renderer.setSize(x, y);


	// position text block.
	var iResolution = {x:x,y:y};

	var tl = this.uvToWindowCoords({ x: -.13, y: -.6}, iResolution);
	var br = this.uvToWindowCoords({x:1.5,y:1.5}, iResolution);

	tl.x = Math.min(Math.max(0,tl.x), iResolution.x);
	tl.y = Math.min(Math.max(0,tl.y), iResolution.y);
	br.x = Math.min(Math.max(0,br.x), iResolution.x);
	br.y = Math.min(Math.max(0,br.y), iResolution.y);

	var noskew = "0";
	var skew = "skew(0,-" + Math.atan(0.33333) + "rad)";
	$("#desc")
		.css({
			top: tl.y + "px",
			left: tl.x + "px",
			width: Math.abs(br.x-tl.x)+"px",
			height: Math.abs(br.y-tl.y)+"px",
			"-webkit-transform-origin": "0",
			"-webkit-transform": noskew,
			"-ms-transform-origin": "0",
			"-ms-transform": noskew,
			"transform-origin": "0",
			"transform": noskew
		});

	// tl = this.uvToWindowCoords({ x: -.15, y: -.6}, iResolution);
	// $("#social")
	// 	.css({
	// 		top: tl.y + "px",
	// 		left: tl.x + "px",
	// 		"-webkit-transform-origin": "0",
	// 		"-webkit-transform": noskew,
	// 		"-ms-transform-origin": "0",
	// 		"-ms-transform": noskew,
	// 		"transform-origin": "0",
	// 		"transform": noskew
	// 	});
};


SlashKickApp.prototype.doAnimFrame = function()
{
 	requestAnimationFrame(bind(this, function() { this.doAnimFrame(); }));
  this.drawScene();
}

SlashKickApp.prototype.drawScene = function()
{
  var currentTime = Date.now();
  this.uniforms.iGlobalTime.value = (currentTime - this.startTime) * 0.001;
  
  this.uniforms.iDate.value.x = currentTime.year;
  this.uniforms.iDate.value.y = currentTime.month;
  this.uniforms.iDate.value.z = currentTime.day;
  this.uniforms.iDate.value.w = currentTime.second + currentTime.milliseconds;
  
  this.uniforms.iMouse.value.x = 0;
  this.uniforms.iMouse.value.y = 0;
  this.uniforms.iMouse.value.z = 0;
  this.uniforms.iMouse.value.w = 0;

  this.uniforms.iFFT.value = 0;//.009*(Math.sin(this.uniforms.iGlobalTime.value) * .5+.5);

  this.renderer.render( this.scene, this.camera );
};


window.onload = function()
{
	window.slashKickApp = new SlashKickApp();
};


