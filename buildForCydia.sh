#!/bin/sh
./buildMobileVLC.sh -t MobileVLCforCydia
rm -rf build/stage
mkdir -p build/stage/Applications
cp -r build/Release-iphoneos/VLC.app build/stage/Applications
mkdir -p build/stage/DEBIAN
cp control prerm build/stage/DEBIAN
rm build/com.zodttd.vlc4iphone_1:1.1.1_iphoneos.deb 2> /dev/null || true
dpkg-deb -Zbzip2 -b build/stage build/com.zodttd.vlc4iphone_1:1.1.1_iphoneos.deb
