# odin-tracy
Tracy profiler for the Odin programming language.

## 0. Prerequisites
This assumes you are using the latest nightly build or GitHub master of the Odin compiler.   Since Odin is still under development this means these bindings might break in the future. Please create an issue or PR if that happens.

## 1. Cloning the sources
```sh
git clone --recurse-submodules https://github.com/oskarnp/odin-tracy
```
Or if you already had this repo cloned:
```sh
git submodule update --init
```

## 2. Building the Tracy profiler server

### Mac OS
#### Install dependencies
```sh
brew install pkg-config glfw freetype capstone
```
#### Build profiler
```
cd tracy/profiler/build/unix
make release
```
#### Run profiler
```
./tracy/profiler/build/unix/Tracy-release
```

## Windows
#### Install dependencies
(This will download and install external dependencies (glfw3, libcapstone, libfreetype) to vcpkg local directory. This writes files only to the vcpkg\vcpkg directory and makes no other changes on your machine.)
```sh
cd tracy\vcpkg
install_vcpkg_dependencies.bat
```
#### Build profiler
```sh
cd tracy\profiler\build\win32
msbuild Tracy.sln -t:Build -p:Configuration=Release
```
(or open solution with Visual Studio and build from there)
#### Run profiler
```sh
x64\Release\Tracy.exe
```

## Linux
TODO

## 3. Building the Tracy profiler client library

### Mac OS
TODO
### Windows
```sh
cl -MT -O2 -DTRACY_ENABLE -c tracy\TracyClient.cpp -Fotracy
lib tracy.obj
```
### Linux
TODO
