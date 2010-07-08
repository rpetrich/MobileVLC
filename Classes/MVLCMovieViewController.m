    //
//  MVLCMovieViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 06/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVLCMovieViewController.h"

@implementation MVLCMovieViewController
@synthesize movieView=_movieView, media=_media, positionSlider=_positionSlider, playOrPauseButton=_playOrPauseButton, volumeSlider=_volumeSlider, HUDView=_HUDView;
- (void)viewDidLoad {
	[super viewDidLoad];
	_mediaPlayer = [[VLCMediaPlayer alloc] init];
	[_mediaPlayer setDelegate:self];
    [_mediaPlayer setDrawable:self.movieView];
	UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleHUDVisibility:)];
	tapGestureRecognizer.numberOfTapsRequired = 1;
	tapGestureRecognizer.numberOfTouchesRequired = 1;
	[self.movieView addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self addObserver:self forKeyPath:@"media" options:0 context:nil];
	[_mediaPlayer setMedia:self.media];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self removeObserver:self forKeyPath:@"media"];
	[super viewWillDisappear:animated];
}

- (void)dealloc {
	[_playOrPauseButton release];
	[_positionSlider release];
	[_movieView release];
	[_mediaPlayer release];
	[_media release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark Key-Value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self && [keyPath isEqualToString:@"media"]) {
		[_mediaPlayer setMedia:self.media];
	}
}

#pragma mark -
#pragma mark Actions
- (IBAction)togglePlayOrPause:(id)sender {
	if ([_mediaPlayer isPlaying]) {
		[self.playOrPauseButton setImage:[UIImage imageNamed:@"MVLCMovieViewHUDPlay.png"] forState:UIControlStateNormal];
		[_mediaPlayer pause];
	} else {
		[self.playOrPauseButton setImage:[UIImage imageNamed:@"MVLCMovieViewHUDPause.png"] forState:UIControlStateNormal];
		[_mediaPlayer play];
	}
}

- (IBAction)position:(id)sender {
	[_mediaPlayer setPosition:self.positionSlider.value];
}

- (IBAction)volume:(id)sender {
	NSLog(@"_mediaPlayer.audio = %@", _mediaPlayer.audio);
	NSLog(@"self.volumeSlider = %@", self.volumeSlider);
	_mediaPlayer.audio.volume =  self.volumeSlider.value * 200.0f; // FIXME: This is equal to VOLUME_MAX, as defined in VLCAudio.m ...
}

- (IBAction)goForward:(id)sender {
	[_mediaPlayer mediumJumpForward];
}

- (IBAction)goBackward:(id)sender {
	[_mediaPlayer mediumJumpBackward];
}

- (IBAction)toggleHUDVisibility:(id)sender {
	self.HUDView.hidden = !self.HUDView.hidden;
}

#pragma mark -
#pragma mark VLCMediaPlayerDelegate
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
	self.positionSlider.value = [_mediaPlayer position];
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
	// FIXME: Refresh the UI (change Play/Pause for instance)
}
@end
