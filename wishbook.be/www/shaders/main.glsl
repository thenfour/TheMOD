uniform sampler2D bgTexture;
uniform vec2 bgTextureSize;

uniform float iGlobalTime;
uniform vec3 iResolution;
uniform vec4 iMouse;
uniform vec4 iDate;
uniform float iFFT;

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
  float pad = 0.1;
  uv += mc * pad;
  uv *= 1.-pad;

  tc = uv + .5;// shift origin to tex
  gl_FragColor = vec4(texture2D(bgTexture, tc).rgb, 1.);
  gl_FragColor = 1.-gl_FragColor;
  gl_FragColor = gl_FragColor * 0.3;
  gl_FragColor = 1.-gl_FragColor;
}



