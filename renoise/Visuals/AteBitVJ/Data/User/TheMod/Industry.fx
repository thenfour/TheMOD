// https://www.shadertoy.com/view/XsXXDn


// globals / constants need 'static'
// some keywords will be reserved. for example if you make your own saturate() function.
// vec2(1) is not valid in hlsl so i made new constructors. use vvec2() / vvec3() / etc.
// HLSL cannot use operator * between float2x2 and float2. (mat * uv) is mul(mat,uv).
#pragma pack_matrix( column_major )
#define vec2 float2  
#define vec3 float3  
#define vec4 float4  
#define mat2 float2x2
#define mod fmod // <-- these are not *exactly* the same between hlsl & glsl
#define mix lerp  
#define atan atan2  
#define fract frac
#define texture2D tex2D

#define PI2 6.28318530718  
#define PI 3.14159265358979
#define pi2 6.28318530718
#define pi 3.14159265358979
#define halfpi (pi * 0.5)  
#define oneoverpi (1.0 / pi)

// replacement constructors
float2 vvec2(float a, float b){ return float2(a, b); }
float2 vvec2(float a, int b){ return float2(a, b); }
float2 vvec2(int a, float b){ return float2(a, b); }
float2 vvec2(int a, int b){ return float2(a, b); }
float2 vvec2(int a){ return float2(a, a); }
float2 vvec2(float a){ return float2(a, a); }

float3 vvec3(int a) { return float3(a,a,a); }
float3 vvec3(float a) { return float3(a,a,a); }
float3 vvec3(float2 a, float b) { return float3(a,b); }
float3 vvec3(float2 a, int b) { return float3(a,b); }
float3 vvec3(int2 a, float b) { return float3(a,b); }
float3 vvec3(int2 a, int b) { return float3(a,b); }
float3 vvec3(int a, int b, int c) { return float3(a,b,c); }
float3 vvec3(int a, int b, float c) { return float3(a,b,c); }
float3 vvec3(int a, float b, int c) { return float3(a,b,c); }
float3 vvec3(int a, float b, float c) { return float3(a,b,c); }
float3 vvec3(float a, int b, int c) { return float3(a,b,c); }
float3 vvec3(float a, int b, float c) { return float3(a,b,c); }
float3 vvec3(float a, float b, int c) { return float3(a,b,c); }
float3 vvec3(float a, float b, float c) { return float3(a,b,c); }


//--------------------------------------------------------------------------------------
Texture2D tex1 : register(t0);
Texture2D tex2 : register(t1);
Texture2D tex3 : register(t2);
Texture2D texFFT : register(t3);
SamplerState samp1 : register(s0);
SamplerState samp2 : register(s1);
SamplerState samp3 : register(s2);
SamplerState sampFFT : register(s3);

cbuffer ConstantBuffer : register(b0)
{
    float g_fPosX, g_fPosY;
    float g_fRotation;
    float g_fScale;
    float g_fAspect;
    float cbpad1, cbpad2, cbpad3;
};

cbuffer PSBuffer : register(b1)
{
    float4 g_vecColour1;
    float4 g_vecColour2;
    float4 g_vecColour3;
    float g_fFloat1;
    float g_fFloat2;
    float g_fFloat3;
    float g_fBeats;
    float g_fBars;
    float g_fTime;
    float g_fSecondsVisible;
    float g_fSecondsActive;
};

//--------------------------------------------------------------------------------------
struct VS_INPUT
{
    float2 vecPos : POSITION;
    float2 vecTex : TEXCOORD0;
};

struct PS_INPUT
{
    float4 vecPos : SV_POSITION;
    float2 vecTex : TEXCOORD0;

    float3 iResolution : TEXCOORD1;
    //float vol : PSIZE;
};


//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT inp)
{
    PS_INPUT outp;
    float2 vecTex = (inp.vecTex-.5)*2.;
    outp.vecPos = float4(vecTex*2., 0, 1);
    
    vecTex += .5; // shift origin to bottom-left; shadertoy compatibility
    //vecTex *= 2.;// double viewport bounds (scale)

    outp.iResolution = vec3(100. * vec2(g_fAspect, 1.),0);
    outp.vecTex = vecTex * outp.iResolution.xy;// correct aspect and scale up to simulate pixels
    return outp;
}



