// https://www.shadertoy.com/view/XsXXDn


// globals / constants need 'static'
// some keywords will be reserved. for example if you make your own saturate() function.
// vec2(1) is not valid in hlsl so i made new constructors. use vvec2() / vvec3() / etc.
// HLSL cannot use operator * between float2x2 and float2. (mat * uv) is mul(mat,uv).

#pragma pack_matrix( row_major )

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

    outp.iResolution = float3(500. * float2(g_fAspect, 1.),0);
    outp.vecTex = vecTex * outp.iResolution.xy;// correct aspect and scale up to simulate pixels
    return outp;
}



//--------------------------------------------------------------------------------------
// simulate shadertoy vars:
static float3 iResolution;// uniform vec3      iResolution;           // viewport resolution (in pixels)
static float iGlobalTime;// uniform float     iGlobalTime;           // shader playback time (in seconds)
// uniform float     iChannelTime[4];       // channel playback time (in seconds)
// uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
static float4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
// uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
static float4 iDate;// uniform vec4      iDate;                 // (year, month, day, time in seconds)
// uniform float     iSampleRate;           // sound sample rate (i.e., 44100)


































//http://webstaff.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
//simplex pretty much 99% copied from there
//adjusted by getting "completely random" gradients instead of randoming from 12 preset ones
//and normalizing the gradient vector

#define time iGlobalTime*0.25
#define PI 3.14159265359

float3x3 rot(float3 ang)
{
    float3x3 x = float3x3(1.0,0.0,0.0,0.0,cos(ang.x),-sin(ang.x),0.0,sin(ang.x),cos(ang.x));
    float3x3 y = float3x3(cos(ang.y),0.0,sin(ang.y),0.0,1.0,0.0,-sin(ang.y),0.0,cos(ang.y));
    float3x3 z = float3x3(cos(ang.z),-sin(ang.z),0.0,sin(ang.z),cos(ang.z),0.0,0.0,0.0,1.0);
    return mul(x,mul(y,z));
}

float noise3D(float3 p)
{
    return frac(sin(dot(p ,float3(12.9898,78.233,128.852))) * 43758.5453)*2.0-1.0;
}

float simplex3D(float3 p)
{
    float f3 = 1.0/3.0;
    float s = (p.x+p.y+p.z)*f3;
    int i = int(floor(p.x+s));
    int j = int(floor(p.y+s));
    int k = int(floor(p.z+s));
    
    float g3 = 1.0/6.0;
    float t = float((i+j+k))*g3;
    float x0 = float(i)-t;
    float y0 = float(j)-t;
    float z0 = float(k)-t;
    x0 = p.x-x0;
    y0 = p.y-y0;
    z0 = p.z-z0;
    
    int i1,j1,k1;
    int i2,j2,k2;
    
    if(x0>=y0)
    {
        if(y0>=z0){ i1=1; j1=0; k1=0; i2=1; j2=1; k2=0; } // X Y Z order
        else if(x0>=z0){ i1=1; j1=0; k1=0; i2=1; j2=0; k2=1; } // X Z Y order
        else { i1=0; j1=0; k1=1; i2=1; j2=0; k2=1; }  // Z X Z order
    }
    else 
    { 
        if(y0<z0) { i1=0; j1=0; k1=1; i2=0; j2=1; k2=1; } // Z Y X order
        else if(x0<z0) { i1=0; j1=1; k1=0; i2=0; j2=1; k2=1; } // Y Z X order
        else { i1=0; j1=1; k1=0; i2=1; j2=1; k2=0; } // Y X Z order
    }
    
    float x1 = x0 - float(i1) + g3; 
    float y1 = y0 - float(j1) + g3;
    float z1 = z0 - float(k1) + g3;
    float x2 = x0 - float(i2) + 2.0*g3; 
    float y2 = y0 - float(j2) + 2.0*g3;
    float z2 = z0 - float(k2) + 2.0*g3;
    float x3 = x0 - 1.0 + 3.0*g3; 
    float y3 = y0 - 1.0 + 3.0*g3;
    float z3 = z0 - 1.0 + 3.0*g3;   
                 
    float3 ijk0 = float3(i,j,k);
    float3 ijk1 = float3(i+i1,j+j1,k+k1);   
    float3 ijk2 = float3(i+i2,j+j2,k+k2);
    float3 ijk3 = float3(i+1,j+1,k+1);  
            
    float3 gr0 = normalize(float3(noise3D(ijk0),noise3D(ijk0*2.01),noise3D(ijk0*2.02)));
    float3 gr1 = normalize(float3(noise3D(ijk1),noise3D(ijk1*2.01),noise3D(ijk1*2.02)));
    float3 gr2 = normalize(float3(noise3D(ijk2),noise3D(ijk2*2.01),noise3D(ijk2*2.02)));
    float3 gr3 = normalize(float3(noise3D(ijk3),noise3D(ijk3*2.01),noise3D(ijk3*2.02)));
    
    float n0 = 0.0;
    float n1 = 0.0;
    float n2 = 0.0;
    float n3 = 0.0;

    float t0 = 0.5 - x0*x0 - y0*y0 - z0*z0;
    if(t0>=0.0)
    {
        t0*=t0;
        n0 = t0 * t0 * dot(gr0, float3(x0, y0, z0));
    }
    float t1 = 0.5 - x1*x1 - y1*y1 - z1*z1;
    if(t1>=0.0)
    {
        t1*=t1;
        n1 = t1 * t1 * dot(gr1, float3(x1, y1, z1));
    }
    float t2 = 0.5 - x2*x2 - y2*y2 - z2*z2;
    if(t2>=0.0)
    {
        t2 *= t2;
        n2 = t2 * t2 * dot(gr2, float3(x2, y2, z2));
    }
    float t3 = 0.5 - x3*x3 - y3*y3 - z3*z3;
    if(t3>=0.0)
    {
        t3 *= t3;
        n3 = t3 * t3 * dot(gr3, float3(x3, y3, z3));
    }
    return 96.0*(n0+n1+n2+n3);
    
}

