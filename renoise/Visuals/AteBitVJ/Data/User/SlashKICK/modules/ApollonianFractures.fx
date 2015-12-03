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




































/*--------------------------------------------------------------------------------------
License CC0 - http://creativecommons.org/publicdomain/zero/1.0/
To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.
----------------------------------------------------------------------------------------
^ This means do ANYTHING YOU WANT with this code. Because we are programmers, not lawyers.
-Otavio Good
*/

// noise functions
vec2 noise2dTex2(vec2 p)
{
  p *= 140.;
  p = vec2( dot(p,vec2(127.1,311.7)),
        dot(p,vec2(269.5,183.3)) );
  return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}


// float Hash2d(vec2 uv)
// {
//     float f = uv.x + uv.y * 37.0;
//     return fract(sin(f)*104003.9);
// }
// float mixP(float f0, float f1, float a)
// {
//     return mix(f0, f1, a*a*(3.0-2.0*a));
// }
// static const vec2 zeroOne = vec2(0.0, 1.0);
// float noise2d(vec2 uv)
// {
//     vec2 fr = fract(uv.xy);
//     vec2 fl = floor(uv.xy);
//     float h00 = Hash2d(fl);
//     float h10 = Hash2d(fl + zeroOne.yx);
//     float h01 = Hash2d(fl + zeroOne);
//     float h11 = Hash2d(fl + zeroOne.yy);
//     return mixP(mixP(h00, h10, fr.x), mixP(h01, h11, fr.x), fr.y);
// }


static const float speed = .17;
float Fractal(vec2 p)
{
    vec2 pr = p;
    float scale = 1.0;
    float iter = 1.0;
    for (int i = 0; i < 12; i++)
    {
        vec2 n2 = noise2dTex2(p*0.15*iter+iGlobalTime*speed)*(0.5+pow(g_fFloat1,.2));
        float nx = n2.x - 0.5;
        float ny = n2.y;
        pr += vec2(nx, ny)*0.0002*iter*iter*iter;
        pr = fract(pr*0.5+0.5)*2.0 - 1.0;
        float len = pow(dot(pr, pr), 1.0+nx*0.5);
        float inv = 1.1/len;
        pr *= inv;
        scale *= inv;
        iter += 1.0;
    }
    float b = abs(pr.x)*abs(pr.y)/scale;
    return pow(b, 0.125)*0.95;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //float xPerturb = pow(g_fFloat1, .4)/10.;
    // center and scale the UV coordinates
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x / iResolution.y;
    uv *= 0.74;
    uv.y += iGlobalTime*.07;

    // do the magic
    //uv.x += xPerturb;
    vec2 warp = normalize(uv) * (1.0-pow(length(uv), 0.45));
    vec3 finalColor = vec3(Fractal(uv*2.0+1.0),
                           Fractal(uv*2.0+37.0),
                           Fractal((warp+0.5)*2.0+15.0));
    finalColor = 1.0 - finalColor;

    // do it again.
    // uv.x -= xPerturb * 2.;
    // vec2 warp2 = normalize(uv) * (1.0-pow(length(uv), 0.45));
    // vec3 finalColor2 = vec3(Fractal(uv*2.0+1.0),
    //                        Fractal(uv*2.0+37.0),
    //                        Fractal((warp2+0.5)*2.0+15.0));
    // finalColor2 = 1.0 - finalColor2;

    // mix.
    //finalColor = lerp(finalColor, finalColor2, .5);



    //float circle = 1.0-length(uv*2.2);
    //float at = atan(uv.x, uv.y);
    //float aNoise = noise2d(vec2(at * 30.0, iGlobalTime));
    //aNoise = aNoise * 0.5 + 0.5;
    //finalColor *= pow(max(0.0, circle), 0.1)*2.0; // comment out this line to see the whole fractal.
    //finalColor *= 1.0 + pow(1.0 - abs(circle), 30.0); // colorful outer glow
    //finalColor += vec3(1.0, 0.3, 0.03)*3.0 * pow(1.0 - abs(circle), 100.0);  // outer circle
    //float outer = (1.0 - pow(max(0.0, circle), 0.1)*2.0);
    //finalColor += vec3(1.,0.2,0.03)*0.4* max(0.0, outer*(1.0-length(uv)));

    fragColor = vec4(finalColor, 1.0);
}



















//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    iDate = vec4(2015, 11, 1, g_fTime);// totally fake obv.
    iGlobalTime = g_fTime;
    iResolution = inp.iResolution;

    float4 fragColor = vec4(0,0,0,0);// output

    mainImage(fragColor, inp.vecTex);

    fragColor.rgb=lerp((fragColor.r+fragColor.g+fragColor.b)/3., fragColor.rgb,g_fFloat2 + pow(g_fFloat1,2.));// saturation

    return vec4(fragColor.rgb, 1.0);
}

