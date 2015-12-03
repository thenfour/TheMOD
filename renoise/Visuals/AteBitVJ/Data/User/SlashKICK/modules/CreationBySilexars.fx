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













// #define t iGlobalTime
// #define r iResolution.xy

// void mainImage( out vec4 fragColor, in vec2 fragCoord ){
//     vec3 c;
//     float l,z=t;
//     for(int i=0;i<3;i++) {
//         vec2 uv,p=fragCoord.xy/r;
//         uv=p;
//         p-=.5;
//         p.x*=r.x/r.y;
//         z+=.07;
//         l=length(p);
//         uv+=p/l*(sin(z)+1.)*abs(sin(l*9.-z*2.));
//         c[i]=.01/length(abs(mod(uv,1.)-.5));
//     }
//     fragColor=vec4(c/l,t);
// }







// From https://www.shadertoy.com/view/XsXXDn

#define t (iGlobalTime*g_fFloat3)
#define r iResolution.xy
#define m iMouse.xy

//#define PI 3.14159265359

/**
 * Interpolate (cos) between 'min' and 'max' with a defined 'period'
 */
float stepper(float time, float period, float min, float max)
{
    return cos(mod(time, period) / period * 2. * PI) * (max - min) / 2. + (max + min) / 2.;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    /* position */
    vec2 p = fragCoord.xy/r - .5;
    p.x*= r.x/r.y;
    p = abs(p);
    
	float l = length(p);
    
    
    /* cycling values */
    // color shift
    float dz = stepper(t, 10.9, -.1, .1);
    // size
    float ds = stepper(t, 15.4, -2., 2.);
    // pattern
    float dp = stepper(t, 20.6, 5., 10.);
    // intensity
    float di = stepper(t, 8.2, .008, .06);
    // direction
    float dd = stepper(t, 12.1, -.03, .03);
    // attenuation
    float dl = stepper(t, 19.3, l, 1./l);
    
    /* original values */
    //dz = .07;
	//ds = 1.;
    //dp = 9.;
    //di = .01;
    //dd = 2.;
    //dl = 1./l;
    
    
    /* compute colors */
    vec3 c;
    float z = t;
    
	for (int i=0; i<3; i++)
    {
		z+= dz;
        float a = (sin(z)+ds) * abs(sin(l*dp - z*dd));
		vec2 uv = fragCoord.xy/r + p / l * a;
		c[i] = di / length(abs(mod(uv, 1.) - .5));
	}
    
	fragColor = vec4(c*dl, t);
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

