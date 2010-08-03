#!/bin/bash

git clone ssh://git@dev.applidium.com/var/git/vlc.git
git clone ssh://git@dev.applidium.com/var/git/MediaLibraryKit.git
git clone ssh://git@dev.applidium.com/var/git/MobileVLC.git

pushd vlc
pushd extras/package/ios
./build_for_iOS.sh
popd
pushd projects/macosx/framework
xcodebuild -project MobileVLCKit.xcodeproj -target "Aggregate static plugins" -configuration "Release"
xcodebuild -project MobileVLCKit.xcodeproj -target "MobileVLCKit" -configuration "Release"
popd
popd

pushd MediaLibraryKit
ln -s ../../vlc/projects/macosx/framework/build/Release-iphoneos External/MobileVLCKit
xcodebuild -project MobileMediaLibraryKit.xcodeproj -configuration "Release"
popd

pushd MobileVLC
ln -s ../../vlc/projects/macosx/framework/build/Release-iphoneos External/MobileVLCKit
ln -s ../../MediaLibraryKit/build/Release-iphoneos External/MediaLibraryKit
popd
