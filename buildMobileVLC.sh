#!/bin/sh

set -e

PLATFORM=OS
SDK=iphoneos3.2
VERBOSE=no

usage()
{
cat << EOF
usage: $0 [-s] [-v] [-k sdk]

OPTIONS
   -k       Specify which sdk to use (see 'xcodebuild -showsdks', current: ${SDK})
   -v       Be more verbose
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

info()
{
     local green="\033[1;32m"
     local normal="\033[0m"
     echo "[${green}info${normal}] $1"
}

buildxcodeproj()
{
    local target="$2"
    if [ "x$target" = "x" ]; then
        target="$1"
    fi

    info "Building $1 ($target)"

    local extra=""
    if [ "$PLATFORM" = "Simulator" ]; then
        extra="ARCHS=i386"
    fi

    xcodebuild -project "$1.xcodeproj" \
               -target "$target" \
               -sdk $SDK \
               -configuration "Release" ${extra} > ${out}
}

while getopts "hvsk:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         v)
             VERBOSE=yes
             ;;
         s)
             PLATFORM=Simulator
             SDK=iphonesimulator3.2
             ;;
         k)
             SDK=$OPTARG
             ;;
         ?)
             usage
             exit 1
             ;;
     esac
done
shift $(($OPTIND - 1))

out="/dev/null"
if [ "$VERBOSE" = "yes" ]; then
   out="/dev/stdout"
fi

if [ "x$1" != "x" ]; then
    usage
    exit 1
fi

# Get root dir
spushd .
mvlc_root_dir=`pwd`
spopd

info "Preparing build dirs"

mkdir -p ImportedSources

spushd ImportedSources

if ! [ -e vlc ]; then
git clone git://git.videolan.org/vlc.git
fi
if ! [ -e MediaLibraryKit ]; then
git clone git://github.com/pdherbemont/MediaLibraryKit.git
fi

if [ "$PLATFORM" = "Simulator" ]; then
    xcbuilddir="build/Release-iphonesimulator"
else
    xcbuilddir="build/Release-iphoneos"
fi
framework_build="${mvlc_root_dir}/ImportedSources/vlc/projects/macosx/framework/${xcbuilddir}"
mlkit_build="${mvlc_root_dir}/ImportedSources/MediaLibraryKit/${xcbuilddir}"

spushd MediaLibraryKit
rm External/MobileVLCKit
ln -sf ${framework_build} External/MobileVLCKit
spopd

spopd #ImportedSources

rm External/MobileVLCKit
rm External/MediaLibraryKit
ln -sf ${framework_build} External/MobileVLCKit
ln -sf ${mlkit_build} External/MediaLibraryKit

#
# Build time
#

info "Building"

spushd ImportedSources

spushd vlc/extras/package/ios
info "Building vlc"
args=""
if [ "$PLATFORM" = "Simulator" ]; then
    args="${args} -s"
fi
if [ "$VERBOSE" = "yes" ]; then
    args="${args} -v"
fi
./build.sh ${args} -k "${SDK}"
spopd

spushd vlc/projects/macosx/framework
buildxcodeproj MobileVLCKit "Aggregate static plugins"
buildxcodeproj MobileVLCKit "MobileVLCKit"
spopd

spushd MediaLibraryKit
buildxcodeproj MobileMediaLibraryKit
spopd

spopd # ImportedSources


# Build Mobile VLC now
buildxcodeproj MobileVLC

info "Build completed"
