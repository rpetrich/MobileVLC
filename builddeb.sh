#!/bin/sh
rm -rf stage
mkdir -p stage/Applications
cp -r build/Release-iphoneos/VLC.app stage/Applications
mkdir -p stage/DEBIAN
cp control prerm stage/DEBIAN
rm com.rpetrich.vlc_1.1.0_iphoneos.deb 2> /dev/null || true
dpkg-deb -Zbzip2 -b stage com.rpetrich.vlc_1.1.0_iphoneos.deb