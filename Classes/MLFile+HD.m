//
//  MLFile+HD.m
//  MobileVLC
//
//  Created by Romain Goyet on 01/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MLFile+HD.h"

@implementation MLFile (HD)
- (BOOL)isHD {
	if ([self videoTrack]) {
		double numberOfPixels = [[[self videoTrack] valueForKey:@"width"] doubleValue] * [[[self videoTrack] valueForKey:@"height"] doubleValue];
		return (numberOfPixels > 600000); // This is roughly between 480p and 720p
    } else {
		return NO; // If we don't have any resolution info, let's assume the file isn't HD
	}
}
@end
