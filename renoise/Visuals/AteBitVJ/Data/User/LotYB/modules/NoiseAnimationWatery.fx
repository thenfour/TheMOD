#include "User/LotYB/shadertoy.fxh"




//Noise animation - Watery by nimitz (twitter: @stormoid)

//The domain is rotated by the values of a preliminary fbm call
//then the fbm function is called again to color the screen.
//Turbulent fbm (aka ridged) is used for better effect.
//define centered to see the rotation better.

//#define CENTERED

#define time (fmod(iGlobalTime*0.06,100.))



vec2 hash( vec2 p )
{
  p = vec2( dot(p,vec2(127.1,311.7)),
        dot(p,vec2(269.5,183.3)) );

  return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p )
{
  p *= 5.;
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

  vec2 i = floor( p + (p.x+p.y)*K1 );
  
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0); //vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
    vec2 b = a - o + K2;
  vec2 c = a - 1.0 + 2.0*K2;

    vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );

  vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));

    //return pow(smoothstep(-.6,.6,dot( n, vvec3(70.0) )), 1.0);
    return dot( n, vvec3(70.0) );
  
}




mat2 makem2(in float theta){float c = cos(theta);float s = sin(theta);return mat2(c,-s,s,c);}
//float noise( in vec2 x ){return texture2D(iChannel0, x*.01).x;}

//float noise( in vec2 x ){return tex1.Sample(samp1, x*.06).x;}

mat2 m2 = mat2( 0.80,  0.60, -0.60,  0.80 );
float fbm( in vec2 p )
{ 
  float z=2.;
  float rz = 0.;
  for (float i= 1.;i < 7.;i++ )
  {
    rz+= abs((noise(p)-0.5)*2.)/z;
    z = z*2.;
    p = p*2.;
    p= mul(p,m2);
  }
  return rz;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 p = fragCoord.xy / iResolution.xy*2.-1.;
  p.x *= iResolution.x/iResolution.y;
  vec2 bp = p;
  #ifndef CENTERED
  p += 5.;
  p *= 0.6;
  #endif
  float rb = fbm(p*.5+time*.17)*.1;
  rb = sqrt(rb);
  #ifndef CENTERED
  p = mul(p, makem2(rb*.2+atan(p.y,p.x)*1.));
  #else
  p = mul(p, makem2(rb*.2+atan(p.y,p.x)*2.));
  #endif
  
  //coloring
  float rz = fbm(p*.9-time*.7);
  rz *= dot(bp*5.,bp)+.5;
  rz *= sin(p.x*.5+time*4.)*1.5;
  vec3 col = vec3(.3,.4,.4)/(.1-rz);
  fragColor = vec4(clamp(abs(col),0,1),1.0);
}




