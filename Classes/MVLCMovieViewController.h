//
//  MVLCMovieViewController.h
//  MobileVLC
//
//  Created by Romain Goyet on 06/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileVLCKit/MobileVLCKit.h>

@interface MVLCMovieViewController : UIViewController <VLCMediaPlayerDelegate> {
	VLCMedia *       _media;
	VLCMediaPlayer * _mediaPlayer;
	UIView *         _movieView;
	UISlider *       _positionSlider;
	UISlider *       _volumeSlider;
	UIButton *       _playOrPauseButton;
}
@property (nonatomic, retain) VLCMedia * media;
@property (nonatomic, retain) IBOutlet UIView * movieView;
@property (nonatomic, retain) IBOutlet UISlider * positionSlider;
@property (nonatomic, retain) IBOutlet UISlider * volumeSlider;
@property (nonatomic, retain) IBOutlet UIButton * playOrPauseButton;
- (IBAction)togglePlayOrPause:(id)sender;
- (IBAction)position:(id)sender;
- (IBAction)volume:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)goBackward:(id)sender;	
@end
