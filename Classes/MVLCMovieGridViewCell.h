//
//  MVLCMovieGridViewCell.h
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridViewCell.h"
#import "MVLCCircularProgressView.h"
#import <MediaLibraryKit/MLFile.h>

typedef enum {
	MVLCMovieGridViewCellStyleLeft   = 0,
	MVLCMovieGridViewCellStyleCenter = 1,
	MVLCMovieGridViewCellStyleRight  = 2,
	MVLCMovieGridViewCellStyleNone   = 3
} MVLCMovieGridViewCellStyle;

@interface MVLCMovieGridViewCell : AQGridViewCell <UIAlertViewDelegate> {
	MLFile *_file;
	MVLCMovieGridViewCellStyle _style;
    BOOL _editMode;

	UIImageView * _overlayImageView;
	UILabel *     _titleLabel;
	UILabel *     _subtitleLabel;
	UIImageView * _posterImageView;
	UIImageView * _hdBannerImageView;
	UIActivityIndicatorView * _activityIndicator;
	MVLCCircularProgressView * _progressView;
    UIButton *    _deleteButton;
}
+ (CGSize)cellSize;
+ (MVLCMovieGridViewCell *)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, retain) MLFile * file;
@property (nonatomic, assign) MVLCMovieGridViewCellStyle style;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, retain) IBOutlet UIImageView * overlayImageView;
@property (nonatomic, retain) IBOutlet UILabel * titleLabel;
@property (nonatomic, retain) IBOutlet UILabel * subtitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView * posterImageView;
@property (nonatomic, retain) IBOutlet UIImageView * hdBannerImageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic, retain) IBOutlet MVLCCircularProgressView * progressView;
@property (nonatomic, retain) IBOutlet UIButton * deleteButton;
- (IBAction)deleteFile:(id)sender;
@end

@interface MVLCMovieGridViewCell (InterfaceBuilder)
@property (nonatomic, retain) IBOutlet UIView * contentView;
@end
