#!/bin/sh
c++ -stdlib=libc++ -mmacosx-version-min=10.8 -std=c++11 -DTRACY_ENABLE -O2 -dynamiclib tracy/public/TracyClient.cpp  -o tracy.dylib
