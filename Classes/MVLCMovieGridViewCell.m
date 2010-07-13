//
//  MVLCMovieGridViewCell.m
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCMovieGridViewCell.h"

@interface MVLCMovieGridViewCell (Private)
+ (UIView *)_viewFromNib;
@end

@implementation MVLCMovieGridViewCell
@synthesize media=_media;

+ (CGSize)cellSize {
	static CGSize sSize = { 0.0f, 0.0f };
	if (sSize.width == 0.0f && sSize.height == 0.0f) {
		sSize = [[self _viewFromNib] frame].size;
	}
	return sSize;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	UIView * view = [MVLCMovieGridViewCell _viewFromNib];

    self = [super initWithFrame:view.frame reuseIdentifier:reuseIdentifier];
	if (self != nil) {
		[self.contentView addSubview:view];
	}
	return self;
}

- (void)setMedia:(VLCMedia *)media {
	if (media != _media) {
		[_media release];
		_media = [media retain];
	}
}

- (VLCMedia *)media {
	return _media;
}

- (void)dealloc {
	[_media release];
    [super dealloc];
}
@end
			
@implementation MVLCMovieGridViewCell (Private)
+ (UIView *)_viewFromNib {
	NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"MVLCMovieGridViewCell" owner:nil options:nil];
	MVLCAssert([array count] == 1, @"Wrong number of objects in NIB file !");
	MVLCAssert([[array lastObject] isKindOfClass:[UIView class]], @"Unexpected object in NIB file !");
	return (UIView *)[array lastObject];
}
@end

