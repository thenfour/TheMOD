// https://www.shadertoy.com/view/MsBGWm



// globals / constants need 'static'
// some keywords will be reserved. for example if you make your own saturate() function.
// vec2(1) is not valid in hlsl so i made new constructors. use vvec2() / vvec3() / etc.
// HLSL cannot use operator * between float2x2 and float2. (mat * uv) is mul(mat,uv).
#pragma pack_matrix( column_major )
#define vec2 float2  
#define vec3 float3  
#define vec4 float4  
//#define mat2 float2x2-- these must be handled specially anyway; a #define won't cut it.
#define mod fmod // <-- these are not *exactly* the same between hlsl & glsl
#define mix lerp  
#define atan atan2  
#define fract frac
//#define texture2D tex2D-- must be converted manually; #define won't cut it.

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
static vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
// uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
static float4 iDate;// uniform vec4      iDate;                 // (year, month, day, time in seconds)
// uniform float     iSampleRate;           // sound sample rate (i.e., 44100)












// Ben Quantock 2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.



//#define BLOB // alternate shape


static const float tau = 6.28318530717958647692;
// anti aliased / blurred distance field tracer

// trace a cone vs the distance field
// approximate pixel coverage with a direction and proportion
// this will cope correctly with grazing the edge of a surface, which my focal blur trick didn't

// Gamma correction
#define GAMMA (3.2)
//#define BLOB

vec3 ToGamma( in vec3 col )
{
    // convert back into colour values, so the correct light will come out of the monitor
    return pow( abs(col), vvec3(1.0/GAMMA) );
}

static vec3 viewSpaceRay;

// Set up a camera looking at the scene.
// origin - camera is positioned relative to, and looking at, this point
// distance - how far camera is from origin
// rotation - about x & y axes, by left-hand screw rule, relative to camera looking along +z
// zoom - the relative length of the lens
void CamPolar( out vec3 pos, out vec3 ray, in vec3 origin, in vec2 rotation, in float distance, in float zoom, in vec2 fragCoord )
{
    // get rotation coefficients
    vec2 c = vec2(cos(rotation.x),cos(rotation.y));
    vec4 s;
    s.xy = vec2(sin(rotation.x),sin(rotation.y)); // worth testing if this is faster as sin or sqrt(1.0-cos);
    s.zw = -s.xy;

    // ray in view space
    ray.xy = fragCoord.xy - iResolution.xy*.5;
    ray.z = iResolution.y*zoom;
    ray = normalize(ray);
    
    viewSpaceRay = ray;
    
    // rotate ray
    ray.yz = ray.yz*c.xx + ray.zy*s.zx;
    ray.xz = ray.xz*c.yy + ray.zx*s.yw;
    
    // position camera
    pos = origin - distance*vec3(c.x*s.y,s.z,c.x*c.y);
}


vec2 Noise( in vec3 x )
{
    return vec2(0.5, .5);
    // vec3 p = floor(x);
    // vec3 f = fract(x);
    // f = f*f*(3.0-2.0*f);

    // vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
    // //vec4 rg = texture2D( iChannel0, (uv+0.5)/256.0, -100.0 );
    // vec4 rg = tex1.Sample(samp1, (uv+0.5)/256.0, -100.0 );

    // return mix( rg.yw, rg.xz, f.z );
}



float fft(float x)
{
    return texFFT.Sample(sampFFT, float2(x,0)).r;
}

float DistanceField( vec3 pos )
{
#ifdef BLOB
    float a = atan(pos.x,pos.z)+iGlobalTime*.1;
    pos.xz = length(pos.xz)*vec2(sin(a),cos(a));
    return .5*(length(pos)-2.0+(Noise(pos).x+Noise(pos*2.0+iGlobalTime*vec3(0,1.0,0)).x/2.0)*1.0);
#else
    // rotational symmettry
    const float slice = tau/12.;
    float rot = -iGlobalTime*.5;
    rot -= pow(g_fFloat1, .2);
    float a = abs(fract(atan(pos.x,pos.z)/slice+rot)-.5)*slice;
    a -= pow(g_fFloat1, .2)*.2;
    pos.xz = length(pos.xz)*vec2(sin(a),cos(a));
    
    // symettry in y
    pos.y = abs(pos.y);
    
    return dot(pos,normalize(vec3(1,1,1))) - 1.0;
#endif
}


vec3 Normal( vec3 pos, float rad )
{
    vec2 delta = vec2(0,rad);
    vec3 grad;
    grad.x = DistanceField( pos+delta.yxx )-DistanceField( pos-delta.yxx );
    grad.y = DistanceField( pos+delta.xyx )-DistanceField( pos-delta.xyx );
    grad.z = DistanceField( pos+delta.xxy )-DistanceField( pos-delta.xxy );
    return normalize(grad);
}


