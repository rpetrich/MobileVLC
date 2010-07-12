//
//  MVLCMovieGridViewCell.m
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVLCMovieGridViewCell.h"


@implementation MVLCMovieGridViewCell
@synthesize media=_media;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 200.0f) reuseIdentifier:reuseIdentifier];
	if (self != nil) {
		UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MVLCIcon.png"]];
		[self.contentView addSubview:imageView];
		[imageView release];
	}
	return self;
}

- (void)dealloc {
	[_media release];
    [super dealloc];
}


@end
