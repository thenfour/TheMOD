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

    outp.iResolution = vec3(100. * vec2(g_fAspect, 1.),0);
    outp.vecTex = vecTex * outp.iResolution.xy;// correct aspect and scale up to simulate pixels
    return outp;
}



//--------------------------------------------------------------------------------------
// simulate shadertoy vars:
static vec3 iResolution;// uniform vec3      iResolution;           // viewport resolution (in pixels)
static float iGlobalTime;// uniform float     iGlobalTime;           // shader playback time (in seconds)
// uniform float     iChannelTime[4];       // channel playback time (in seconds)
// uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
// uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
// uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
static float4 iDate;// uniform vec4      iDate;                 // (year, month, day, time in seconds)
// uniform float     iSampleRate;           // sound sample rate (i.e., 44100)






























//forked By Cale Bradbury, 2015 from https://www.shadertoy.com/view/ltjGzd

//fuck yeah, mirror that shit
#define MIRROR

// Base ray trace code via https://www.shadertoy.com/view/Xds3zN by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


float opS( float d1, float d2 )
{
    return max(-d2,d1);
}

vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}

float qbox( vec3 p, float s )
{
  return length(max(abs(p)-vec3(s,s,s),0.0));
}

float box(vec3 p, vec3 b){ 
    p = abs(p) - b;
    return max(p.x, max(p.y,p.z));
}

vec2 map( in vec3 pos )
{
    float size = .65;
    //pos.z = mod(pos.z,size*5.)-0.5*size*5.;
    pos.y = mod(pos.y,size)-0.5*size;
    float res = qbox(pos,size);

    pos+=size;
    
    float t = iGlobalTime;
    for(float i = 0.0; i<3.;i++){
        size /= 3.0;
        
        float b = box(opRep(pos,vec3(size*5.,size*5.,0)),vec3(size,size,10.));
        res = opS(res,b);
        b = box(opRep(pos,vec3(size*5.25,0.,size*5.)),vec3(size,10.,size));
        res = opS(res,b);
        b = box(opRep(pos,vec3(0.,size*2.,size*6.)),vec3(10.,size,size));
        res = opS(res,b);
    }
    
    return vec2(res,1.0);
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 0.;
    float tmax = 120.0;
    
    float precis = 0.001;
    float t = tmin;
    float m = 0.0;
    for( int i=0; i<120; i++ )
    {
        vec2 res = map( ro+rd*t );
        if( res.x<precis || t>tmax ) break;
        t += res.x;
        m = res.y;
    }

    if( t>tmax ) m=-1.;
    return vec2( t, m );
}

float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
    float res = 1.0;
    float t = mint;
    for( int i=0; i<4; i++ )
    {
        float h = map( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );

}

vec3 calcNormal( in vec3 pos )
{
    vec3 eps = vec3( 0.001, 0.0, 0.0 );
    vec3 nor = vec3(
        map(pos+eps.xyy).x - map(pos-eps.xyy).x,
        map(pos+eps.yxy).x - map(pos-eps.yxy).x,
        map(pos+eps.yyx).x - map(pos-eps.yyx).x );
    return normalize(nor);
}

float calcAO( in vec3 pos, in vec3 nor )
{
    float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vvec3(1.0);
    vec2 res = castRay(ro,rd);
    float t = res.x;
    float m = res.y;
    
    if( m>-0.5 )
    {
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
        vec3 ref = reflect( rd, nor );
        
        // material        
        float occ = calcAO( pos, nor );
        col = occ*smoothstep(vec3(0.8, 0.2, 0.2)*(1.0-occ), vec3(0.2, 0.8, .8)*occ, vvec3(occ));
    }

return vec3( clamp(col,0.0,1.0) );
}

float3x3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
    vec3 cw = normalize(ta-ro);
    vec3 cp = vec3(sin(cr), cos(cr),0.0);
    vec3 cu = normalize( cross(cw,cp) );
    vec3 cv = normalize( cross(cu,cw) );
    return float3x3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
    p.x *= iResolution.x/iResolution.y;
    #ifdef MIRROR
    p.x = -abs(p.x);
    #endif
         
    float time = 15.0 + iGlobalTime*.5;
    float camDist = 3.;
    // camera   
    vec3 ro = vec3(-.02, iGlobalTime*.01, 0.);
    //vec3( -0.5+camDist*cos(0.1*time), 5.0, 0.5 + camDist*sin(0.1*time) );
    vec3 ta = ro + vec3(-1., -1., -1. );
    
    // camera-to-world transformation
//    mat3 ca = setCamera( ro, ta, 56.54 );
    float3x3 ca = setCamera( ro, ta, 0. );
    // ray direction
    vec3 rd = mul(ca, normalize( vvec3(p.xy,5.) ));

    // render   
    vec3 col = render( ro, rd);
    col += (vvec3(1.)*p.y)*0.35;

    fragColor=vec4( col, 1.0 );
}


















//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    iDate = vec4(2015, 11, 1, g_fTime);// totally fake obv.
    iGlobalTime = g_fTime;
    iResolution = inp.iResolution;

    float4 fragColor = vec4(0,0,0,0);// output

    mainImage(fragColor, inp.vecTex);

    return vec4(fragColor.rgb, 1.0);
}

