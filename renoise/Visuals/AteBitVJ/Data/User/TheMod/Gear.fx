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
};


//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT inp)
{
    PS_INPUT outp;
    float2 vecTex = (inp.vecTex-.5)*2.;
    outp.vecPos = float4(vecTex*2., 0, 1);
    
    //vecTex += .5; // shift origin to bottom-left; shadertoy compatibility
    vecTex *= 2.;// double viewport bounds (scale)
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

// circle
float sdCircle(float2 uv, float radius)
{
    float d = length(uv) - radius;
    return d;
}

// i is 0-1
float pixellate(float i, float sz)
{
    return floor(i / sz) * sz;
}

float tri(float i, float p)
{
    return abs(fmod(abs(i),(p*2.)) - p) / p;
}

float tri_gear(float i, float p)
{
    return clamp(tri(i,p), .45, .6);
}

float opAdd(float a, float b) { return min(a,b); }
float opSub(float a, float b) { return max(a,-b); }

float sdGear(float2 uv, float scale, float direction, float rotOffset)
{
    const float cogCount = 26.;
    const float innerRadius = 0.8;
    const float outerRadius = 0.9;
    float radius = fmod(atan2(uv.y,uv.x)+pi2, pi2) / pi2;
    radius *= direction;
    radius += rotOffset;
    radius += g_fTime * 0.03;
    radius = .6 + tri_gear(radius, 1./cogCount);
    radius *= scale;

    return opSub(sdCircle(uv, radius), sdCircle(uv, 0.1));
}

float sdScene(float2 uv)
{
    return opAdd(
        sdGear(uv - float2(-.7,-.3), 0.7, 1., 0.),
        sdGear(uv - float2(0.7,0.5), 0.7, -1., 0.01)
        );
}

//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    float fft = 160. * pow(1.-g_fFloat1, 1.7);

    float2 uv = inp.uv;// -1 to 1, centered
    float4 o = float4(0,0,0,1);

    o.rgb = lerp(o.rgb, float3(1,1,1), dtoa(sdScene(uv), fft));

    return o;
}

