#!/bin/bash

set -e

usage()
{
cat << EOF
usage: $0 [-s]

OPTIONS
   -s       Build for simulator
EOF
}

spushd()
{
     pushd "$1" 2>&1> /dev/null
}

spopd()
{
     popd 2>&1> /dev/null
}

TARGET=
while getopts "ht:d:b:i:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         s)
             TARGET=Simulator
             ;;
         ?)
             usage
             exit 1
             ;;
     esac
done
shift $(($OPTIND - 1))

if [ "x$1" != "x" ]; then
    usage
    exit 1
fi

mkdir -p ImportedSources

spushd ImportedSources 
if ! [ -e vlc ]; then
git clone git://git.videolan.org/vlc.git
fi
if ! [ -e MediaLibraryKit ]; then
git clone git://github.com/pdherbemont/MediaLibraryKit.git
fi

spushd vlc
spushd extras/package/ios
./build.sh ${TARGET}
spopd
spushd projects/macosx/framework
xcodebuild -project MobileVLCKit.xcodeproj -target "Aggregate static plugins" -configuration "Release"
xcodebuild -project MobileVLCKit.xcodeproj -target "MobileVLCKit" -configuration "Release"
spopd
spopd

spushd MediaLibraryKit
ln -s ../../vlc/projects/macosx/framework/build/Release-iphoneos External/MobileVLCKit
xcodebuild -project MobileMediaLibraryKit.xcodeproj -configuration "Release"
spopd

# Pop external
spopd

ln -s ../../ImportedSources/vlc/projects/macosx/framework/build/Release-iphoneos External/MobileVLCKit
ln -s ../../ImportedSources/MediaLibraryKit/build/Release-iphoneos External/MediaLibraryKit

# Build Mobile VLC now
xcodebuild -project MobileVLC.xcodeproj -configuration "Release"
spopd
