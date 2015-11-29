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
  this.camera.position.z = 1;

  this.scene = new THREE.Scene();

  var geometry = new THREE.PlaneBufferGeometry( 2, 1 );

  this.uniforms = {
    iGlobalTime: { type: "f", value: 1.0 },
    iResolution: { type: "v3", value: new THREE.Vector3() }
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
	this.uniforms.iResolution.value.x = window.innerWidth;
	this.uniforms.iResolution.value.y = window.innerHeight;
	this.uniforms.iResolution.value.z = 0;
	this.renderer.setSize( window.innerWidth, window.innerHeight );
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
  this.renderer.render( this.scene, this.camera );
};


window.onload = function()
{
	window.slashKickApp = new SlashKickApp();
};



define("main", function(){});

