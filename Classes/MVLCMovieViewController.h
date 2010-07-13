//
//  MVLCMovieViewController.h
//  MobileVLC
//
//  Created by Romain Goyet on 06/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileVLCKit/MobileVLCKit.h>

@interface MVLCMovieViewController : UIViewController <VLCMediaPlayerDelegate> {
	VLCMedia *       _media;
	VLCMediaPlayer * _mediaPlayer;
	UIView *         _movieView;
	UIView *         _HUDView;
	UIView *         _topView;
	BOOL             _showInterface;
	UISlider *       _positionSlider;
	UISlider *       _volumeSlider;
	UIButton *       _playOrPauseButton;
}
@property (nonatomic, retain) VLCMedia * media;
@property (nonatomic, retain) IBOutlet UIView * movieView;
@property (nonatomic, retain) IBOutlet UIView * HUDView;
@property (nonatomic, retain) IBOutlet UIView * topView;
@property (nonatomic, retain) IBOutlet UISlider * positionSlider;
@property (nonatomic, retain) IBOutlet UISlider * volumeSlider;
@property (nonatomic, retain) IBOutlet UIButton * playOrPauseButton;
- (IBAction)toggleHUDVisibility:(id)sender;
- (IBAction)togglePlayOrPause:(id)sender;
- (IBAction)position:(id)sender;
- (IBAction)volume:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)goBackward:(id)sender;
- (IBAction)dismiss:(id)sender;
@end
