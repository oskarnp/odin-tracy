# odin-tracy
Tracy profiler bindings/wrapper for the Odin programming language.

![image](https://user-images.githubusercontent.com/6025293/111910080-3411b000-8a60-11eb-9be0-8c80a1d5831c.png)


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
#### Build profiler server
```
cd tracy/profiler/build/unix
make release
```
#### Run profiler server
```
./tracy/profiler/build/unix/Tracy-release
```

## Windows
#### Install dependencies
This will download and install external dependencies (glfw3, libcapstone, libfreetype) to vcpkg local directory. This writes files only to the vcpkg\vcpkg directory and makes no other changes on your machine.
```sh
cd tracy\vcpkg
install_vcpkg_dependencies.bat
```
#### Build profiler server
```sh
cd tracy\profiler\build\win32
msbuild Tracy.sln -t:Build -p:Configuration=Release
```
(or open solution with Visual Studio and build from there)
#### Run profiler server
```sh
x64\Release\Tracy.exe
```

## Linux

### Install dependencies
* pkg-config
* glfw3
* freetype2
* capstone

#### Build profiler server
```
cd tracy/profiler/build/unix
make release
```
#### Run profiler server
```
./tracy/profiler/build/unix/Tracy-release
```

## 3. Building the Tracy profiler client library

### Mac OS
```sh
c++ -stdlib=libc++ -mmacosx-version-min=10.8 -std=c++11 -DTRACY_ENABLE -O2 -dynamiclib tracy/TracyClient.cpp  -o tracy.dylib
```
### Windows
```sh
cl -MT -O2 -DTRACY_ENABLE -c tracy\public\TracyClient.cpp -Fotracy
lib tracy.obj
```
### Linux
TODO

## 4. (Optional) Run the demo application / profiler client

### Windows/Linux
```sh
cd demo
odin run . -define:TRACY_ENABLE=true
```
### Mac OS
```sh
cd demo
DYLB_LIBRARY_PATH=.. odin run . -define:TRACY_ENABLE=true
```

and then click Connect in Tracy profiler server.


---

For more details on how to use Tracy, please refer to the [official manual](https://github.com/wolfpld/tracy/releases/download/v0.9/tracy.pdf).
