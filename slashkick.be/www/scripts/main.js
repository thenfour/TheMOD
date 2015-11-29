// http://webglfundamentals.org/webgl/lessons/webgl-2d-matrices.html
// http://codepen.io/anon/pen/eNVWWB


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

  var geometry = new THREE.PlaneBufferGeometry( 2, 2 );

  this.uniforms = {
    iGlobalTime: { type: "f", value: 1.0 },
    iResolution: { type: "v3", value: new THREE.Vector3() },
    iDate: { type: "v4", value: new THREE.Vector4() },
    iMouse: { type: "v4", value: new THREE.Vector4() }
  };

  var material = new THREE.ShaderMaterial( {
    uniforms: this.uniforms,
    vertexShader: document.getElementById( 'vertexShader' ).textContent,
    fragmentShader: document.getElementById( 'fragmentShader' ).textContent
  } );

  var mesh = new THREE.Mesh( geometry, material );
  this.scene.add( mesh );

  this.renderer = new THREE.WebGLRenderer();
  document.body.appendChild( this.renderer.domElement );

  this.onWindowResize();

  window.addEventListener( 'resize', bind(this, function() { this.onWindowResize(); }), false );

	this.doAnimFrame();
}

SlashKickApp.prototype.onWindowResize = function()
{
	var x = window.innerWidth;
	var y = window.innerHeight;
	this.uniforms.iResolution.value.x = x;
	this.uniforms.iResolution.value.y = y;
	//console.log("Resizing ("+x+","+y+")");
	this.uniforms.iResolution.value.z = 0;
	this.renderer.setSize(x, y);
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

  this.renderer.render( this.scene, this.camera );
};


window.onload = function()
{
	window.slashKickApp = new SlashKickApp();
};


