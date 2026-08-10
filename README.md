# Tracy Profiler bindings for Odin

Odin bindings for [Tracy Profiler](https://github.com/wolfpld/tracy/) v0.14.0

![image](https://github.com/wolfpld/tracy/raw/master/doc/profiler.png)

![image](https://github.com/wolfpld/tracy/raw/master/doc/profiler2.png)

![image](https://github.com/wolfpld/tracy/raw/master/doc/profiler3.png)

## 1. Cloning/updating the sources
```console
git clone --recurse-submodules https://github.com/oskarnp/odin-tracy
```
Or if you already had this repo cloned:
```console
git submodule update --init
```

## 2. Download the Tracy Profiler server

[Pre-built binaries](https://github.com/wolfpld/tracy/releases/tag/v0.14.0) for
Windows/Mac/Linux available from the official release page.

## 3. Building the Tracy Profiler client library

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
odin run demo -define:TRACY_ENABLE=true -debug -o:speed
```

and then click Connect in Tracy Profiler server.

> [!TIP]
> Run the profiled application (e.g. `demo`) in privileged mode
  (sudo/administrator) to enable even more features in Tracy.


---

> [!IMPORTANT]
> For more details on how to use Tracy, please refer to the [official manual](https://github.com/wolfpld/tracy/releases/download/v0.14.0/tracy.pdf).


## License

Tracy Profiler is licensed under [3-clause BSD license](https://github.com/wolfpld/tracy/blob/master/LICENSE).

These bindings are licensed under [3-clause BSD license](LICENSE).
