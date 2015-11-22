// global constants need 'static'. Maybe even #define.

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
#define pi2 6.28318530718  
#define pi 3.14159265358979
#define halfpi (pi * 0.5)  
#define oneoverpi (1.0 / pi)  
#define iGlobalTime (g_fTime)

// we don't actually have the real dimensions, so we have to just pick something "biggish"
#define ViewportDimension 180
#define iResolution (ViewportDimension * float3(g_fAspect, 1., 1.))

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
    float aspect : PSIZE;
};


//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT inp)
{
    PS_INPUT outp;
    float2 vecTex = (inp.vecTex-.5)*2.;
    outp.vecPos = float4(vecTex*2., 0, 1);
    
    vecTex += .5; // shift origin to bottom-left
    //vecTex *= 2.;// double viewport bounds (scale)
    outp.vecTex = vecTex * iResolution.xy;// correct aspect and scale up to simulate pixels
    outp.aspect = g_fAspect;
    return outp;
}



//--------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // how to access g_fAspect in here?
    fragColor = vec4(1,1,1,1);
}







//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    float g_fAspect = inp.aspect;
    float4 fragColor = vec4(0,0,0,0);// output

    //------ begin GLSL --------------------------
    mainImage(fragColor, inp.vecTex);

    // vec2 uv = fragCoord / iResolution.xy - 0.5;// the -.5 is not needed because it goes up in the VS
    // uv.x *= iResolution.x / iResolution.y;// aspect correction also done in the VS

    // o = vec4(0., sin(length(uv)/PI2)/2.+.5, 1., 1.);

    // if(length(uv) < 25.) o = vec4(1,0,0,1);
    // if(length(uv) < 1.0) o = vec4(1,0,1,1);
    // if(length(uv) < .5) o = vec4(1,1,0,1);
    // if(uv.x < 0.) o.rgb *= .3;
    // if(uv.y < 0.) o.rgb *= .3;

    //------ end GLSL --------------------------
    return vec4(fragColor.rgb, 1.0);
}

