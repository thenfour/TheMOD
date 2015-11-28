

# What is this?
New website for /KICK, made 2015-11-28. It's compiled, using r.js optimizer. The point is to make something making good use of webgl.

# Build environment
In order to launch local web server:

    $ npm install connect serve-static


# Building
To build, just open bash and do:

    $ bash build.sh


# Viewing / debugging locally

Output is in `./www-release`.

Launch a local web server with

    $ bash launchLocal.sh

Navigate to the URL specified in the console. Probably:

> http://localhost:1337/default.html


# Deploying to production

    $ bash deploy.sh
