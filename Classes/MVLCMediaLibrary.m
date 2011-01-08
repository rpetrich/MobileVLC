//
//  MVLCMediaLibrary.m
//  MobileVLC
//
//  Created by Ryan Petrich on 11-01-08.
//  Copyright 2011 Ryan Petrich. All rights reserved.
//

#import "MVLCMediaLibrary.h"
#include <sys/stat.h>
#include <sys/types.h>

@implementation MVLCMediaLibrary

#if MOBILEVLC_FOR_CYDIA

- (id)init
{
	if ((self = [super init])) {
		mkdir("/var/mobile/Library/VLC", 0755);
		mkdir("/var/mobile/Library/VLC/Database", 0755);
		mkdir("/var/mobile/Library/VLC/Thumbnails", 0755);
		_managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle mainBundle]]] retain];
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

#endif

@end
