//
//  MVLCMovieGridViewCell.h
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridViewCell.h"
#import "VLCMedia.h"

@interface MVLCMovieGridViewCell : AQGridViewCell {
	VLCMedia * _media;

	UILabel *     _titleLabel;
	UIImageView * _posterImageView;
}
+ (CGSize)cellSize;
+ (MVLCMovieGridViewCell *)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, retain) VLCMedia * media;
@property (nonatomic, retain) IBOutlet UILabel *     titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView * posterImageView;
@end

@interface MVLCMovieGridViewCell (InterfaceBuilder)
@property (nonatomic, retain) IBOutlet UIView * contentView;
@end
