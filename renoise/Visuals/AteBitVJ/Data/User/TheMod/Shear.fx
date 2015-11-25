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

    float fft = 100. * pow(1.-g_fFloat1, 2.1);
    vecTex.y -= vecTex.x * 0.5;

    vecTex *= float2(g_fAspect, 1.);// aspect-correct
    outp.uv = vecTex;
    return outp;
}

//--------------------------------------------------------------------------------------

// convert distance to alpha
float dtoa(float d, float amount)
{
    float a = clamp(1.0 / (clamp(d, 1.0/amount, 1.0)*amount), 0.,1.);
    return a;
}

// i is 0-1
// float pixellate(float i, float sz)
// {
//     return floor(i / sz) * sz;
// }

float tri(float i, float p)
{
    return abs(fmod(abs(i),(p*2.)) - p) / p;
}

float tri_gear(float i, float p, float cmin, float cmax)
{
    return clamp(tri(i,p), cmin, cmax);
}

void band(inout float3 o, float2 uv, float y, float3 c)
{
    y -= .3;
    float fft = .5 + g_fFloat1 / 2.;

    float ext = y + tri_gear(uv.x + (g_fTime * .5) - (g_fFloat1 * 1), 0.2, 1.-fft, fft);

    float amt = 400-(1000*pow(g_fFloat1, 0.5));
    amt = clamp(amt, 10, 400);
    o.rgb = lerp(o.rgb, c, dtoa(uv.y - ext, amt));
}

void blit(inout float3 o, float2 uv, float2 pos, float2 destSize)
{
    float texW, texH;
    tex1.GetDimensions(texW, texH);

    uv -= pos;

    if(uv.x <= 0) return;
    if(uv.y <= 0) return;
    if(uv.x >= destSize.x) return;
    if(uv.y >= destSize.y) return;

    uv /= destSize;
    uv.y *= -1;

    float4 s = tex1.Sample(samp1, uv);
    o = lerp(o.rgb, s.rgb, s.a);
}


void slash(inout float3 o, float2 uv)
{
}

//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    float2 uv = inp.uv;

    float4 o = float4(0,0,1,1);
    band(o.rgb, uv, .7, float3(0,0,0));
    band(o.rgb, uv, .6, float3(1,.5,0));
    band(o.rgb, uv, .3, float3(.5,.5,.5));
    band(o.rgb, uv, .2, float3(.5,.5,.5));
    // KICK
    blit(o.rgb, uv, float2(.1,-.75), float2(1.7,1.5));
    // slash
    slash(o.rgb, uv);

    band(o.rgb, uv, -.69, float3(0,0,0));
    band(o.rgb, uv, -.73, float3(1,.5,0));
    band(o.rgb, uv, -.8, float3(1,1,1));

    // vignette
    float vignetteAmt = 1.-dot(inp.uvn*.8,inp.uvn*.8);
    o.rgb *= vignetteAmt;

    return o;
}

