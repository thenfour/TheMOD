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

//--------------------------------------------------------------------------------------

// convert distance to alpha
float dtoa(float d, float amount)
{
    //return d > 0 ? 0 : 1;
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

float opAdd(float a, float b) { return min(a,b); }
float opSub(float a, float b) { return max(a,-b); }


float sdGearCircle(float2 uv, float radius, float constRadius)
{
    //return sdCircle(uv, radius);
    return opAdd(
            opSub(
                sdCircle(uv, radius),
                sdCircle(uv, constRadius * 0.5)),
            opSub(
                sdCircle(uv, constRadius * 0.5 - 0.03),
                sdCircle(uv, radius * 0.1)
                )
        );
}


// val, period, and where to cut it off.
float tri_gear(float i, float p, float cmin, float cmax)
{
    return (clamp(tri(i,p), cmin, cmax)-cmin)/(cmax-cmin);
}


// cogPeriod is 0-1, and will be scaled so differently-sized gears' cogs will be compatible
float sdGear(float2 uv, float scale, float rotation, float cmin, float cmax, float cogAmt)
{
    const float cogPeriod = .01799;
    float uvAng = fmod(atan2(uv.y,uv.x)+pi2, pi2) / pi2;

    rotation /= scale;

    float cogAmp = tri_gear(rotation + uvAng, cogPeriod / scale, cmin, cmax);
    //cogAmt *= scale;
    float radius = cogAmt + ((1. - cogAmt) * cogAmp);
    radius *= scale;

    //return opSub(sdCircle(uv, radius), sdCircle(uv, 0.1));
    return sdGearCircle(uv, radius, scale);
}

float sdScene(float2 uv)
{
    float baseRotation = (g_fTime * .17) + pow(g_fFloat1, 2.)*.7;
    baseRotation *= .2;

    return opAdd(
        opAdd(
            sdGear(uv - float2(-.9,-.9), 1.5, baseRotation,            .4, .6, .94),
            sdGear(uv - float2(.66,0.9), .97, baseRotation*-1.+.023,  .4, .6, .88)//
        ),opAdd(
            sdGear(uv - float2(-1.4,1.), .53, baseRotation*-1.+.098, .5, .7, .85),
            sdGear(uv - float2(.944,-.9), .4, baseRotation*-1.+.5, .5, .7, .85)
        ));
}

//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    float fft = 160. * pow(1.-g_fFloat1, 1.7);

    float2 uv = inp.uv;// -1 to 1, centered
    float4 o = float4(0,0,0,1);

    float4 col = g_vecColour1;
    float d = sdScene(uv);
    if(d > 0.)
        col = lerp(o, g_vecColour2, dtoa(d, fft));

    //o.rgb = lerp(o.rgb, g_vecColour1, dtoa(, fft));
    o = col;
    //o.rgb = float3(1,1,1);

    // vignette
    //float vignetteAmt = 1.-dot(inp.uvn,inp.uvn);
    //o.rgb *= vignetteAmt;

    return o;
}

