#!/bin/sh

# Pre-Compile.sh
# MobileVLC
#
# Created by Pierre d'Herbemont on 6/27/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


plugins="misc/dummy access/filesystem demux/mp4 demux/avi codec/avcodec codec/lpcm packetizer/copy"

pushd `dirname $0`
PROJECT_DIR=`pwd`
popd

echo "// This file is autogenerated by $(basename $0)\n\n" > $PROJECT_DIR/vlc-plugins.h
echo "// This file is autogenerated by $(basename $0)\n\n" > $PROJECT_DIR/vlc-plugins.xcconfig

VLC_CONTRIB_DIR="$PROJECT_DIR/../vlc/extras/contrib/hosts/i686-apple-darwin10"

AVCODEC_FLAGS=`PKG_CONFIG_PATH="$VLC_CONTRIB_DIR/lib/pkgconfig" $VLC_CONTRIB_DIR/bin/pkg-config --libs libavcodec | sed -e s://::`

LDFLAGS="$VLC_CONTRIB_DIR/lib/libavcodec.a $AVCODEC_FLAGS"
DEFINITION=""
BUILTINS="const void *vlc_builtins_modules[] = {\n"
for i in $plugins; do
    dir=`dirname $i`
    name=`basename $i`
    LDFLAGS+="\$(M)/${dir}/lib${name}_plugin.a "
    DEFINITION+="vlc_declare_plugin(${name});\n"
    BUILTINS+="    vlc_plugin(${name}),\n"
done;
BUILTINS+="    NULL\n"
BUILTINS+="};\n"
echo "VLC_PLUGINS_LDFLAGS=$LDFLAGS" >> $PROJECT_DIR/vlc-plugins.xcconfig
echo "$DEFINITION\n$BUILTINS" >> $PROJECT_DIR/vlc-plugins.h

# Force xcode to reload
touch $PROJECT_DIR/vlc.xcconfig