//--------------------------------------------------------------------------------------
// simulate shadertoy vars:
static vec3 iResolution;// uniform vec3      iResolution;           // viewport resolution (in pixels)
static float iGlobalTime;// uniform float     iGlobalTime;           // shader playback time (in seconds)
// uniform float     iChannelTime[4];       // channel playback time (in seconds)
// uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
// uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
// uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
static float4 iDate;// uniform vec4      iDate;                 // (year, month, day, time in seconds)
// uniform float     iSampleRate;           // sound sample rate (i.e., 44100)





































// by srtuss, 2013
// a little expression of my love for complex machines and stuff
// was going for some cartoonish 2d look
// still could need some optimisation

// * improved gears
// * improved camera movement

float hash(float x)
{
  return fract(sin(x) * 43758.5453);
}

vec2 hash(vec2 p)
{
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
  return fract(sin(p) * 43758.5453);
}

// simulates a resonant lowpass filter
float mechstep(float x, float f, float r)
{
  float fr = fract(x);
  float fl = floor(x);
  return fl + pow(fr, 0.5) + sin(fr * f) * exp(-fr * 3.5) * r;
}

// voronoi cell id noise
vec3 voronoi(in vec2 x)
{
  vec2 n = floor(x);
  vec2 f = fract(x);

  vec2 mg, mr;
  
  float md = 8.0;
  for(int j = -1; j <= 1; j ++)
  {
    for(int i = -1; i <= 1; i ++)
    {
      vec2 g = vec2(float(i),float(j));
      vec2 o = hash(n + g);
      vec2 r = g + o - f;
      float d = max(abs(r.x), abs(r.y));
      
      if(d < md)
      {
        md = d;
        mr = r;
        mg = g;
      }
    }
  }
  
  return vvec3(n + mg, mr);
}

vec2 rotate(vec2 p, float a)
{
  return vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
}

float stepfunc(float a)
{
  return step(a, 0.0);
}

float fan(vec2 p, vec2 at, float ang)
{
  p -= at;
  p *= 3.0;
  
  float v = 0.0, w, a;
  float le = length(p);
  
  v = le - 1.0;
  
  if(v > 0.0)
    return 0.0;
  
  a = sin(atan(p.y, p.x) * 3.0 + ang);
  
  w = le - 0.05;
  v = max(v, -(w + a * 0.8));
  
  w = le - 0.15;
  v = max(v, -w);
  
  return stepfunc(v);
}

float gear(vec2 p, vec2 at, float teeth, float size, float ang)
{
  p -= at;
  float v = 0.0, w;
  float le = length(p);
  
  w = le - 0.3 * size;
  v = w;
  
  w = sin(atan(p.y, p.x) * teeth + ang);
  w = smoothstep(-0.7, 0.7, w) * 0.1;
  v = min(v, v - w);
  
  w = le - 0.05;
  v = max(v, -w);
  
  return stepfunc(v);
}

float car(vec2 p, vec2 at)
{
  p -= at;
  float v = 0.0, w;
  w = length(p + vec2(-0.05, -0.31)) - 0.03;
  v = w;
  w = length(p + vec2(0.05, -0.31)) - 0.03;
  v = min(v, w);
  
  vec2 box = abs(p + vec2(0.0, -0.3 - 0.07));
  w = max(box.x - 0.1, box.y - 0.05);
  v = min(v, w);
  return stepfunc(v);
}

float layerA(vec2 p, float seed)
{
  float v = 0.0, w, a;
  
  float si = floor(p.y);
  float sr = hash(si + seed * 149.91);
  vec2 sp = vec2(p.x, mod(p.y, 4.0));
  float strut = 0.0;
  strut += step(abs(sp.y), 0.3);
  strut += step(abs(sp.y - 0.2), 0.1);
  
  float st = iGlobalTime + sr;
  float ct = mod(st * 3.0, 5.0 + sr) - 2.5;
  
  v = step(2.0, abs(voronoi(p + vec2(0.35, seed * 194.9)).x));
  
  w = length(sp - vec2(-2.0, 0.0)) - 0.8;
  v = min(v, 1.0 - step(w, 0.0));
  
  
  a = st;
  w = fan(sp, vec2(2.5, 0.65), a * 40.0);
  v = min(v, 1.0 - w);
  
  
  return v;
}

