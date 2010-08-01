//
//  MVLCMovieGridViewCell.h
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridViewCell.h"

@class MLFile;
@interface MVLCMovieGridViewCell : AQGridViewCell {
	MLFile *_file;

	UILabel *     _titleLabel;
	UIImageView * _posterImageView;
	UIActivityIndicatorView * _activityIndicator;
}
+ (CGSize)cellSize;
+ (MVLCMovieGridViewCell *)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, retain) MLFile* file;
@property (nonatomic, retain) IBOutlet UILabel *     titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView * posterImageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@end

@interface MVLCMovieGridViewCell (InterfaceBuilder)
@property (nonatomic, retain) IBOutlet UIView * contentView;
@end
