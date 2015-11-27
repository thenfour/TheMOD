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
    
    outp.uvn = vecTex;
    vecTex *= float2(g_fAspect, 1.);// aspect-correct

    outp.uv = vecTex;
    return outp;
}



float rand(float n){
    return frac(cos(n*89.42)*343.42);
}

float rand(float2 co){
  return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    float2 uv = inp.uv;
    float fft = pow(g_fFloat1, 1.7);


    //i=i/iResolution.xy-.5;
    float4 o = float4(0,0,0,1);//uv.xyyy;
    for(float w=3.; w<6.;w+=.1)
    {
        o[(int)(w-3)] += fmod(atan2(uv.y-w*.1,uv.x)+g_fTime*.2+fft,.5)/w;
    }
    
    //* post-processing. comment this out for 142 char version.
    o*=1-(rand(uv*o)*.05);//sin(uv.xyxy*o*1e5)*.05;// grain
    o=clamp(o*1.0,0.,1.);// linear brightness
    o.rgb=lerp((o.r+o.g+o.b)/3., o.rgb,.8);// saturation

    // vignette
    float vignetteAmt = 1.-dot(inp.uvn*.85,inp.uvn*.85);
    o.rgb *= vignetteAmt;

    return o;
}

