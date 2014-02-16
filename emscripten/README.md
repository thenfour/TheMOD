
# Requirements # 

* Emscripten (and thus java, python, python2 alias, node.js, ...)
* set emcc path in build.sh

# What... #

* theMODexternalLib.js is used by the compiler to define external javascript calls, called by our CPP code.
* to build,

    bash build.sh

In order to start a simple local web server,

    cd ~/Dropbox/root/MUS/Project2013/website/05/www
    python -m SimpleHTTPServer 8080

And browse to: http://localhost:8080/default.html

To stop it, ctrl+x then ctrl+c (http://www.andyjamesdavies.com/javascript/simple-http-server-on-mac-os-x-in-seconds)

# External Links #

* http://stackoverflow.com/questions/15865923/interaction-with-c-classes-in-emscripten
* https://github.com/kripken/emscripten/wiki/FAQ
* https://github.com/kripken/emscripten/wiki/embind


