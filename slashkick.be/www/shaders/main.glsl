
uniform sampler2D kickTexture;
uniform vec2 kickTextureSize;
uniform sampler2D tenfourGradientTexture;
uniform vec2 tenfourGradientTextureSize;
uniform sampler2D dumbGradientTexture;
uniform vec2 dumbGradientTextureSize;
uniform sampler2D noiseTexture;
uniform vec2 noiseTextureSize;


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

float pixellate(float i, float sz)
{
    return floor(i / sz) * sz;
}


float quantize(float x, float s) { return floor(x/s)*s; }
vec2 quantize(vec2 x, float s) { return floor(x/s)*s; }


const float pixelSize = 2.5;
const float idealColorChangeWidth = .82;// % of scan width
const float animatedPerturbanceAmt = 0.04;// % of scan width
const float fixedPerturbanceAmt = 0.04;// % of scan width

const float animationSpeed = 32.0;


//----------------------------------------------------------------------
// c64 palette
vec3 color0 = vec3(0,0,0);// black
vec3 color1 = vec3(1,1,1);// white
vec3 color2 = vec3(0.41,0.22,0.17);// red
vec3 color3 = vec3(0.44,0.64,0.70);// cyan
vec3 color4 = vec3(0.44,0.24,0.53);// violet
vec3 color5 = vec3(0.35,0.55,0.26);// green
vec3 color6 = vec3(0.21,0.16,0.47);// blue
vec3 color7 = vec3(0.72,0.78,0.44);// yellow
vec3 color8 = vec3(0.44,0.31,0.15);// orange
vec3 color9 = vec3(0.26,0.22,0);// brown
vec3 colorA = vec3(0.60,0.40,0.35);// light red
vec3 colorB = vec3(0.27,0.27,0.27);// grey1
vec3 colorC = vec3(0.42,0.42,0.42);// grey2
vec3 colorD = vec3(0.60,0.82,0.52);// light green
vec3 colorE = vec3(0.42,0.37,0.71);// light blue
vec3 colorF = vec3(0.58,0.58,0.58);// grey3


//----------------------------------------------------------------------

void getRasterColor( out vec4 o, vec2 i)
{
		i.y -= iGlobalTime*animationSpeed;

    vec2 pVirt = floor(i / pixelSize);// pixel coords in simulated screen space.
    vec2 virtRes = floor(iResolution.xy / pixelSize);
    vec2 uv = pVirt / virtRes;

    float linPixel = pVirt.x + (pVirt.y * virtRes.x);
    float bandWidth = virtRes.x * idealColorChangeWidth;// with no glitches, color bands span X% of the screen.
    linPixel -= (hash(pVirt.y)*2.-1.)*virtRes.x*fixedPerturbanceAmt;// perturb by Y up to X% of screen width
    linPixel -= (hash(iGlobalTime)*2.-1.)*virtRes.x*animatedPerturbanceAmt;// perturb by time up to X% of screen width
    //linPixel += virtRes.x *floor(iGlobalTime*animationSpeed);// animate by shifting whole scan lines
    float band = linPixel / bandWidth;
    
    // select which gradient to show
    if(mod(iGlobalTime, 3.) < 2.)
    {
    	o = texture2D(tenfourGradientTexture, vec2(0, band/16.));
    }
    else
    {
    	o = texture2D(dumbGradientTexture, vec2(0, band/16.));
    }
}











void band(inout vec3 o, vec2 uv, float y, vec3 c)
{
    y -= .3;
    float fft = .5 + iFFT / 2.;

    //float ext = y + tri_gear(uv.x + (iGlobalTime * .5) - (iFFT * 1.), 0.2, 1.-fft, fft);
    float ext = y + .5;

    float amt = 400.-(1000.0*pow(iFFT, 0.5));
    amt = clamp(amt, 10., 400.);
    amt = 900.;
    o.rgb = mix(o.rgb, c, dtoa(uv.y - ext, amt));
}

float sdSegment1D(float uv, float a, float b)
{
    return max(max(a - uv, 0.), uv - b);
}
float sdAxisAlignedRect(vec2 uv, vec2 tl, vec2 br)
{
    float dx = sdSegment1D(uv.x,tl.x,br.x);
    float dy = sdSegment1D(uv.y,tl.y,br.y);
    return dx + dy;// manhattan
    //return sqrt(dx*dx+dy*dy);// euclidian version
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



	vec4 o = vec4(color6,1);
  band(o.rgb, uv, .8, vec3(0,0,0));

 	band(o.rgb, uv, .75, color8);// vec3(1,.5,0)
 	
 	if(uv.y < .8 && uv.y > .34)
 	{
	  vec4 rasterColor = vec4(1);
  	getRasterColor(rasterColor, uvPix);
  	o = rasterColor;
	 	//band(o.rgb, uv, .62, rasterColor.rgb);
 	}
 	//band(o.rgb, uv, .62, color5);

 	band(o.rgb, uv, .34, vec3(0));

  // slash
  vec3 grayColor = vec3(.5,.5,.5);
  //grayColor = rasterColor.rgb;

  slash_color(grayColor, uv, -.8, -.54, vec3(.2,.2,.2));
  slash_color(grayColor, uv, -.55, -.5, vec3(.0,.0,.0));

  blit(grayColor, uv, vec2(-.2,-.715), vec2(2.,1.55), uvPix);// KICK

  band(o.rgb, uv, .3, grayColor);

  band(o.rgb, uv, -.69, vec3(0,0,0));
  
  // if(uv.y < -.69 && uv.y > -.73)
  // {
	 //  vec4 rasterColor = vec4(1);
  // 	getRasterColor(rasterColor, uvPix);
	 //  band(o.rgb, uv, -.73, rasterColor.rgb);
  // }
  //band(o.rgb, uv, -.73, colorC);
  
  band(o.rgb, uv, -.8, vec3(1,1,1));

  // POST PROCESSING
	vec2 uvn = gl_FragCoord.xy / iResolution.xy - .5;
	uvn *= 2.;

  // if(uvn.x < -0.95 || uvn.x > 0.95)
  // 	o = rasterColor;
  // if(uvn.y < -0.95 || uvn.y > 0.95)
  // 	o = rasterColor;

  o.rgb *=1.-(rand(uvPix+iGlobalTime))*.15;
  //o.rgb = pow(o.rgb, vec3(1./1.9));// gamma
  //o.rgb *= 1.-dot(uvn*.5, uvn*.5);// vignette

  // fade-in
  o.rgb *= smoothstep(0., 3.0, iGlobalTime);

  gl_FragColor = vec4(o.rgb, 1.);
}



