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
	UIView *         _movieView;
	UISlider *       _positionSlider;
	VLCMediaPlayer * _mediaPlayer;
	VLCMedia *       _media;
}
@property (nonatomic, retain) IBOutlet UIView * movieView;
@property (nonatomic, retain) IBOutlet UISlider * positionSlider;
@property (nonatomic, retain) VLCMedia * media;
- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)position:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)goBackward:(id)sender;	
@end
