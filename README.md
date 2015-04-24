
# dev

Source files are located in:

    www/...

The build process interlaces built stuff with sources. The outputs of building are:

  * `www/min/theMOD.min.js`: all our scripts after compilation
  * `www/default.html` production homepage which loads the minified scripts
  * `www/default.dev.html` dev homepage which loads un-minified scripts
    
The "source" version of `default.html` is `default.src.html`. This has a little placeholder in it for scripts. Thus, you can't run it in a browser and expect it to work. You can only visit `default.html` or `default.dev.html`.

To build,

    bash build.sh

This creates the above files, and is required to run the site, even for dev.

For dev, you don't need any webserver. Just open default.html in a browser. I originally needed a local webserver because I used jquery `.getScript()`. But not anymore because it's minified into a single script.


#deploy

    bash deploy.sh

We deploy more than we need to, whatevs. And it is super slow because curl is super slow.

# Daed stuff

Been tinkering with several things and abandoned them. some of it still remains:

  * RequireJS
  * Closure library (i still use the compiler)
  * KineticJS

# TODO

  * More images? Watermarks?
  * Online content editor
  * Audio automation - maybe animate the sun or something to the audio
  * Logo animation



# /RENOISE/com.carlcorcoran.SDCompoLive.xrnx

# /RENOISE/com.carlcorcoran.TheModVisuals.xrnx

a tool that can be used to map novation launchpad mini to OSC commands, and control LED lights?
