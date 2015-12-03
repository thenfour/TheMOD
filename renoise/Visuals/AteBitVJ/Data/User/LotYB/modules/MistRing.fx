// https://www.shadertoy.com/view/XsXXDn


// globals / constants need 'static'
// some keywords will be reserved. for example if you make your own saturate() function.
// vec2(1) is not valid in hlsl so i made new constructors. use vvec2() / vvec3() / etc.
// HLSL cannot use operator * between float2x2 and float2. (mat * uv) is mul(mat,uv).


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

    outp.iResolution = float3(500. * float2(g_fAspect, 1.),0);
    outp.vecTex = vecTex * outp.iResolution.xy;// correct aspect and scale up to simulate pixels
    return outp;
}



//--------------------------------------------------------------------------------------
// simulate shadertoy vars:
static float3 iResolution;// uniform vec3      iResolution;           // viewport resolution (in pixels)
static float iGlobalTime;// uniform float     iGlobalTime;           // shader playback time (in seconds)
// uniform float     iChannelTime[4];       // channel playback time (in seconds)
// uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
// uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
// uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
static float4 iDate;// uniform vec4      iDate;                 // (year, month, day, time in seconds)
// uniform float     iSampleRate;           // sound sample rate (i.e., 44100)



































float hash( float n )
{
    return frac(sin(n)*43758.5453);
}
float noise( in float2 x )
{
    float2 p = floor(x);
    float2 f = frac(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0;

    float res = lerp(lerp( hash(n+  0.0), hash(n+  1.0),f.x),
                    lerp( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
    return res;
}
float fbm(float2 p){
    float f = 0.;
    float2x2 m = float2x2( 0.8,  -0.6, 0.6,  0.8 );
    f +=0.50000*abs(noise(p)-1.)*2.;p=mul(p, m*2.02);
    f +=0.25000*abs(noise(p)-1.)*2.;p=mul(p, m*2.03);
    f +=0.12500*abs(noise(p)-1.)*2.;p=mul(p, m*2.01);
    f +=0.06250*abs(noise(p)-1.)*2.;p=mul(p, m*2.04);
    f +=0.03125*abs(noise(p)-1.)*2.;
    return f/0.96875;
}
void mainImage( out float4 fragColor, in float2 fragCoord )
{
  float2 q = fragCoord.xy / iResolution.xy;
    float2 p = 2.*q-1.0;
    float r = length(p);
    p.x *= iResolution.x/iResolution.y;
    float f = fbm(p+fmod(g_fTime*.4,100.));
    f *= r*3.-0.5;
    f = (1.-f);
    float3 col = float3(0.2,0.3,0.5)/f;
  fragColor = float4(sqrt(abs(col))*0.5,1.0);
}

















//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    iDate = float4(2015, 11, 1, g_fTime);// totally fake obv.
    iGlobalTime = g_fTime;
    iResolution = inp.iResolution;

    float4 fragColor = float4(0,0,0,0);// output

    mainImage(fragColor, inp.vecTex);

    return float4(fragColor.rgb, 1.0);
}

