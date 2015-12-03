//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
Texture2D texSrc : register(t0);
Texture2D tex1 : register(t1);
Texture2D texFFT : register(t2);
SamplerState sampSrc : register(s0);
SamplerState samp1 : register(s1);
SamplerState sampFFT : register(s2);

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
    float g_fSeconds;
    float psPad1;
    float psPad2;
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
    float2 uvn : TEXCOORD1;
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT inp )
{
    PS_INPUT outp;
    float2 vecTex = (inp.vecTex-.5)*2.;
    outp.vecPos = float4(vecTex*2., 0, 1);
    
    outp.uvn = vecTex*2.;

    vecTex -= .5;
    vecTex.y = -vecTex.y;
    //vecTex /= 2.;
    //vecTex *= float2(g_fAspect, 1.);// aspect-correct
    outp.uv = vecTex;

    return outp;
}


float rand(float2 co){
  return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    float4 o = texSrc.Sample(sampSrc, inp.uv);

    o.rgb*=1-(rand(inp.uv+g_fFloat2)*.25);

    o.rgb *= 1.-dot(inp.uvn*.8, inp.uvn*.8);

    return o;
}
