#pragma pack_matrix( column_major )
#define NO_DEFAULT_PIXEL_SHADER_INPUT
#define NO_DEFAULT_VERTEX_SHADER
#include "System/Modules/user_shader_defines.fxh"


// globals / constants need 'static'
// some keywords will be reserved. for example if you make your own saturate() function.
// vec2(1) is not valid in hlsl so i made new constructors. use vvec2() / vvec3() / etc.
// HLSL cannot use operator * between float2x2 and float2. (mat * uv) is mul(mat,uv).

#pragma pack_matrix( column_major )

#define vec2 float2  
#define vec3 float3  
#define vec4 float4  
#define mat2 float2x2
#define mod fmod // <-- NOTE: these are not *exactly* the same between hlsl & glsl
#define mix lerp  
#define atan atan2  
#define fract frac
#define texture2D tex2D

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
    
    vecTex += .5; // shift origin to bottom-left
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
static float4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
// uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
static float4 iDate;// uniform vec4      iDate;                 // (year, month, day, time in seconds)
// uniform float     iSampleRate;           // sound sample rate (i.e., 44100)



// forward declaration
void mainImage( out vec4 fragColor, in vec2 fragCoord );



//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
  iMouse = float4(0.,0.,0.,0.);
    iDate = vec4(2015, 11, 1, g_fSeconds);// totally fake obv.
    iGlobalTime = g_fSeconds;
    iResolution = inp.iResolution;

    float4 fragColor = vec4(0,0,0,0);// output

    mainImage(fragColor, inp.vecTex);

    return vec4(fragColor.rgb, 1.0);
}