float layerB(vec2 p, float seed)
{
  float v = 0.0, w, a;
  
  float si = floor(p.y / 3.0) * 3.0;
  vec2 sp = vec2(p.x, mod(p.y, 3.0));
  float sr = hash(si + seed * 149.91);
  sp.y -= sr * 2.0;
  
  float strut = 0.0;
  strut += step(abs(sp.y), 0.3);
  strut += step(abs(sp.y - 0.2), 0.1);
  
  float st = iGlobalTime + sr;
  
  float cs = 2.0;
  if(hash(sr) > 0.5)
    cs *= -1.0;
  float ct = mod(st * cs, 5.0 + sr) - 2.5;

  
  v = step(2.0, abs(voronoi(p + vec2(0.35, seed * 194.9)).x) + strut);
  
  w = length(sp - vec2(-2.3, 0.6)) - 0.15;
  v = min(v, 1.0 - step(w, 0.0));
  w = length(sp - vec2(2.3, 0.6)) - 0.15;
  v = min(v, 1.0 - step(w, 0.0));
  
  if(v > 0.0)
    return 1.0;
  
  
  w = car(sp, vec2(ct, 0.0));
  v = w;
  
  if(hash(si + 81.0) > 0.5)
    a = mechstep(st * 2.0, 20.0, 0.4) * 3.0;
  else
    a = st * (sr - 0.5) * 30.0;
  w = gear(sp, vec2(-2.0 + 4.0 * sr, 0.5), 8.0, 1.0, a);
  v = max(v, w);
  
  w = gear(sp, vec2(-2.0 + 0.65 + 4.0 * sr, 0.35), 7.0, 0.8, -a);
  v = max(v, w);
  if(hash(si - 105.13) > 0.8)
  {
    w = gear(sp, vec2(-2.0 + 0.65 + 4.0 * sr, 0.35), 7.0, 0.8, -a);
    v = max(v, w);
  }
  if(hash(si + 77.29) > 0.8)
  {
    w = gear(sp, vec2(-2.0 - 0.55 + 4.0 * sr, 0.30), 5.0, 0.5, -a + 0.7);
    v = max(v, w);
  }
  
  return v;
}

float fft(float x)
{
    return texFFT.Sample(sampFFT, float2(x,0)).r;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = fragCoord.xy / iResolution.xy;
  uv = uv * 2.0 - 1.0;
  vec2 p = uv * lerp(1.2,.95,fft(.05));
  p.x *= iResolution.x / iResolution.y;
  
  float t = iGlobalTime;
  
  vec2 cam = vec2(sin(t) * 0.2, t);
  
  // for future use
  /*float quake = exp(-fract(t) * 5.0) * 0.5;
  if(quake > 0.001)
  {
    cam.x += (hash(t) - 0.5) * quake;
    cam.y += (hash(t - 118.29) - 0.5) * quake;
  }*/
  
  p = rotate(p, sin(t) * 0.02);
  
  vec2 o = vec2(0.0, t);
  float v = 0.0, w;
  
  
  float z = 3.0 - sin(t * 0.7) * 0.1;
  for(int i = 0; i < 5; i ++)
  {
    float f = 1.0;
    
    float zz = 0.3 + z;
    
    f = zz * 2.0 * 0.9;
    
    
    if(i == 3 || i == 1)
      w = layerA(vec2(p.x, p.y) * f + cam, float(i));
    else
      w = layerB(vec2(p.x, p.y) * f + cam, float(i));
    v = mix(v, exp(-abs(zz) * 0.3 + 0.1), w);
    
    
    z -= 0.6;
  }
  
  
  
  
  v = 1.0 - v;// * pow(1.0 - abs(uv.x), 0.1);
  
  fragColor = vec4(v, v, v, 1.0);
}



















//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    iDate = vec4(2015, 11, 1, g_fTime);// totally fake obv.
    iGlobalTime = g_fTime;
    iResolution = inp.iResolution;

    float4 fragColor = vec4(0,0,0,0);// output

    mainImage(fragColor, inp.vecTex);

    return vec4(fragColor.rgb, 1.0);
}

