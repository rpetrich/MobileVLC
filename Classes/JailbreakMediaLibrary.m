//
//  JailbreakMediaLibrary.m
//  MobileVLC
//
//  Created by Ryan Petrich on 11-01-08.
//  Copyright 2011 Ryan Petrich. All rights reserved.
//

#import "JailbreakMediaLibrary.h"
#include <sys/stat.h>
#include <sys/types.h>

@implementation JailbreakMediaLibrary

+ (void)initialize
{
	mkdir("/var/mobile/Library/VLC", 0755);
	mkdir("/var/mobile/Library/VLC/Database", 0755);
	mkdir("/var/mobile/Library/VLC/Thumbnails", 0755);
}

- (id)init
{	
	if ((self = [super init])) {
		[_managedObjectModel release];
		_managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle bundleWithPath:@"/Applications/VLC.app"]]] retain];
	}
	return self;
}

- (NSString *)databaseFolderPath
{
	return @"/var/mobile/Library/VLC/Database";
}

- (NSString *)thumbnailFolderPath
{
	return @"/var/mobile/Library/VLC/Thumbnails";
}

@end
