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

@interface MVLCMovieGridViewCell (PrivateInSuper)
@property (nonatomic, retain) NSString * reuseIdentifier;
@end

@interface MVLCMovieGridViewCell (Private)
+ (MVLCMovieGridViewCell *)_cellFromNib;
- (void)_refreshFromFile;
- (UIImage *)_framedImageFromImage:(UIImage *)sourceImage;
@end

@implementation MVLCMovieGridViewCell
@synthesize file=_file, titleLabel=_titleLabel, posterImageView=_posterImageView;
@synthesize activityIndicator=_activityIndicator;

- (void)awakeFromNib {
	// Workaround a stupid piece of code in AQGridViewCell
	UIColor * color = self.backgroundColor;
	[super awakeFromNib];
	self.backgroundColor = color;
    self.selectionGlowColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.selectionGlowShadowRadius = 40;
    self.selectionStyle = AQGridViewCellSelectionStyleGlow;
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
		[_file release];
		_file = [file retain];
        [_file addObserver:self forKeyPath:@"showEpisode.artworkURL" options:0 context:nil];
        [_file addObserver:self forKeyPath:@"artworkURL" options:0 context:nil];
        [_file addObserver:self forKeyPath:@"computedThumbnail" options:0 context:nil];
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

	[_activityIndicator release];
	[_posterImageView release];
	[_titleLabel release];
	[_file release];
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

- (void)_refreshFromFile
{
    MLFile *file = self.file;
	self.titleLabel.text = [file title];

    [self.activityIndicator stopAnimating];

    NSURL *url = [NSURL URLWithString:file.showEpisode ? file.showEpisode.artworkURL : file.artworkURL];
    [self.posterImageView cancelCurrentImageLoad];
    NSLog(@"%@", [file title]);

    if (url) {
        NSLog(@"%@", url);
        [self.posterImageView setImageWithURL:url];
    } else if (file.computedThumbnail) {
        [self.posterImageView setImage:[self _framedImageFromImage:[UIImage imageWithData:file.computedThumbnail]]];
    } else {
        [self.activityIndicator startAnimating];
        [self.posterImageView setImage:nil];
    }
}

- (UIImage *)_framedImageFromImage:(UIImage *)sourceImage {

	UIImage * maskImage = [UIImage imageNamed:@"MVLCMovieGridViewCellImageMask.png"];	
	CGContextRef context = NULL;

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate (NULL, maskImage.size.width, maskImage.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);	
	CGColorSpaceRelease(colorSpace);

	CGImageRef maskImageRef = [maskImage CGImage];
	CGContextClipToMask(context, CGRectMake(0, 0, maskImage.size.width, maskImage.size.height), maskImageRef);
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, maskImage.size.width, maskImage.size.height), sourceImage.CGImage);

	CGImageRef framedImageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);

	UIImage * framedImage = [UIImage imageWithCGImage:framedImageRef];
	CGImageRelease(framedImageRef);
	
	return framedImage;
}

@end

