
uniform sampler2D kickTexture;
uniform vec2 kickTextureSize;
uniform sampler2D tenfourGradientTexture;
uniform vec2 tenfourGradientTextureSize;
uniform sampler2D dumbGradientTexture;
uniform vec2 dumbGradientTextureSize;
// uniform sampler2D noiseTexture;
// uniform vec2 noiseTextureSize;


uniform vec3 iResolution;
uniform float iGlobalTime;
uniform vec4 iMouse;
uniform vec4 iDate;
uniform float iFFT;


highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

highp float hash(highp float n )
{
    return fract(sin(n)*43758.5453);
}


// convert distance to alpha
float dtoa(float d, float amount)
{
    float a = clamp(1.0 / (clamp(d, 1.0/amount, 1.0)*amount), 0.,1.);
    return a;
}


const float pixelSize = 2.5;
const float idealColorChangeWidth = .82;// % of scan width
const float animatedPerturbanceAmt = 0.04;// % of scan width
const float fixedPerturbanceAmt = 0.04;// % of scan width

const float animationSpeed = 32.0;

//----------------------------------------------------------------------

vec4 getRasterColor(vec2 i)
{
	i.y -= iGlobalTime*animationSpeed;

  vec2 pVirt = floor(i / pixelSize);// pixel coords in simulated screen space.
  vec2 virtRes = floor(iResolution.xy / pixelSize);
  vec2 uv = pVirt / virtRes;

  float linPixel = pVirt.x + (pVirt.y * virtRes.x);
  float bandWidth = virtRes.x * idealColorChangeWidth;// with no glitches, color bands span X% of the screen.
  linPixel -= (hash(pVirt.y)*2.-1.)*virtRes.x*fixedPerturbanceAmt;// perturb by Y up to X% of screen width
  linPixel -= (hash(iGlobalTime)*2.-1.)*virtRes.x*animatedPerturbanceAmt;// perturb by time up to X% of screen width
  float band = linPixel / bandWidth;
  
  // select which gradient to show
  if(mod(iGlobalTime, 3.) < 2.)
  	return texture2D(tenfourGradientTexture, vec2(0, band/16.));
  else
  	return texture2D(dumbGradientTexture, vec2(0, band/16.));
}


void band(inout vec3 o, vec2 uv, float y, vec3 c)
{
    o.rgb = mix(o.rgb, c, dtoa(uv.y - y, 400.));
}

float sdSegment1D(float uv, float a, float b)
{
    return max(a - uv, uv - b);
}

float sdAxisAlignedRect(vec2 uv, vec2 tl, vec2 br)
{
  	vec2 d = max(tl - uv, uv - br);
    return length(max(vec2(0.0), d)) + min(0.0, max(d.x, d.y));
}


void blit(inout vec3 o, vec2 uv, vec2 pos, vec2 destSize, vec2 uvPix)
{
    uv -= pos;
    uv /= destSize;

    float d = sdAxisAlignedRect(uv, vec2(0.), vec2(1.));
    float alpha = step(d, 0.);
    // causes artifacts. we actually need to sample and use alpha instead
    //if(alpha < 0) return;

    //uv.y = 1.-uv.y;// flip y coord
    vec4 s = texture2D(kickTexture, uv);
    //o = mix(o.rgb, s.rgb, s.a * alpha);

    vec4 rasterColor = vec4(0);
    //getRasterColor(rasterColor, uvPix);
    //rasterColor = vec4(1);

    o = mix(o.rgb, rasterColor.rgb, s.a * alpha);
}

void slash_color(inout vec3 o, vec2 uv, float left, float right, vec3 col)
{
    uv.x -= (uv.y*.7);
    float d = sdAxisAlignedRect(uv, vec2(left,-1), vec2(right,1));
    o = mix(o, col, 1.-smoothstep(0.,.007,d));
}


void main()
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy - .5;
	uv *= 2.1;
	uv += vec2(.3,-.3);
	// add padding to correct aspect.
	if(iResolution.x > iResolution.y)
		uv.x *= iResolution.x / iResolution.y;
	else
		uv.y /= iResolution.x / iResolution.y;
	
	uv.y -= uv.x * .3333;// shear

	vec2 uvPix = gl_FragCoord.xy;
	uvPix.y -= uvPix.x * .3333;


	vec4 o = vec4(vec3(0.3,0.3,0.7),1);// BLUE
  band(o.rgb, uv, .90, vec3(0,0,0));// BLACK
 	band(o.rgb, uv, .83, vec3(1,.5,0));// ORANGE
 	band(o.rgb, uv, .60, vec3(0));// BLACK

  // slash
  vec3 grayColor = vec3(.5,.5,.5);
  slash_color(grayColor, uv, -.8, -.54, vec3(.2,.2,.2));
  slash_color(grayColor, uv, -.55, -.5, vec3(.0,.0,.0));
  blit(grayColor, uv, vec2(-.2,-.715), vec2(2.,1.55), uvPix);// KICK

  band(o.rgb, uv, .5, grayColor);// GRAY BACKGROUND
  band(o.rgb, uv, -.5, vec3(0,0,0));// BLACK
  band(o.rgb, uv, -.6, vec3(1,1,1));

	float d = sdSegment1D(uv.y, .54, .77);// RASTER 1 (out of order)
	if(d <= 0.)
	{
		o = mix(o, getRasterColor(uvPix), 1.-smoothstep(-0.02, 0., d));
	}

	d = sdSegment1D(uv.y, -.58, -.52);// RASTER 2
	if(d <= 0.)
	{
		o = mix(o, getRasterColor(uvPix), 1.-smoothstep(-0.02, 0., d));
	}

  // POST PROCESSING
	vec2 uvn = gl_FragCoord.xy / iResolution.xy - .5;
	uvn *= 2.;

  o.rgb *= 1.-rand(uvPix+iGlobalTime)*.12;
  //o.rgb = vec3(1);
  float v = 1.-dot(uvn*.9, uvn*.9)*.4;// vignette attenuation
  v = pow(v, 1./2.2);
  v = clamp(v, 0., 1.);
  o.rgb *= v;// vignette

  // fade-in
  o.rgb *= smoothstep(0., 2.5, iGlobalTime);

  gl_FragColor = vec4(o.rgb, 1.);
}



