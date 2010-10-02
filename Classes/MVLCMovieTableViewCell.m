//
//  MVLCMovieTableViewCell.m
//  MobileVLC
//
//  Created by Romain Goyet on 22/09/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCMovieTableViewCell.h"
#import <MobileVLCKit/MobileVLCKit.h>

@interface MVLCMovieTableViewCell (Private)
- (void)_refreshFromFile;
+ (MVLCMovieTableViewCell *)_cellFromNib;
@end

@implementation MVLCMovieTableViewCell
@synthesize posterImageView=_posterImageView, titleLabel=_titleLabel, subtitleLabel=_subtitleLabel, progressView=_progressView, activityIndicator=_activityIndicator;

+ (CGFloat)cellHeight {
	static CGFloat sHeight = 0.0f;
	if (sHeight == 0.0f) {
		sHeight = [[self _cellFromNib] frame].size.height;
	}
	return sHeight;
}

+ (MVLCMovieTableViewCell *)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
	MVLCMovieTableViewCell * cell = [MVLCMovieTableViewCell _cellFromNib];
	MVLCAssert([cell.reuseIdentifier isEqualToString:reuseIdentifier], @"Invalid identifier in MVLCMovieTableViewCell !");
	return cell;
}

- (void)dealloc {
	self.file = nil;
	[_activityIndicator release];
	[_progressView release];
	[_subtitleLabel release];
	[_titleLabel release];
	[_posterImageView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (void)setFile:(MLFile *)file {
	if (file != _file) {
//        [_file removeObserver:self forKeyPath:@"showEpisode.artworkURL"];
//        [_file removeObserver:self forKeyPath:@"computedThumbnail"];
//        [_file removeObserver:self forKeyPath:@"artworkURL"];
//        [_file removeObserver:self forKeyPath:@"lastPosition"];
//        [_file removeObserver:self forKeyPath:@"tracks"];
//        [_file removeObserver:self forKeyPath:@"duration"];
        [_file didHide];
		[_file release];
		_file = [file retain];
//        [_file addObserver:self forKeyPath:@"showEpisode.artworkURL" options:0 context:nil];
//        [_file addObserver:self forKeyPath:@"computedThumbnail" options:0 context:nil];
//        [_file addObserver:self forKeyPath:@"artworkURL" options:0 context:nil];
//        [_file addObserver:self forKeyPath:@"lastPosition" options:0 context:nil];
//        [_file addObserver:self forKeyPath:@"tracks" options:0 context:nil];
//        [_file addObserver:self forKeyPath:@"duration" options:0 context:nil];
        [_file willDisplay];
	}
	[self _refreshFromFile];
}

- (MLFile *)file {
	return _file;
}

- (void)setEven:(BOOL)even {
	self.backgroundView.hidden = !even;
}
@end

@implementation MVLCMovieTableViewCell (Private)
+ (MVLCMovieTableViewCell *)_cellFromNib {
	NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"MVLCMovieTableViewCell" owner:nil options:nil];
	MVLCAssert([array count] == 1, @"Wrong number of objects in NIB file !");
	MVLCAssert([[array lastObject] isKindOfClass:[MVLCMovieTableViewCell class]], @"Unexpected object in NIB file !");
	MVLCMovieTableViewCell * cell = (MVLCMovieTableViewCell *)[array lastObject];
	cell.backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
	cell.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCMovieTableViewCellBackground.png"]];
	cell.backgroundView.opaque = NO;
	cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
	cell.selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCMovieTableViewCellSelectedBackground.png"]];
	cell.selectedBackgroundView.opaque = NO;
	return cell;
}

- (void)_refreshFromFile {
	self.titleLabel.text = self.file.title;

	if (!self.file.isSafe || self.file.thumbnailTimeouted) {
        [self.activityIndicator stopAnimating];
        self.posterImageView.image = [UIImage imageNamed:@"MVLCMovieGridViewCellBomb.png"];
    }
    else if (self.file.computedThumbnail){
		[self.activityIndicator stopAnimating];
        self.posterImageView.image = self.file.computedThumbnail;
    } else {
        [self.activityIndicator startAnimating];
        self.posterImageView.image = nil;
    }
	float lastPosition = [[self.file lastPosition] floatValue];
	self.progressView.progress = lastPosition;
	self.progressView.hidden = (lastPosition < 0.1f);

	NSMutableString * subtitle = [[NSMutableString alloc] init];
	if (self.file.duration) {
		[subtitle appendFormat:@"%@ - ", [VLCTime timeWithNumber:[self.file duration]]];
	}
	[subtitle appendFormat:@"%.01fMB", (float)([self.file fileSizeInBytes] / 1e6)]; // FIXME - a formatter to play nicely with KB, GB...
    if ([self.file videoTrack]) {
        [subtitle appendFormat:@" - %@x%@", [[self.file videoTrack] valueForKey:@"width"], [[self.file videoTrack] valueForKey:@"height"]];
    }

	self.subtitleLabel.text = subtitle;

	[subtitle release];
}
@end