float fbm(float3 p)
{
    float f;
    f  = 0.50000*simplex3D( p ); p = p*2.01;
    f += 0.25000*simplex3D( p ); p = p*2.02; //from iq
    f += 0.12500*simplex3D( p ); p = p*2.03;
    f += 0.06250*simplex3D( p ); p = p*2.04;
    f += 0.03125*simplex3D( p );
    return f;
}

void mainImage(out float4 fragColor, in float2 fragCoord)
{
    iMouse = float4(0,0,0,0);
    float2 uv = fragCoord.xy/iResolution.xy;
    float2 p = uv*2.0-1.0;
    p.x*=(iResolution.x/iResolution.y);
    float3 col = .1;
    float3 ro = float3(0.0,0.0,-2.0);
    float3 rd = normalize(float3(p,0.0)-ro);
    ro=mul(ro,rot(float3(time-2.0*PI*iMouse.y/iResolution.y,time+2.0*PI*iMouse.x/iResolution.x,0.0)));
    rd=mul(rd,rot(float3(time-2.0*PI*iMouse.y/iResolution.y,time+2.0*PI*iMouse.x/iResolution.x,0.0)));
    float3 rp = ro;
    if(pow(dot(rd,ro),2.0) - pow(length(ro),2.0) + 1.0>0.0)
    {
        float d = -dot(rd,(ro))-sqrt(pow(dot(rd,ro),2.0) - pow(length(ro),2.0) + 1.0);
        rp+=rd*d;
        float t = 0.05;
        for(int i = 0; i<50; i++)
        {       
            rp+= rd*t;
            float ds = length(rp)-1.0;
            if(ds>0.0) break;
            col = lerp(col, 
                      float3(1.0*abs(sin(time)),1.5*abs(ds),1.0*abs(sin(time+PI*0.5))),
                      (fbm(rp*2.0)*4.0+1.0)*abs(ds)*0.1);
        }
    }
    fragColor = float4(col,1.0);
}
















//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    iDate = float4(2015, 11, 1, g_fTime);// totally fake obv.
    iGlobalTime = g_fTime;
    iResolution = inp.iResolution;

    float4 fragColor = float4(0,0,0,0);// output

    mainImage(fragColor, inp.vecTex);

    return float4(fragColor.rgb, 1.0);
}

