    //
//  MVLCMovieViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 06/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCMovieViewController.h"

static NSString * MVLCMovieViewControllerHUDFadeInAnimation = @"MVLCMovieViewControllerHUDFadeInAnimation";
static NSString * MVLCMovieViewControllerHUDFadeOutAnimation = @"MVLCMovieViewControllerHUDFadeOutAnimation";

@implementation MVLCMovieViewController
@synthesize movieView=_movieView, media=_media, positionSlider=_positionSlider, playOrPauseButton=_playOrPauseButton, volumeSlider=_volumeSlider, HUDView=_HUDView, topView=_topView;
- (void)viewDidLoad {
	[super viewDidLoad];
	_showInterface = YES;
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
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[self addObserver:self forKeyPath:@"media" options:0 context:nil];
	[_mediaPlayer setMedia:self.media];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[_mediaPlayer stop];
	[self removeObserver:self forKeyPath:@"media"];
}

- (void)dealloc {
	[_topView release];
	[_HUDView release];
	[_playOrPauseButton release];
	[_positionSlider release];
	[_movieView release];
	[_mediaPlayer release];
	[_media release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES; // We support all 4 orientations
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
	_showInterface = !_showInterface;
	if (_showInterface) {
		[UIView beginAnimations:MVLCMovieViewControllerHUDFadeInAnimation context:NULL];
		self.HUDView.alpha = 1.0f;
		self.topView.alpha = 1.0f;
	} else {
		[UIView beginAnimations:MVLCMovieViewControllerHUDFadeOutAnimation context:NULL];
		self.HUDView.alpha = 0.0f;
		self.topView.alpha = 0.0f;
	}
	[UIView setAnimationDelegate:self];
	[UIView commitAnimations];
}

- (IBAction)dismiss:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewAnimationDelegate
- (void)animationWillStart:(NSString *)animationID context:(void *)context {
	if ([animationID isEqualToString:MVLCMovieViewControllerHUDFadeInAnimation]) {
		self.HUDView.hidden = NO;
		self.topView.hidden = NO;
	}
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([animationID isEqualToString:MVLCMovieViewControllerHUDFadeOutAnimation] && [finished boolValue] == YES) {
		self.HUDView.hidden = YES;
		self.topView.hidden = YES;
	}
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
