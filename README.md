# OpenBYOND

A free, open-source alternative to [BYOND](http://byond.com) running on top of Allegro.

## Installing

Not yet.

## Compiling

### Requirements
1. CMake 2.8+
2. Allegro 5.0.11 
 * Windows: Extract into lib/allegro-5.0 (should have lib, include, etc. in that directory)
3. flex
4. bison
5. gcc

Windows users should install flex and bison through Cygwin or MSYS.  Visual C++ Express or Visual Studio will be required to compile on Windows.

### Compile Process

#### Windows

1. Open CMake GUI, you lucky bastard, you.
2. Set the following:
 * Source: C:/Wherever/You/Put/OpenBYOND
 * Build Folder: C:/Wherever/You/Put/OpenBYOND/build
3. Mash Configure and select your desired Visual Studio/Visual C++ Express version
4. Push Generate.
5. Open OpenBYOND.sln in the build directory.
6. F6 to build.
 
#### Linux

```
$ cmake -G "Unix Makefiles"
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

Every openbyond-* directory should have an include/ folder for C++ headers, a src/ for C++ sourcecode, and a CMakeLists.txt file specifying which files are built and any additional actions to take.

## How To Contribute

We welcome any and all contributors.  To get started, feel free to make a fork and modify it to your heart's desire.  If you like, you can then submit a pull request.  Regular committers may eventually get push access.
