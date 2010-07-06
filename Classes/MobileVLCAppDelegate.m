//
//  MobileVLCAppDelegate.m
//  MobileVLC
//
//  Created by Pierre d'Herbemont on 6/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MobileVLCAppDelegate.h"
#import <MobileVLCKit/MobileVLCKit.h>

@implementation MobileVLCAppDelegate
@synthesize window=_window, movieViewController=_movieViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [VLCLibrary sharedLibrary];

	[_window addSubview:self.movieViewController.view];
    [_window makeKeyAndVisible];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	NSString * filePath = [documentsDirectory stringByAppendingPathComponent:@"test.avi"];
	self.movieViewController.media = [VLCMedia mediaWithPath:filePath];

    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [_window release];
    [super dealloc];
}


@end

