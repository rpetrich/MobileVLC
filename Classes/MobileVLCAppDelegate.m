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


    // start vlc.
    [VLCLibrary sharedLibrary];


    VLCMediaPlayer *mp = [[VLCMediaPlayer alloc] init];
    [mp setMedia:[VLCMedia mediaWithURL:[NSURL fileURLWithPath:@"/Users/steg/Movies/7 Ans De Mariage.avi"]]];
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

