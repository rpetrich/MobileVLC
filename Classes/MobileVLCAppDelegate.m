//
//  MobileVLCAppDelegate.m
//  MobileVLC
//
//  Created by Pierre d'Herbemont on 6/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

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


    // start vlc.
    [VLCLibrary sharedLibrary];

	NSLog(@"Ha ha ha Blablabla !!");

    VLCMediaPlayer *mp = [[VLCMediaPlayer alloc] init];
    [mp setMedia:[VLCMedia mediaWithURL:[NSURL URLWithString:@"http://192.168.0.3/~romain/99_F.divx.avi"]]];
    [mp setDrawable:splitViewController.view];
    [mp play];

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

