// https://www.shadertoy.com/view/XsXXDn


// globals / constants need 'static'
// some keywords will be reserved. for example if you make your own saturate() function.
// vec2(1) is not valid in hlsl so i made new constructors. use vvec2() / vvec3() / etc.
// HLSL cannot use operator * between float2x2 and float2. (mat * uv) is mul(mat,uv).
#pragma pack_matrix( column_major )
#define vec2 float2  
#define vec3 float3  
#define vec4 float4  
#define mat2 float2x2
#define mod fmod // <-- these are not *exactly* the same between hlsl & glsl
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

// replacement constructors
float2 vvec2(float a, float b){ return float2(a, b); }
float2 vvec2(float a, int b){ return float2(a, b); }
float2 vvec2(int a, float b){ return float2(a, b); }
float2 vvec2(int a, int b){ return float2(a, b); }
float2 vvec2(int a){ return float2(a, a); }
float2 vvec2(float a){ return float2(a, a); }

float3 vvec3(int a) { return float3(a,a,a); }
float3 vvec3(float a) { return float3(a,a,a); }
float3 vvec3(float2 a, float b) { return float3(a,b); }
float3 vvec3(float2 a, int b) { return float3(a,b); }
float3 vvec3(int2 a, float b) { return float3(a,b); }
float3 vvec3(int2 a, int b) { return float3(a,b); }
float3 vvec3(int a, int b, int c) { return float3(a,b,c); }
float3 vvec3(int a, int b, float c) { return float3(a,b,c); }
float3 vvec3(int a, float b, int c) { return float3(a,b,c); }
float3 vvec3(int a, float b, float c) { return float3(a,b,c); }
float3 vvec3(float a, int b, int c) { return float3(a,b,c); }
float3 vvec3(float a, int b, float c) { return float3(a,b,c); }
float3 vvec3(float a, float b, int c) { return float3(a,b,c); }
float3 vvec3(float a, float b, float c) { return float3(a,b,c); }


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

    float3 iResolution : TEXCOORD1;
    //float vol : PSIZE;
};


//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT inp)
{
    PS_INPUT outp;
    float2 vecTex = (inp.vecTex-.5)*2.;
    outp.vecPos = float4(vecTex*2., 0, 1);
    
    vecTex += .5; // shift origin to bottom-left; shadertoy compatibility
    //vecTex *= 2.;// double viewport bounds (scale)

    outp.iResolution = vec3(400. * vec2(g_fAspect, 1.),0);
    outp.vecTex = vecTex * outp.iResolution.xy;// correct aspect and scale up to simulate pixels
    return outp;
}



//--------------------------------------------------------------------------------------
// simulate shadertoy vars:
static vec3 iResolution;// uniform vec3      iResolution;           // viewport resolution (in pixels)
static float iGlobalTime;// uniform float     iGlobalTime;           // shader playback time (in seconds)
// uniform float     iChannelTime[4];       // channel playback time (in seconds)
// uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
static vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
// uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
static float4 iDate;// uniform vec4      iDate;                 // (year, month, day, time in seconds)
// uniform float     iSampleRate;           // sound sample rate (i.e., 44100)


























//Magnetismic by nimitz (twitter: @stormoid)

//Getting 60fps here at high quality
//#define HIGH_QUALITY

#ifdef HIGH_QUALITY
#define STEPS 100
#define ALPHA_WEIGHT 0.025
#define BASE_STEP 0.05
#else
#define STEPS 50
#define ALPHA_WEIGHT 0.05
#define BASE_STEP 0.1
#endif

