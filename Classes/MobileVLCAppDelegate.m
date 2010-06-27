//
//  MobileVLCAppDelegate.m
//  MobileVLC
//
//  Created by Pierre d'Herbemont on 6/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <vlc/vlc.h>
#import "vlc-plugins.h"

#import "MobileVLCAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"

void __bzero(void *a, size_t c)
{
    return bzero(a, c);
}

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
        "-vvv",
        "--ignore-config",
        "--no-media-library",
        "-I", "dummy",
        "--plugin-path=../modules",
        "--vout=dummy",
        "--aout=dummy"
    };

    static const int argc = sizeof (args) / sizeof (args[0]);

    libvlc_instance_t *vlc = libvlc_new_with_builtins(argc, args, vlc_builtins_modules);
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

