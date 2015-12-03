Texture2D tex1 : register(t0);
Texture2D tex2 : register(t1);
Texture2D tex3 : register(t2);
Texture2D texFFT : register(t3);
SamplerState samp1 : register(s0);
SamplerState samp2 : register(s1);
SamplerState samp3 : register(s2);
SamplerState sampFFT : register(s3);

static const float pi = 3.1415926535;
static const float pi2 = pi * 2.;

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
    float2 uv : TEXCOORD0;
    float2 uvn : TEXCOORD1;// not aspect-correct
};


//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT inp)
{
    PS_INPUT outp;
    float2 vecTex = (inp.vecTex-.5)*2.;
    outp.vecPos = float4(vecTex*2., 0, 1);
    
    //vecTex += .5; // shift origin to bottom-left; shadertoy compatibility
    vecTex *= 2.;// double viewport bounds (scale)
    outp.uvn = vecTex;
    vecTex *= float2(g_fAspect, 1.);// aspect-correct

    outp.uv = vecTex;
    return outp;
}

// i is 0-1
float pixellate(float i, float sz)
{
    return floor(i / sz) * sz;
}

float rand(float2 co)
{
  return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

// https://www.shadertoy.com/view/ll2GD3
float3 pal2( in float t, in float3 a, in float3 b, in float3 c, in float3 d )
{
    return a + b*cos( pi2*(c*t+d) );
}

float3 pal(float t, float t2)
{
    float3 c1 = pal2(t, float3(0.8,0.5,0.4),float3(0.2,0.4,0.2),float3(2.0,1.0,1.0),float3(0.0,0.25,0.25) );
    float3 c2 = pal2(t, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.0,0.33,0.67) );
    float3 c3 = pal2(t, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.0,0.10,0.20) );
    float3 c4 = pal2(t, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.3,0.20,0.20) );
    return pal2(t2, c1, c2, c3, c4);

    //c = pal(v, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,0.5),float3(0.8,0.90,0.30) );
    //c = pal(v, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,0.7,0.4),float3(0.0,0.15,0.20) );
    //c = pal(v, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(2.0,1.0,0.0),float3(0.5,0.20,0.25) );
}

float3 czm_saturation(float3 rgb, float adjustment)
{
    // Algorithm from Chapter 16 of OpenGL Shading Language
    const float3 W = float3(0.2125, 0.7154, 0.0721);
    float3 intensity = dot(rgb, W);
    return lerp(intensity, rgb, adjustment);
}

//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    float2 uv = inp.uv;// -1 to 1, centered
    float fft = pow(g_fFloat1, 1.7);

    float bandWidth = 0.333;
    float vx;
    float3 cx;

    // pixellate using constant band width to get some random value.
    vx = abs(frac(pixellate(uv.x + fft + g_fTime * 0.2, bandWidth)));
    vx = rand(vx * vx);
    vx = abs(frac(pixellate(uv.x + g_fTime * 0.1, vx)));// pixellate again, using that value as band width
    cx = pal(vx, uv.y);// and convert to color.
    cx = pow(cx, .3);

    float vy, cy;
    // pixellate using constant band width to get some random value.
    vy = abs(frac(pixellate(uv.y + fft + g_fTime * 0.2, bandWidth)));
    vy = rand(vy * vy);
    vy = abs(frac(pixellate(uv.y - g_fTime * 0.1, vy)));// pixellate again, using that value as band width
    cy = pal(vy, uv.x);// and convert to color.
    cy = pow(cy, .3);

    //float4 o = float4(cx,1);
    float4 o = float4(cx * cy,1);

    o.rgb= czm_saturation(o.rgb, g_fFloat2);
    o.rgb *= lerp(1.0, g_vecColour1.rgb, g_vecColour1.a);
    //float4 o = float4(lerp(cx, cy, .5),1);

    // vignette
    //float vignetteAmt = 1.-dot(inp.uvn * .85,inp.uvn * .85);
    //o.rgb *= vignetteAmt;
    return o;
}

