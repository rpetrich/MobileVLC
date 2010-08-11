//
//  MVLCMovieGridViewCell.m
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCMovieGridViewCell.h"
#import "UIImageView+WebCache.h"
#import "MLFile.h"
#import "MLShowEpisode.h"
#import <MobileVLCKit/MobileVLCKit.h>

@interface MVLCMovieGridViewCell (PrivateInSuper)
@property (nonatomic, retain) NSString * reuseIdentifier;
@end

@interface MVLCMovieGridViewCell (Private)
+ (MVLCMovieGridViewCell *)_cellFromNib;
- (void)_refreshFromFile;
+ (UIImage *)imageFromFile:(MLFile *)file;
@end

@implementation MVLCMovieGridViewCell
@synthesize file=_file, titleLabel=_titleLabel, subtitleLabel=_subtitleLabel, posterImageView=_posterImageView, progressView=_progressView;
@synthesize activityIndicator=_activityIndicator;

- (void)awakeFromNib {
	// Workaround a stupid piece of code in AQGridViewCell
	UIColor * color = self.backgroundColor;
	[super awakeFromNib];
	self.backgroundColor = color;
    self.selectionGlowColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.selectionGlowShadowRadius = 40;
    self.selectionStyle = AQGridViewCellSelectionStyleGlow;
    [self.posterImageView setClipsToBounds:YES];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self _refreshFromFile];
}

- (void)setFile:(MLFile *)file {
	if (file != _file) {
        [_file removeObserver:self forKeyPath:@"showEpisode.artworkURL"];
        [_file removeObserver:self forKeyPath:@"computedThumbnail"];
        [_file removeObserver:self forKeyPath:@"artworkURL"];
        [_file removeObserver:self forKeyPath:@"lastPosition"];
        [_file removeObserver:self forKeyPath:@"tracks"];
        [_file removeObserver:self forKeyPath:@"duration"];
        [_file didHide];
		[_file release];
		_file = [file retain];
        [_file addObserver:self forKeyPath:@"showEpisode.artworkURL" options:0 context:nil];
        [_file addObserver:self forKeyPath:@"computedThumbnail" options:0 context:nil];
        [_file addObserver:self forKeyPath:@"artworkURL" options:0 context:nil];
        [_file addObserver:self forKeyPath:@"lastPosition" options:0 context:nil];
        [_file addObserver:self forKeyPath:@"tracks" options:0 context:nil];
        [_file addObserver:self forKeyPath:@"duration" options:0 context:nil];
        [_file willDisplay];
	}
	[self _refreshFromFile];
}

- (MLFile *)file {
	return _file;
}

- (void)dealloc {
    // FIXME: We need to remove the observers at some point.
    // We should use -viewWillDisapear
    [self setFile:nil];

	[_progressView release];
	[_activityIndicator release];
	[_posterImageView release];
	[_subtitleLabel release];
	[_titleLabel release];
	[_file release];
    [super dealloc];
}
@end

@implementation MVLCMovieGridViewCell (Private)
+ (UIImage *)imageFromFile:(MLFile *)file {
#define MVLC_MOVIE_GRID_IMAGE_CACHE_SIZE 32
#if MVLC_MOVIE_GRID_USE_IMAGE_CACHE > 0
    // This does UIImage caching as it appears that loading the PNG files is what slows down the app (up to 75% CPU in ImageIO/libz)
    static NSMutableDictionary * sImageCache = nil;
    static NSMutableArray *      sImageCacheExpirationQueue = nil;
    if (sImageCache == nil) {
        sImageCache = [[NSMutableDictionary alloc] initWithCapacity:MVLC_MOVIE_GRID_IMAGE_CACHE_SIZE];
    }
    if (sImageCacheExpirationQueue == nil) {
        sImageCacheExpirationQueue = [[NSMutableArray alloc] initWithCapacity:MVLC_MOVIE_GRID_IMAGE_CACHE_SIZE];
    }
    UIImage * cachedImage = [sImageCache objectForKey:file.objectID];
    if (cachedImage == nil) {
        MVLCLog(@"Cache MISS for %@", file.objectID);
        if ([sImageCacheExpirationQueue count] >= MVLC_MOVIE_GRID_IMAGE_CACHE_SIZE) {
            [sImageCache removeObjectForKey:[sImageCacheExpirationQueue lastObject]];
            [sImageCacheExpirationQueue removeLastObject];
        }
        cachedImage = [UIImage imageWithData:file.computedThumbnail];
        [sImageCache setObject:cachedImage forKey:file.objectID];
        [sImageCacheExpirationQueue insertObject:file.objectID atIndex:0];
        NSLog(@"Queue = %@", sImageCacheExpirationQueue);
        NSLog(@"Cache = %@", sImageCache);
    } else {
        MVLCLog(@"Cache HIT for %@", file.objectID.URIRepresentation);
        // Bring the current image up in the deletion queue
        [sImageCacheExpirationQueue removeObject:file.objectID];
        [sImageCacheExpirationQueue insertObject:file.objectID atIndex:0];
    }
    return cachedImage;
#else
    return [UIImage imageWithData:file.computedThumbnail];
#endif
}

+ (MVLCMovieGridViewCell *)_cellFromNib {
	NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"MVLCMovieGridViewCell" owner:nil options:nil];
	MVLCAssert([array count] == 1, @"Wrong number of objects in NIB file !");
	MVLCAssert([[array lastObject] isKindOfClass:[MVLCMovieGridViewCell class]], @"Unexpected object in NIB file !");
	return (MVLCMovieGridViewCell *)[array lastObject];
}

- (void)_refreshFromFile
{
    MLFile *file = self.file;
	self.titleLabel.text = [file title];

    [self.activityIndicator stopAnimating];

    NSURL *url = [NSURL URLWithString:file.showEpisode ? file.showEpisode.artworkURL : file.artworkURL];
    [self.posterImageView cancelCurrentImageLoad];

    if (url) {
        [self.posterImageView setImageWithURL:url];
    } else if (file.computedThumbnail) {
        [self.posterImageView setImage:[MVLCMovieGridViewCell imageFromFile:file]];
    } else {
        [self.activityIndicator startAnimating];
        [self.posterImageView setImage:nil];
    }
	float lastPosition = [[file lastPosition] floatValue];
	self.progressView.progress = lastPosition;
	self.progressView.hidden = (lastPosition < 0.1f);

    NSManagedObject *videoTrack = [file videoTrack];
    NSString *videoSizeString = nil;
    if (videoTrack) {
        videoSizeString = [NSString stringWithFormat:@"%@x%@",
                     [videoTrack valueForKey:@"width"], [videoTrack valueForKey:@"height"]];

    }
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ - %.01fMB%s%@",
                          [VLCTime timeWithNumber:[file duration]],
                          (float)([file fileSizeInBytes] / 1e6), // FIXME - a formatter to play nicely with KB, GB...
                          videoSizeString ? " - " : "",
                          videoSizeString];
}
@end

