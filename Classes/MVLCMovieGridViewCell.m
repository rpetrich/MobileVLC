//
//  MVLCMovieGridViewCell.m
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCMovieGridViewCell.h"

@interface MVLCMovieGridViewCell (PrivateInSuper)
@property (nonatomic, retain) NSString * reuseIdentifier;
@end

@interface MVLCMovieGridViewCell (Private)
+ (MVLCMovieGridViewCell *)_cellFromNib;
- (void)_refreshFromMedia;
@end

@implementation MVLCMovieGridViewCell
@synthesize media=_media, titleLabel=_titleLabel, posterImageView=_posterImageView;

- (void)awakeFromNib {
	// Workaround a stupid piece of code in AQGridViewCell
	UIColor * color = self.backgroundColor;
	[super awakeFromNib];
	self.backgroundColor = color;
}

+ (CGSize)cellSize {
	static CGSize sSize = { 0.0f, 0.0f };
	if (sSize.width == 0.0f && sSize.height == 0.0f) {
		sSize = [[self _cellFromNib] frame].size;
	}
	return sSize;
}

+ (MVLCMovieGridViewCell *)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
	MVLCMovieGridViewCell * cell = [MVLCMovieGridViewCell _cellFromNib];
	cell.reuseIdentifier = reuseIdentifier;
	return cell;
}

- (void)setMedia:(VLCMedia *)media {
	if (media != _media) {
		[_media release];
		_media = [media retain];
		[self _refreshFromMedia];
	}
	[self _refreshFromMedia];
}

- (VLCMedia *)media {
	return _media;
}

- (void)dealloc {
	[_posterImageView release];
	[_titleLabel release];
	[_media release];
    [super dealloc];
}
@end
			
@implementation MVLCMovieGridViewCell (Private)
+ (MVLCMovieGridViewCell *)_cellFromNib {
	NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"MVLCMovieGridViewCell" owner:nil options:nil];
	MVLCAssert([array count] == 1, @"Wrong number of objects in NIB file !");
	MVLCAssert([[array lastObject] isKindOfClass:[MVLCMovieGridViewCell class]], @"Unexpected object in NIB file !");
	return (MVLCMovieGridViewCell *)[array lastObject];
}

- (void)_refreshFromMedia {
	NSDictionary * metaDictionary = [self.media metaDictionary];
	self.titleLabel.text = [metaDictionary objectForKey:VLCMetaInformationTitle];
}
@end

