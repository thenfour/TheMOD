#define vec2 float2  
#define vec3 float3  
#define vec4 float4  
#define mat2 float2x2
#define mod fmod // <-- these are not exactly the same between hlsl & glsl
#define mix lerp  
#define atan atan2  
#define fract frac   
#define texture2D tex2D  
#define PI2 6.28318530718  
#define PI 3.14159265358979  
#define halfpi (pi * 0.5)  
#define oneoverpi (1.0 / pi)  
#define iGlobalTime (g_fTime / 2.5)
#define iResolution (float3(1,1,1))
#define fragCoord (input.vecTex)

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
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
};


//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT input )
{
    PS_INPUT output;
    output.vecTex = input.vecTex;
    output.vecPos = float4((2 * (input.vecTex - 0.5)) * float2(1, g_fAspect), 0, 1);
    return output;
}