#define time iGlobalTime
static vec2 mo;
vec2 rot(in vec2 p, in float a){float c = cos(a), s = sin(a);return mul(p, mat2(c,s,-s,c));}
float hash21(in vec2 n){ return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453); }
float noise(in vec3 p) //iq's ubiquitous 3d noise
{
    vec3 ip = floor(p), f = fract(p);
    #ifdef HIGH_QUALITY
    f = f*f*f*(f*(f*6. - 15.) + 10.); //Quintic smoothing
    #else
    f = f*f*(3.0-2.0*f); //Cubic smoothing
    #endif
    vec2 uv = (ip.xy+vec2(37.0,17.0)*ip.z) + f.xy;
    vec2 rg = tex1.Sample(samp1, (uv+ 0.5)/256.0, -100.0 ).yx;
    return mix(rg.x, rg.y, f.z);
}

float fbm(in vec3 p, in float sr)
{
    p *= 3.5;
    float rz = 0., z = 1.;
    for(int i=0;i<4;i++)
    {
        float n = noise(p-time*.6);
        rz += (sin(n*4.4)-.45)*z;
        z *= .47;
        p *= 3.5;
    }
    return rz;
}

vec4 map(in vec3 p)
{
    float dtp = dot(p,p);
    p = .5*p/(dtp + .2);
    p.xz = rot(p.xz, p.y*2.5);
    p.xy = rot(p.xz, p.y*2.);
    
    float dtp2 = dot(p, p);
    p = (mo.y + .6)*3.*p/(dtp2 - 5.);
    float r = clamp(fbm(p, dtp*0.1)*1.5-dtp*(.35-sin(time*0.3)*0.15), 0. ,1.);
    vec4 col = vec4(.5,1.7,.5,.96)*r;
    
    float grd = clamp((dtp+.7)*0.4,0.,1.);
    col.b += grd*.6;
    col.r -= grd*.5;    
    vec3 lv = mix(p,vvec3(0.3),2.);
    grd = clamp((col.w - fbm(p+lv*.05,1.))*2., 0.01, 1.5 );
    col.rgb *= vec3(.5, 0.4, .6)*grd + vec3(4.,0.,.4);
    col.a *= clamp(dtp*2.-1.,0.,1.)*0.07+0.93;
    
    return col;
}

vec4 vmarch(in vec3 ro, in vec3 rd, in vec2 gl_FragCoord)
{
    vec4 rz = 0;
    float t = 2.5;
    t += 0.03*hash21(gl_FragCoord.xy);
    for(int i=0; i<STEPS; i++)
    {
        if(rz.a > 0.99 || t > 6.)break;
        vec3 pos = ro + t*rd;
        vec4 col = map(pos);
        float den = col.a;
        col.a *= ALPHA_WEIGHT;
        col.rgb *= col.a*1.7;
        rz += col*(1. - rz.a);
        t += BASE_STEP - den*(BASE_STEP-BASE_STEP*0.015);
    }
    return rz;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 p = fragCoord.xy/iResolution.xy*2. - 1.;
    p.x *= iResolution.x/iResolution.y*0.95;
    mo = 2.0*iMouse.xy/iResolution.xy;
    mo = (mo==vvec2(.0))?mo=vec2(0.5,1.):mo;
    
    vec3 ro = 4.*normalize(vec3(cos(2.75-2.0*(mo.x+time*0.05)), sin(time*0.22)*0.2, sin(2.75-2.0*(mo.x+time*0.05))));
    vec3 eye = normalize(vvec3(0) - ro);
    vec3 rgt = normalize(cross(vec3(0,1,0), eye));
    vec3 up = cross(eye,rgt);
    vec3 rd = normalize(p.x*rgt + p.y*up + (3.3-sin(time*0.3)*.7)*eye);
    
    vec4 col = vmarch(ro, rd, fragCoord);
    fragColor = vec4(col.rgb, 1.0);
}











//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    iDate = vec4(2015, 11, 1, g_fTime);// totally fake obv.
    iGlobalTime = g_fTime;
    iResolution = inp.iResolution;
    iMouse = vec4(0,0,0,0);

    float4 fragColor = vec4(0,0,0,0);// output

    mainImage(fragColor, inp.vecTex);

    return vec4(fragColor.rgb, 1.0);
}

