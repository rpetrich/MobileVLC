#!/bin/sh
rm -rf stage
mkdir -p stage/Applications
cp -r build/Release-iphoneos/VLC.app stage/Applications
mkdir -p stage/DEBIAN
cp control prerm stage/DEBIAN
rm com.zodttd.vlc4iphone_1:1.1.1_iphoneos.deb 2> /dev/null || true
dpkg-deb -Zbzip2 -b stage com.zodttd.vlc4iphone_1:1.1.1_iphoneos.deb