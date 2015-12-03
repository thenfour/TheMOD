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

float sdSegment1D(float uv, float a, float b)
{
    return max(max(a - uv, 0.), uv - b);
}
float sdAxisAlignedRect(float2 uv, float2 tl, float2 br)
{
    float dx = sdSegment1D(uv.x,tl.x,br.x);
    float dy = sdSegment1D(uv.y,tl.y,br.y);
    return dx + dy;// manhattan
    //return sqrt(dx*dx+dy*dy);// euclidian version
}

void blit(inout float3 o, float2 uv, float2 pos, float2 destSize)
{
    uv -= pos;
    uv /= destSize;

    float d = sdAxisAlignedRect(uv, 0, 1);
    float alpha = step(d, 0);
    // causes artifacts. we actually need to sample and use alpha instead
    //if(alpha < 0) return;

    uv.y = 1.-uv.y;// flip y coord
    float4 s = tex1.Sample(samp1, uv);
    o = lerp(o.rgb, s.rgb, s.a * alpha);
}


void slash(inout float3 o, float2 uv)
{
    uv.x -= (uv.y*.7);
    float d = sdAxisAlignedRect(uv, float2(-.8,-1), float2(-.5,1));
    o = lerp(o, float3(.0,.3,.3), 1.-smoothstep(0,.007,d));
}

//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    float2 uv = inp.uv;

    //float4 o = float4(1,1,1,1);

    float4 o = float4(0,0,1,1);
    band(o.rgb, uv, .7, float3(0,0,0));
    band(o.rgb, uv, .6, float3(1,.5,0));
    //band(o.rgb, uv, .3, float3(.5,.5,.5));

    // slash
    float3 grayColor = float3(.5,.5,.5);
    slash(grayColor, uv);
    // KICK
    blit(grayColor, uv, float2(-.2,-.715), float2(2.,1.55));

    band(o.rgb, uv, .3, grayColor);

    band(o.rgb, uv, -.69, float3(0,0,0));
    band(o.rgb, uv, -.73, float3(1,.5,0));
    band(o.rgb, uv, -.8, float3(1,1,1));

    return o;
}

