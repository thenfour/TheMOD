uniform sampler2D bgTexture;
uniform vec2 bgTextureSize;

uniform float iGlobalTime;
uniform vec3 iResolution;
uniform vec4 iMouse;
uniform vec4 iDate;
uniform float iFFT;


vec3 phosphors(in vec2 p, sampler2D tex, vec2 texSize)
{
  vec3 r = texture2D(tex, p/texSize.xy).rgb;

  // crt effect. probably better to calculate this differently for each r, g, b.
  vec2 size = vec2(3., 2.);
  vec2 thepower = vec2(.2);
  float boost = .4;
  for(int i = 0; i < 3; i ++ ){
    vec2 pp = pow((sin(((gl_FragCoord.xy + (0.*float(i)))) * 2. * 3.141592654 / size)+1.)*.5, thepower);
    float att = pp.x * pp.y;
    att *= boost;
    att += 1.-boost;
    r[i] *= att;
  }
  return r;
}

void main()
{
  vec2 tc;
  float aspect = iResolution.x / iResolution.y;
  vec2 uv = (gl_FragCoord.xy / iResolution.xy) - .5;
  vec2 mc = (iMouse.xy / iResolution.xy);
  mc.y = 1. - mc.y;
  mc -= 0.5;
  if (aspect > 1.) {
    uv.y += mc.y * (aspect - 1.);
    uv.y /= aspect;
  } else {
    uv.x += mc.x * ((1./aspect) - 1.);
    uv.x *= aspect;
  }

  // panzoom. this is not actually accurate and i don'tk now why. for large pads, doesn't dispaly the whole imagee.
  float pad = 0.05;
  uv += mc * pad;
  uv *= 1.-pad;

  // texkture
  tc = uv + .5;// shift origin to tex
  tc *= bgTextureSize;
  gl_FragColor = vec4(phosphors(tc, bgTexture, bgTextureSize), 1.);

  // gamma
  gl_FragColor = vec4(pow(gl_FragColor.rgb, vec3(1./1.4)), 1.);

  // vignette
  vec2 uvv = (gl_FragCoord.xy / iResolution.xy) - .5;
  float vignetteAmt = 1.-dot(uvv,uvv*2.2);
  gl_FragColor *= vignetteAmt;
}



