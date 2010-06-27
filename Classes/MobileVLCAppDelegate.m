//
//  MobileVLCAppDelegate.m
//  MobileVLC
//
//  Created by Pierre d'Herbemont on 6/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <vlc/vlc.h>

#import "MobileVLCAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"


@implementation MobileVLCAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after app launch

    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];

    static const char * args[] = {
        "-v",
        "--ignore-config",
        "--no-media-library",
        "-I", "dummy",
        "--plugin-path=../modules",
        "--vout=dummy",
        "--aout=dummy"
    };

    static const int argc = sizeof (args) / sizeof (args[0]);

    //vlc_declare_plugin(avcodec);
    vlc_declare_plugin(avi);
    vlc_declare_plugin(dummy);
    vlc_declare_plugin(filesystem);
    vlc_declare_plugin(mp4);
    const void *builtins[] = {
        //vlc_plugin(avcodec),
        vlc_plugin(avi),
        vlc_plugin(dummy),
        vlc_plugin(filesystem),
        vlc_plugin(mp4), NULL };

    libvlc_instance_t *vlc = libvlc_new_with_builtins(argc, args, builtins);
    NSAssert(vlc, @"Can't initialize vlc");
    libvlc_media_t *m = libvlc_media_new_path(vlc, "/Users/steg/Movies/7 Ans De Mariage.avi");
    libvlc_media_player_t *mp = libvlc_media_player_new(vlc);
    libvlc_media_player_set_media(mp, m);
    libvlc_media_player_play(mp);

    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [splitViewController release];
    [window release];
    [super dealloc];
}


@end

