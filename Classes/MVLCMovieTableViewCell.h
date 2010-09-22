//
//  MVLCMovieTableViewCell.h
//  MobileVLC
//
//  Created by Romain Goyet on 22/09/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaLibraryKit/MLFile.h>
#import "MVLCCircularProgressView.h"

@interface MVLCMovieTableViewCell : UITableViewCell {
	MLFile *                   _file;
	UIImageView *              _posterImageView;
	UILabel *                  _titleLabel;
	UILabel *                  _subtitleLabel;
	MVLCCircularProgressView * _progressView;
	UIActivityIndicatorView *  _activityIndicator;
}
+ (CGFloat)cellHeight;
+ (MVLCMovieTableViewCell *)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setEven:(BOOL)even;
@property (nonatomic, retain) MLFile * file;
@property (nonatomic, retain) IBOutlet UIImageView * posterImageView;
@property (nonatomic, retain) IBOutlet UILabel * titleLabel;
@property (nonatomic, retain) IBOutlet UILabel * subtitleLabel;
@property (nonatomic, retain) IBOutlet MVLCCircularProgressView * progressView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@end