vec3 Sky( vec3 ray )
{
    // combine some vague coloured shapes
    vec3 col = vec3(0,0,0);
    
    col += vec3(.1,.1,.13)*smoothstep(.2,1.0,dot(ray,normalize(vec3(1,1,3))));
    col += vec3(.1,.1,.05)*Noise(ray*2.0+vec3(0,1,5)*iGlobalTime).x;
    col += 3.0*vec3(0,1.7,3)*smoothstep(.8,1.0,dot(ray,normalize(vec3(3,3,-2))));
    col += 2.0*vec3(2,1,3)*smoothstep(.9,1.0,dot(ray,normalize(vec3(3,8,-2))));
    
    return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // float2 fftCoord = abs(fragCoord / iResolution.xy - .5);
    // fftCoord.x = fftCoord.y;
    // fftCoord = pow(fftCoord, 1.8);
    float zoom = 1.5;//lerp(1.5, 1.8, pow(fft(length(fftCoord)), 1.4));

    vec3 pos, ray;
    CamPolar( pos, ray, .04*vec3(Noise(vec3(3.0*iGlobalTime,0,0)).xy,0), vec2(.22,0)+vec2(.7,tau)*iMouse.yx/iResolution.yx, 6.0, zoom, fragCoord );

    // radius of cone to trace, at 1m distance;
    float coneRad = .7071/(iResolution.y*zoom);
    
    float coverage = -1.0;
    vec3 coverDir = vec3(0,0,0); // this could be a single angle, or a 2D vector, since it's perp to the ray
    
    float aperture = .001;

    float focus = 9.0;
    
    vec3 col = vvec3(0);
    float t = 1.0;
    for ( int i=0; i < 20; i++ )
    {
        float rad = t*coneRad + aperture*abs(t-focus);

        vec3 p = pos + t*ray;
        float h = DistanceField( p );
        
        if ( h < rad )
        {
            // shading
            vec3 normal = Normal(p, rad);
            
            vec3 albedo = vvec3(.2);
            
            // lighting
            vec3 ambient = vvec3(.1)*smoothstep(.7,2.0,length(p.xz)+abs(p.y));
            vec3 directional = 3.0*vec3(1,.1,.13)*max(dot(normal,normalize(vec3(-2,-2,-1))),.0);
            directional *= smoothstep(.5,1.5,dot(p,normalize(vec3(1,1,-1))));

            float fresnel = pow( 1.0-abs(dot( normal, ray )), 5.0 );
            fresnel = mix( .03, 1.0, fresnel );
            
            vec3 reflection = Sky( reflect(ray,normal) );
            
            vec3 sampleCol = mix( albedo*(ambient+directional), reflection, vvec3(fresnel) );
            
            // compute new coverage
            float newCoverage = -h/rad;
            vec3 newCoverDir = normalize(normal-dot(normal,ray)*ray);

            // allow for coverage at different angles
            // very dubious mathematics!
            // basically, coverage adds to old coverage if the angles mean they don't overlap
            newCoverage += (1.0+coverage)*(.5-.5*dot(newCoverDir,coverDir));
            newCoverage = min(newCoverage,1.0);

            // S-curve, to imitate coverage of circle
            newCoverage = sin(newCoverage*tau/4.0);//smoothstep(-1.0,1.0,newCoverage)*2.0-1.0;

            if ( newCoverage > coverage )
            {
                
                // combine colour
                col += sampleCol*(newCoverage-coverage)*.5;
                
                coverDir = normalize(mix(newCoverDir,coverDir,(coverage+1.0)/(newCoverage+1.0)));
                coverage = newCoverage;
            }
        }
        
        t += max( h, rad*.5 ); // use smaller values if there are echoey artefacts
        
        if ( h < -rad || coverage > 1.0 )
            break;
    }
    
    col += (1.0-coverage)*.5*Sky(ray);

    // grain
    // vec3 grainPos = vec3(fragCoord.xy*.8,iGlobalTime*30.0);
    // grainPos.xy = grainPos.xy*cos(.75)+grainPos.yx*vec2(-1,1)*sin(.75);
    // grainPos.yz = grainPos.yz*cos(.5)+grainPos.zy*vec2(-1,1)*sin(.5);
    // vec2 filmNoise = Noise(grainPos*.5);
    // col *= mix( vvec3(1), mix(vec3(1,.5,0),vec3(0,.5,1),filmNoise.x), .1*pow(filmNoise.y,1.0) );

    // dust
    //vec2 uv = fragCoord.xy/iResolution.y;
    //float T = floor( iGlobalTime * 60.0 );
    //vec2 scratchSpace = mix( Noise(vec3(uv*8.0,T)).xy, uv.yx+T, .8 )*1.0;
    
    //float scratches = texture2D( iChannel1, scratchSpace ).r;
    //float scratches = tex2.Sample(samp2, scratchSpace).r;
    
    //col *= vvec3(1.0)-.5*vec3(.3,.5,.7)*pow(1.0-smoothstep( .0, .1, .5 ),2.0);
    
    fragColor.rgb = ToGamma(col);
    fragColor.w = 1.0;
}















 




//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT inp) : SV_Target
{
    iDate = vec4(2015, 11, 1, g_fTime);// totally fake obv.
    iGlobalTime = g_fTime;
    iResolution = inp.iResolution;
    iMouse = vec4(0,0,0,0);//current (if MLB down), zw: click

    float4 fragColor = vec4(0,0,0,0);// output

    mainImage(fragColor, inp.vecTex);

    return vec4(fragColor.rgb, 1.0);
}

