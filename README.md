# OpenBYOND

A free, open-source alternative to [BYOND](http://byond.com) running on top of Allegro.

## Installing

Not yet.

## Compiling

### Requirements
1. CMake 2.8+
2. Allegro 5.0.11 (extract into lib/allegro-5.0)
3. flex
4. bison

### Compile Process
```
$ cmake
```

## WHERE IS EVERYTHING

Here's the organization we're currently using:

* cmake/ - CMake macros and packages.
* lib/ - External libraries (allegro, etc)
* doc/ - Documentation
* openbyond-core - Core library, DM parser syntax, networking. Common things everything else uses.
* openbyond-client - Client.
* openbyond-server - Server.
* openbyond-ide - Replacement for DreamMaker.