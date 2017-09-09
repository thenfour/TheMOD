// http://webglfundamentals.org/webgl/lessons/webgl-2d-matrices.html
// http://codepen.io/anon/pen/eNVWWB
// uniforms types https://github.com/mrdoob/three.js/wiki/Uniforms-types
var SK = SK || {};


SK.App = function()
{
	this.storageEngine = new SK.FakeStorage();
	this.cms = new SK.CMS({
		storageEngine: this.storageEngine,
		languages: [
			{ lang: "en-US", anchorID: "taalEN" }
		]
	});
	
	if(isAudioSupported())
	{
		var autoPlay = false;
		this.audioEngine = new SK.Audio(this.storageEngine, {
			playElementID: 'playButton',
			pauseElementID: 'pauseButton',
			previousSongElementID: 'previousSongButton',
			nextSongElementID: 'nextSongButton',
			songNameElementID: 'songName'
		}, autoPlay, 2000);
	}
	else
	{
		$('#mediaContainer')
			.css('display', 'none');
	}

	var manager = new THREE.LoadingManager(bind(this,function(){
		$("#loading").hide();
		this.beginGlsl();
	}));

	manager.onProgress = function ( item, loaded, total ){
		//$("#loading").text("loading: " + loaded + "/" + total);
		//console.log( item, loaded, total );
	};


	(new THREE.TextureLoader(manager)).load('images/ash_uvgrid01.jpg', bind(this, function(tex){
		this.bgTexture = tex;
	}));

	//(new THREE.TextureLoader(manager)).load('images/tenfourgradient.png', bind(this, function(tex){ this.tenfourGradientTexture = tex; }));
	//(new THREE.TextureLoader(manager)).load('images/dumbgradient.png', bind(this, function(tex){ this.dumbGradientTexture = tex; }));
	//(new THREE.TextureLoader(manager)).load('images/noise.png', bind(this, function(tex){ this.noiseTexture = tex; }));
	(new THREE.XHRLoader(manager)).load('shaders/main.glsl', bind(this, function(contents){ this.ps = contents; }));
};


// called when all glsl assets are loaded.
SK.App.prototype.beginGlsl = function()
{
  this.startTime = Date.now();
  this.camera = new THREE.Camera();
  this.camera.position.z = 0;

  this.scene = new THREE.Scene();

  var geometry = new THREE.PlaneBufferGeometry( 2, 2 );

  // configure textures
  //this.kickTexture
  
  // this.tenfourGradientTexture.wrapS = THREE.RepeatWrapping;
  // this.tenfourGradientTexture.wrapT = THREE.RepeatWrapping;
  // this.tenfourGradientTexture.magFilter = THREE.NearestFilter;
  // this.tenfourGradientTexture.minFilter = THREE.NearestFilter;
  // this.tenfourGradientTexture.needsUpdate = true;

  // this.dumbGradientTexture.wrapS = THREE.RepeatWrapping;
  // this.dumbGradientTexture.wrapT = THREE.RepeatWrapping;
  // this.dumbGradientTexture.magFilter = THREE.NearestFilter;
  // this.dumbGradientTexture.minFilter = THREE.NearestFilter;
  // this.dumbGradientTexture.needsUpdate = true;

  // this.noiseTexture.wrapS = THREE.RepeatWrapping;
  // this.noiseTexture.wrapT = THREE.RepeatWrapping;
  // this.noiseTexture.needsUpdate = true;

  this.uniforms = {
    iGlobalTime: { type: "f", value: 1.0 },
    iResolution: { type: "v3", value: new THREE.Vector3() },
    iDate: { type: "v4", value: new THREE.Vector4() },
    iMouse: { type: "v4", value: new THREE.Vector4() },
    iFFT: { type: "f", value: 0 },

    bgTexture: { type: "t", value: this.bgTexture },
    bgTextureSize: {type:"v2", value: new THREE.Vector2(this.bgTexture.image.width, this.bgTexture.image.height) },

    // tenfourGradientTexture: { type: "t", value: this.tenfourGradientTexture },
    // tenfourGradientTextureSize: {type:"v2", value: new THREE.Vector2(this.tenfourGradientTexture.image.width, this.tenfourGradientTexture.image.height) },

    // dumbGradientTexture: { type: "t", value: this.dumbGradientTexture },
    // dumbGradientTextureSize: {type:"v2", value: new THREE.Vector2(this.dumbGradientTexture.image.width, this.dumbGradientTexture.image.height) },

    //noiseTexture: { type: "t", value: this.noiseTexture },
    //noiseTextureSize: {type:"v2", value: new THREE.Vector2(this.noiseTexture.image.width, this.noiseTexture.image.height) },
  };

  var material = new THREE.ShaderMaterial( {
    uniforms: this.uniforms,
    vertexShader: document.getElementById( 'vertexShader' ).textContent,
    fragmentShader: this.ps
  } );

  var mesh = new THREE.Mesh( geometry, material );
  this.scene.add( mesh );

  this.renderer = new THREE.WebGLRenderer();
  var cont = document.getElementById("glBody");
  cont.appendChild( this.renderer.domElement );

  this.onWindowResize();

  window.addEventListener('resize', bind(this, function() { this.onWindowResize(); }), false );
  
  $(window).mousemove(bind(this, function(event) {
	  this.uniforms.iMouse.value.x = event.pageX;
	  this.uniforms.iMouse.value.y = event.pageY;
	  this.uniforms.iMouse.value.z = 0;
	  this.uniforms.iMouse.value.w = 0;
		//console.log("cursor: (" + event.clientX + ", " + event.clientY + ")");
  }));

	this.doAnimFrame();
};

SK.App.prototype.onWindowResize = function()
{
	var x = window.innerWidth;
	var y = window.innerHeight;
	this.uniforms.iResolution.value.x = x;
	this.uniforms.iResolution.value.y = y;
	this.uniforms.iResolution.value.z = 0;

	// clamp mouse pos
	this.uniforms.iMouse.value.x = Math.min(this.uniforms.iMouse.value.x, x);
	this.uniforms.iMouse.value.y = Math.min(this.uniforms.iMouse.value.y, y);

	this.renderer.setSize(x, y);
};


SK.App.prototype.doAnimFrame = function()
{
 	requestAnimationFrame(bind(this, function() { this.doAnimFrame(); }));
  this.drawScene();
};

SK.App.prototype.drawScene = function()
{
  var currentTime = Date.now();
  this.uniforms.iGlobalTime.value = (currentTime - this.startTime) * 0.001;

  this.uniforms.iDate.value.x = currentTime.year;
  this.uniforms.iDate.value.y = currentTime.month;
  this.uniforms.iDate.value.z = currentTime.day;
  this.uniforms.iDate.value.w = currentTime.second + currentTime.milliseconds;

	console.log("cursor: (" + this.uniforms.iMouse.value.x + ", " + this.uniforms.iMouse.value.y + ") iRes.y=" + this.uniforms.iResolution.value.y + ", mc.y=" + 
		(this.uniforms.iMouse.value.y / this.uniforms.iResolution.value.y));

  this.renderer.render( this.scene, this.camera );
};


window.onload = function()
{
	window.slashKickApp = new SK.App();
};


