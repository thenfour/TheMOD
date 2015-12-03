// WIP.
// - everything from https://www.shadertoy.com/view/4s33RN
// - dust / scratches / grain / splotches
// - rgb sep
// - crt / vhs noise


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
    //float3 iResolution : TEXCOORD2;
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
    //outp.iResolution = vec3(400. * vec2(g_fAspect, 1.),0);

    outp.uv = vecTex;

    return outp;
}


float rand(float2 co){
  return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// simulate shadertoy vars:
//static vec3 iResolution;// uniform vec3      iResolution;           // viewport resolution (in pixels)
static float iGlobalTime;// uniform float     iGlobalTime;           // shader playback time (in seconds)
// uniform float     iChannelTime[4];       // channel playback time (in seconds)
// uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
// uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
// uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
static float4 iDate;// uniform vec4      iDate;                 // (year, month, day, time in seconds)
// uniform float     iSampleRate;           // sound sample rate (i.e., 44100)
static float g_fTime;





















// based on: https://www.shadertoy.com/view/Xdf3zB
// Implementation of equi-angular sampling for raymarching through homogenous media
// 2013 @sjb3d

//#define PI              3.1415926535
#define SIGMA           .2
#define STEP_COUNT      1
#define DIST_MAX        10.0
#define LIGHT_POWER     32.0
#define SURFACE_ALBEDO  0.7
#define EPS             3.09
#define BALL_AMOUNT     14
#define GLITCH          true
#define time            iGlobalTime

//static float iChannelTime1;

//static float audioEnvelope;

// shamelessly stolen from iq!
float hash(float n)
{
    return fract(sin(n)*43758.5453123);
}

// void sampleCamera(vec2 fragCoord, vec2 u, out vec3 rayOrigin, out vec3 rayDir)
// {
//     vec2 filmUv = (fragCoord.xy + u)/iResolution.xy;
    
//     float tx = (2.0*filmUv.x - 1.0)*(iResolution.x/iResolution.y);
//     float ty = (1.0 - 2.0*filmUv.y);
//     float tz = 0.0;
    
//     rayOrigin = vec3(0.0, 0.0, 5.0);
//     rayDir = normalize(vec3(tx, ty, tz) - rayOrigin);
// }

// void intersectSphere(
//     vec3 rayOrigin,
//     vec3 rayDir,
//     vec3 sphereCentre,
//     float sphereRadius,
//     inout float rayT,
//     inout vec3 geomNormal)
// {
//     // ray: x = o + dt, sphere: (x - c).(x - c) == r^2
//     // let p = o - c, solve: (dt + p).(dt + p) == r^2
//     //
//     // => (d.d)t^2 + 2(p.d)t + (p.p - r^2) == 0
//     vec3 p = rayOrigin - sphereCentre;
//     vec3 d = rayDir;
//     float a = dot(d, d);
//     float b = 2.0*dot(p, d);
//     float c = dot(p, p) - sphereRadius*sphereRadius;
//     float q = b*b - 4.0*a*c;
//     if (q > 0.0) {
//         float denom = 0.5/a;
//         float z1 = -b*denom;
//         float z2 = abs(sqrt(q)*denom);
//         float t1 = z1 - z2;
//         float t2 = z1 + z2;
//         bool intersected = false;
//         if (0.0 < t1 && t1 < rayT) {
//             intersected = true;
//             rayT = t1;
//         } else if (0.0 < t2 && t2 < rayT) {
//             intersected = true;
//             rayT = t2;
//         }
//         if (intersected) {
//             geomNormal = normalize(p + d*rayT);
//         }
//     }
// }

// void intersectScene(
//     vec3 rayOrigin,
//     vec3 rayDir,
//     inout float rayT,
//     inout vec3 geomNormal)
// {
//     float z = 1.0;
//     float xfactor = .75;
//     float yfactor = 1.0;
    
//     for (int stepIndex = 0; stepIndex < BALL_AMOUNT; ++stepIndex)
//     {   
//         float xtime = time + float(stepIndex)*142.;
//         float posx = sin(xtime/(2.0+sin(hash(float(stepIndex*1342)))));
//         float posy = cos(xtime/(2.0+sin(hash(float(stepIndex*3234)))));
//         float posz = tan(xtime/(2.0+tan(hash(float(stepIndex*2323)))))/3.;
//         intersectSphere(rayOrigin, rayDir, vec3( posx/xfactor, posy, z+posz), 0.2*(2.0+sin((float(stepIndex*1342))))/2., rayT, geomNormal);
//     }
// }

// void sampleUniform(
//     float u,
//     float maxDistance,
//     out float dist,
//     out float pdf)
// {
//     dist = u*maxDistance;
//     pdf = 1.0/maxDistance;
// }

// void sampleScattering(
//     float u,
//     float maxDistance,
//     out float dist,
//     out float pdf)
// {
//     // remap u to account for finite max distance
//     float minU = exp(-SIGMA*maxDistance);
//     float a = u*(1.0 - minU) + minU;

//     // sample with pdf proportional to exp(-sig*d)
//     dist = -log(a)/SIGMA;
//     pdf = SIGMA*a/(1.0 - minU);
// }

// void sampleEquiAngular(
//     float u,
//     float maxDistance,
//     vec3 rayOrigin,
//     vec3 rayDir,
//     vec3 lightPos,
//     out float dist,
//     out float pdf)
// {
//     // get coord of closest point to light along (infinite) ray
//     float delta = dot(lightPos - rayOrigin, rayDir);
    
//     // get distance this point is from light
//     float D = length(rayOrigin + delta*rayDir - lightPos);

//     // get angle of endpoints
//     float thetaA = atan(0.0 - delta, D);
//     float thetaB = atan(maxDistance - delta, D);
    
//     // take sample
//     float t = D*tan(mix(thetaA, thetaB, u));
//     dist = delta + t;
//     pdf = D/((thetaB - thetaA)*(D*D + t*t));
// }

// i is 0-1
float pixellate(float2 i, float2 sz)
{
    return floor(i / sz) * sz;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float audioEnvelope = 0.;

    vec2 uv = fragCoord;
    vec2 block = pixellate(fragCoord, float2(.08,.06));// floor(fragCoord.xy / vvec2(1));
    vec2 uv_noise = block / vvec2(2);
    uv_noise += iGlobalTime;
    
    float block_thresh = 0.9;//pow(fract(iGlobalTime * 1236.0453), 2.0) * 0.2;
    float line_thresh = 0.1;//pow(fract(iGlobalTime * 2236.0453), 3.0) * 0.7;
    
    vec2 uv_r = uv, uv_g = uv, uv_b = uv;

    // glitch some blocks and lines
    // if  (GLITCH && (tex1.Sample(samp1, uv_noise).r < block_thresh ||
    //     tex1.Sample(samp1, vec2(uv_noise.y, 0.0)).g < line_thresh)) {

    //     vec2 dist = (frac(uv_noise) - 0.5) * audioEnvelope;
    //     fragCoord.x -= dist.x;
    //     fragCoord.y -= dist.y;
    // }

    //fragCoord.x += audioEnvelope * 50.;
    // vec3 lightPos = vec3(0.8*sin(iGlobalTime*3.2/4.0), 0.8*sin(iGlobalTime*1.2/4.0), 0.0);
    // vec3 lightIntensity = vvec3(LIGHT_POWER*audioEnvelope);
    // vec3 surfIntensity = vvec3(SURFACE_ALBEDO/PI);
    // vec3 particleIntensity = vvec3(1.0/(4.0*PI));
    
    //vec3 rayOrigin, rayDir;
   //sampleCamera((fragCoord+uv_r,fragCoord+uv_b), vec2(0.5, 0.5), rayOrigin, rayDir);
    fragColor.ra =texSrc.Sample(sampSrc, uv_r).ra;// output
    fragColor.g =texSrc.Sample(sampSrc, uv_b).b;// output
    fragColor.b =texSrc.Sample(sampSrc, uv_g).g;// output
    //fragColor = .5;


//  float splitCoord = (iMouse.x == 0.0) ? iResolution.x/2.0 : iMouse.x; // old compare indicator
//    float splitCoord = 0.0;
    
    //vec3 col = vvec3(0.0);
    // float t = DIST_MAX;
    // {
    //     vec3 n;
    //     intersectScene(rayOrigin, rayDir, t, n);
        
    //     if (t < DIST_MAX) {
    //         // connect surface to light
    //         vec3 surfPos = rayOrigin + t*rayDir;
    //         vec3 lightVec = lightPos - surfPos;
    //         vec3 lightDir = normalize(lightVec);
    //         vec3 cameraDir = -rayDir;
    //         float nDotL = dot(n, lightDir);
    //         float nDotC = dot(n, cameraDir);
            
    //         // only handle BRDF if entry and exit are same hemisphere
    //         if (nDotL*nDotC > 0.0) {
    //             float d = length(lightVec);
    //             float t2 = d;
    //             vec3 n2;
    //             vec3 rayDir = normalize(lightVec);
    //             intersectScene(surfPos + EPS*rayDir, rayDir, t2, n2);
                
    //             // accumulate surface response if not occluded
    //             if (t2 == d) {
    //                 float trans = exp(-SIGMA*(d + t));
    //                 float geomTerm = abs(nDotL)/dot(lightVec, lightVec);
    //                 col = surfIntensity*lightIntensity*geomTerm*trans;
    //             }
    //         }
    //     }
    // }
    
    // float offset = hash(fragCoord.y*iResolution.x + fragCoord.x + iGlobalTime);
    // for (int stepIndex = 0; stepIndex < STEP_COUNT; ++stepIndex) {
    //     float u = (float(stepIndex)+offset)/float(STEP_COUNT);
        
    //     // sample along ray from camera to surface
    //     float x;
    //     float pdf;
    //     if (fragCoord.x < splitCoord) {
    //         //sampleScattering(u, t, x, pdf);
    //     } else {
    //         sampleEquiAngular(u, t, rayOrigin, rayDir, lightPos, x, pdf);
    //     }
        
    //     // adjust for number of ray samples
    //     pdf *= float(STEP_COUNT);
        
    //     // connect to light and check shadow ray
    //     vec3 particlePos = rayOrigin + x*rayDir;
    //     vec3 lightVec = lightPos - particlePos;
    //     float d = length(lightVec);
    //     float t2 = d;
    //     vec3 n2;
    //     intersectScene(particlePos, normalize(lightVec), t2, n2);
        
    //     // accumulate particle response if not occluded
    //     if (t2 == d) {
    //         float trans = exp(-SIGMA*(d + x));
    //         float geomTerm = 1.0/dot(lightVec, lightVec);
    //         col += SIGMA*particleIntensity*lightIntensity*geomTerm*trans/pdf;
    //     }
    // }
/*
    // show slider position in original shader
    if (abs(fragCoord.x - splitCoord) < 1.0) {
        col.x = 1.0;
    }
*/  
    //col = pow(col, vvec3(1.0/2.2));
    
    //fragColor = col;//vec4(col, 1.0);
    
    // interleave lines in some blocks
    if (GLITCH && (tex1.Sample(samp1, uv_noise).g < block_thresh ||
        tex1.Sample(samp1, vec2(uv_noise.y, 0.0)).g < line_thresh)) {
        float linexx = frac(fragCoord.y / 3.0);
        vec3 mask = vec3(2.0, 0.0, 0.0);
        if (linexx > 0.333)
            mask = vec3(0.0, 2.0, 0.0);
        if (linexx > 0.666)
            mask = vec3(0.0, 0.0, 2.0);
        
        fragColor.xyz *= mask;
    }
}






























float4 PS(PS_INPUT inp) : SV_Target
{
    g_fTime = g_fSeconds;
    iDate = vec4(2015, 11, 1, g_fTime);// totally fake obv.
    iGlobalTime = g_fTime;

    float4 fragColor;

    mainImage(fragColor, inp.uv);

    return fragColor;
}
