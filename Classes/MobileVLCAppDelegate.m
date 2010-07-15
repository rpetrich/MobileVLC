//
//  MobileVLCAppDelegate.m
//  MobileVLC
//
//  Created by Pierre d'Herbemont on 6/27/10.
//  Copyright Applidium 2010. All rights reserved.
//

#import "MobileVLCAppDelegate.h"
#import "MLMediaLibrary.h"
#import <MobileVLCKit/MobileVLCKit.h>

@implementation MobileVLCAppDelegate
@synthesize window=_window, navigationController=_navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [VLCLibrary sharedLibrary];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directoryPath = @"/Users/steg/Downloads";
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    NSMutableArray *filePaths = [NSMutableArray arrayWithCapacity:[fileNames count]];
    for (NSString *fileName in fileNames) {
        if ([[fileName pathExtension] isEqualToString:@"avi"])
            [filePaths addObject:[directoryPath stringByAppendingPathComponent:fileName]];
    }
    NSLog(@"%@", filePaths);

    [[MLMediaLibrary sharedMediaLibrary] addFilePaths:filePaths];
	[_window addSubview:self.navigationController.view];
    [_window makeKeyAndVisible];

//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString * documentsDirectory = [paths objectAtIndex:0];
//	NSString * filePath = [documentsDirectory stringByAppendingPathComponent:@"test.avi"];
////	self.movieViewController.media = [VLCMedia mediaWithPath:filePath];
//	self.movieViewController.media = [VLCMedia mediaWithURL:[NSURL URLWithString:@"rtsp://mafreebox.freebox.fr/fbxtv_pub/stream?namespace=1&service=201&flavour=ld"]];
//	self.movieViewController.media = [VLCMedia mediaWithURL:[NSURL URLWithString:@"http://tv.freebox.fr/stream_france2"]];

    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[_navigationController release];
    [_window release];
    [super dealloc];
}

@end

