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












// Blobs by @paulofalcao
float fft(float x)
{
    return texFFT.Sample(sampFFT, float2(x,0)).r;
}

#define time (iGlobalTime*0.2)

float makePoint(float x,float y,float fx,float fy,float sx,float sy,float t){

   float xx=x+sin(t*fx)*sx*(1.+fft(0.1)*.5);
   float yy=y+cos(t*fy)*sy*(1.+fft(0.1)*.5);
   return 1.0/sqrt(xx*xx+yy*yy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

   vec2 p=fragCoord.xy/iResolution.x-.5;//*2.0-vec2(1.0,iResolution.y/iResolution.x);
   p=p*2.0;
   p.y += .5;
   
   float x=p.x;
   float y=p.y;

   float a=
       makePoint(x,y,3.3,2.9,0.3,0.3,time);
   a=a+makePoint(x,y,1.9,2.0,0.4,0.4,time);
   a=a+makePoint(x,y,0.8,0.7,0.4,0.5,time);
   a=a+makePoint(x,y,2.3,0.1,0.6,0.3,time);
   a=a+makePoint(x,y,0.8,1.7,0.5,0.4,time);
   a=a+makePoint(x,y,0.3,1.0,0.4,0.4,time);
   a=a+makePoint(x,y,1.4,1.7,0.4,0.5,time);
   a=a+makePoint(x,y,1.3,2.1,0.6,0.3,time);
   a=a+makePoint(x,y,1.8,1.7,0.5,0.4,time);   
   
   float b=
       makePoint(x,y,1.2,1.9,0.3,0.3,time);
   b=b+makePoint(x,y,0.7,2.7,0.4,0.4,time);
   b=b+makePoint(x,y,1.4,0.6,0.4,0.5,time);
   b=b+makePoint(x,y,2.6,0.4,0.6,0.3,time);
   b=b+makePoint(x,y,0.7,1.4,0.5,0.4,time);
   b=b+makePoint(x,y,0.7,1.7,0.4,0.4,time);
   b=b+makePoint(x,y,0.8,0.5,0.4,0.5,time);
   b=b+makePoint(x,y,1.4,0.9,0.6,0.3,time);
   b=b+makePoint(x,y,0.7,1.3,0.5,0.4,time);

   float c=
       makePoint(x,y,3.7,0.3,0.3,0.3,time);
   c=c+makePoint(x,y,1.9,1.3,0.4,0.4,time);
   c=c+makePoint(x,y,0.8,0.9,0.4,0.5,time);
   c=c+makePoint(x,y,1.2,1.7,0.6,0.3,time);
   c=c+makePoint(x,y,0.3,0.6,0.5,0.4,time);
   c=c+makePoint(x,y,0.3,0.3,0.4,0.4,time);
   c=c+makePoint(x,y,1.4,0.8,0.4,0.5,time);
   c=c+makePoint(x,y,0.2,0.6,0.6,0.3,time);
   c=c+makePoint(x,y,1.3,0.5,0.5,0.4,time);
   
   vec3 d=vec3(a,b,c)/32.0;
   
   fragColor = vec4(d.x,d.z,d.y,1.0);
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

