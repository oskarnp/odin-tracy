# Tracy Profiler

## A real time, nanosecond resolution, remote telemetry, hybrid frame and sampling profiler for games and other applications.

This is a bindings/wrapper library for the Odin programming language.

![image](https://github.com/wolfpld/tracy/raw/master/doc/profiler.png)

![image](https://github.com/wolfpld/tracy/raw/master/doc/profiler2.png)

![image](https://github.com/wolfpld/tracy/raw/master/doc/profiler3.png)

## 0. Prerequisites
This assumes you are using the latest nightly build or GitHub master of the Odin compiler.   Since Odin is still under development this means these bindings might break in the future. Please create an issue or PR if that happens.

## 1. Cloning the sources
```console
git clone --recurse-submodules https://github.com/oskarnp/odin-tracy
```
Or if you already had this repo cloned:
```console
git submodule update --init
```

## 2. Building the Tracy profiler server

### Mac OS
#### Install dependencies
```console
brew install pkg-config glfw freetype capstone
```
#### Build profiler server
```console
cd tracy/profiler/build/unix
make release
```
#### Run profiler server
```console
./tracy/profiler/build/unix/Tracy-release
```

## Windows
#### Install dependencies
This will download and install external dependencies (glfw3, libcapstone, libfreetype) to vcpkg local directory. This writes files only to the vcpkg\vcpkg directory and makes no other changes on your machine.
```console
cd tracy\vcpkg
install_vcpkg_dependencies.bat
```
#### Build profiler server
This requires Visual Studio installed. Open "x64 Native Tools Command Prompt for VS 20XX" and run commands below.
```console
cd tracy\profiler\build\win32
msbuild Tracy.sln -t:Build -p:Configuration=Release
```
(or open solution with Visual Studio and build from there)
#### Run profiler server
```console
x64\Release\Tracy.exe
```

## Linux

### Install dependencies
* pkg-config
* freetype2
* capstone
* glfw3 (glfw-x11)
  * (Only required if using LEGACY=1 below, otherwise not required and
    profiler server will use Wayland instead.)

#### Build profiler server
```console
cd tracy/profiler/build/unix
make release LEGACY=1
```
> [!NOTE]
> Remove LEGACY=1 above to use Wayland instead of GLFW.

#### Run profiler server
```console
./tracy/profiler/build/unix/Tracy-release
```

## 3. Building the Tracy profiler client library

### Mac OS
```console
c++ -stdlib=libc++ -mmacosx-version-min=10.8 -std=c++11 -DTRACY_ENABLE -O2 -dynamiclib tracy/public/TracyClient.cpp  -o tracy.dylib
```
### Windows
```console
cl -MT -O2 -DTRACY_ENABLE -c tracy\public\TracyClient.cpp -Fotracy
lib tracy.obj
```
### Linux
```console
c++ -std=c++11 -DTRACY_ENABLE -O2 tracy/public/TracyClient.cpp -shared -fPIC -o tracy.so
```

## 4. (Optional) Run the demo application / profiler client

```console
odin run demo -define:TRACY_ENABLE=true
```

and then click Connect in Tracy profiler server.

> [!TIP]
> Run the profiled application (e.g. `demo`) in privileged mode
  (sudo/administrator) to enable even more features in Tracy.


---

> [!IMPORTANT]
> For more details on how to use Tracy, please refer to the [official manual](https://github.com/wolfpld/tracy/releases/download/v0.10/tracy.pdf).
