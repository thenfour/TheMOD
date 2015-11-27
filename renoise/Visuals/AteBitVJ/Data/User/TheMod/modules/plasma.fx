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



// sin() that returns 0-1
float nsin(float a)
{
    return (sin(a)+1.)/2.;
}
float ncos(float a)
{
    return (cos(a)+1.)/2.;
}


// return 0-1
float plasma_a(float2 uv, float t, float2 lbound, float2 ubound)
{
    float2 p1 = float2(nsin(t * 1.3), nsin(t * 1.9));
    float2 p2 = float2(nsin(t * 1.2), nsin(t * 2.2));
    p1 = (p1 * (ubound - lbound)) + lbound;
    p2 = (p2 * (ubound - lbound)) + lbound;

    return
        (nsin(length(p1 - uv))
        + nsin(length(p2 - uv))
        + nsin(uv.x / 3.)
        + nsin(uv.y / 2.)
        ) / 4.
        ;
}

// like smootherstep, but returns 0.0 at both edges, and 1.0 in the center (instead of a ramp, it's a hill)
// float tri_step(float lbound, float ubound, float val)
// {
//     float halfRange = (ubound - lbound) / 2.0;
//     val -= lbound;// shift down to 0.0 - range
//     val -= halfRange;// shift down to -halfrange - halfrange
//     val = abs(val);// make inverted triangle
//     val = halfRange - val;// invert it so it's the kind of triangle we want (0 at the ends)
//     val = val / halfRange;// scale triangle to 0-1
//     val = clamp(val, 0.0, 1.0);
//     return val;
// }


// convert a 1D value to color, mixing channels
// float3 a_to_color(float a)
// {
//     return float3(
//         tri_step(0.,0.75, 1.-a),
//         tri_step(0.12,0.95, 1.-a),
//         tri_step(0.4,1.0, 1.-a)
//     );
// }



float3 pal2( in float t, in float3 a, in float3 b, in float3 c, in float3 d )
{
    return a + b*cos( pi2*(c*t+d) );
}

float3 a_to_color(float a)
{
    float3 c1 = pal2(a, float3(0.8,0.5,0.4),float3(0.2,0.4,0.2),float3(2.0,1.0,1.0),float3(0.0,0.25,0.25) );
    float3 c2 = pal2(a, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.0,0.33,0.67) );
    float3 c3 = pal2(a, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.0,0.10,0.20) );
    float3 c4 = pal2(a, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.3,0.20,0.20) );
    return pal2(a, c1, c2, c3, c4);
}





//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    float2 uv = inp.uv * 7.;// -1 to 1, centered

    float2 lbound = float2(0., 0.);
    float2 ubound = float2(10., 10.);

    // background
    float4 o = float4(1.,1.,1.,1.);

    // pixellate effect
    const float pixelSize = 0.8;
    //float pixelSize = 44./iResolution.x * ubound.x;// pixels wide always.
    
    //float2 plasma_uv = uv;
    float2 plasma_uv = floor((uv / pixelSize) + 0.5) * pixelSize;// pixellated uv coords

    // plasma
    float a = plasma_a(plasma_uv, g_fTime * 0.15, lbound, ubound);
    o = float4(a_to_color(a), 1.0);
    
    // distance to pixel center
    float pixelBorderFX = ncos(uv.x / pixelSize * pi2);
    pixelBorderFX = min(pixelBorderFX, ncos(uv.y / pixelSize * pi2));
    pixelBorderFX = pow(pixelBorderFX, 0.15);
    o.rgb *= pixelBorderFX;

    // vignette
    float vignetteAmt = 1.-dot(inp.uvn*.85,inp.uvn*.85);
    o.rgb *= vignetteAmt;

    return o;
}

