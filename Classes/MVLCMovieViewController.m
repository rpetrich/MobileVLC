    //
//  MVLCMovieViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 06/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <MediaLibraryKit/MLFile.h>

#define MVLC_MOVIE_VIEW_WORKAROUND_NON_TRANSPARENT_UISTATUSBAR 1

#import "MVLCMovieViewController.h"

static NSString * MVLCMovieViewControllerHUDFadeInAnimation = @"MVLCMovieViewControllerHUDFadeInAnimation";
static NSString * MVLCMovieViewControllerHUDFadeOutAnimation = @"MVLCMovieViewControllerHUDFadeOutAnimation";

@implementation MVLCMovieViewController
@synthesize movieView=_movieView, file=_file, positionSlider=_positionSlider, playOrPauseButton=_playOrPauseButton, volumeSlider=_volumeSlider, HUDView=_HUDView, topView=_topView, remainingTimeLabel=_remainingTimeLabel;
- (void)viewDidLoad {
	[super viewDidLoad];
#if MVLC_MOVIE_VIEW_WORKAROUND_NON_TRANSPARENT_UISTATUSBAR
	self.topView.frame = CGRectMake(0.0f, 20.0f, self.topView.frame.size.width, self.topView.frame.size.height);
#endif
	_mediaPlayer = [[VLCMediaPlayer alloc] init];
	[_mediaPlayer setDelegate:self];
    [_mediaPlayer setDrawable:self.movieView];
	UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleHUDVisibility:)];
	tapGestureRecognizer.numberOfTapsRequired = 1;
	tapGestureRecognizer.numberOfTouchesRequired = 1;
	[self.movieView addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];
    [self setHudVisibility:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[_navigationController release];
	_navigationController = [self.navigationController retain]; // Working around an UIKit bug - if we're poped non-animated, self.navigationController will be nil in viewWillDisappear
	[_navigationController setNavigationBarHidden:YES animated:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	[self addObserver:self forKeyPath:@"file" options:0 context:nil];
	[_mediaPlayer setMedia:[VLCMedia mediaWithURL:[NSURL URLWithString:self.file.url]]];
    [_mediaPlayer play];
    if (self.file.lastPosition && [self.file.lastPosition floatValue] < 0.99)
        [_mediaPlayer setPosition:[self.file.lastPosition floatValue]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_mediaPlayer pause];
	[self removeObserver:self forKeyPath:@"file"];

    // Make sure we unset this
    [UIApplication sharedApplication].idleTimerDisabled = NO;

	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[_navigationController setNavigationBarHidden:NO animated:animated];
	[_navigationController release];
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    self.file.lastPosition = [NSNumber numberWithFloat:[_mediaPlayer position]];
	[_mediaPlayer stop];
}

- (void)dealloc {
	[_topView release];
	[_HUDView release];
	[_playOrPauseButton release];
	[_positionSlider release];
	[_movieView release];
	[_mediaPlayer release];
	[_file release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES; // We support all 4 orientations
}

#if MVLC_MOVIE_VIEW_WORKAROUND_NON_TRANSPARENT_UISTATUSBAR
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[[UIApplication sharedApplication] setStatusBarHidden:!self.hudVisibility withAnimation:UIStatusBarAnimationNone];
}
#endif

#pragma mark -
#pragma mark Key-Value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self && [keyPath isEqualToString:@"file"]) {
        [_mediaPlayer setMedia:[VLCMedia mediaWithURL:[NSURL URLWithString:self.file.url]]];
	}
}

#pragma mark -
#pragma mark Actions
- (IBAction)togglePlayOrPause:(id)sender {
	if ([_mediaPlayer isPlaying]) {
		[_mediaPlayer pause];
	} else {
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

@synthesize hudVisibility=_hudVisibility;

- (void)setHudVisibility:(BOOL)targetvisibility {
	if (targetvisibility) {
        if (targetvisibility != _hudVisibility) {
            [UIView beginAnimations:MVLCMovieViewControllerHUDFadeInAnimation context:NULL];
		}
		self.HUDView.alpha = 1.0f;
		self.topView.alpha = 1.0f;
	} else {
        if (targetvisibility != _hudVisibility) {
            [UIView beginAnimations:MVLCMovieViewControllerHUDFadeOutAnimation context:NULL];
		}
		self.HUDView.alpha = 0.0f;
		self.topView.alpha = 0.0f;
	}
	[[UIApplication sharedApplication] setStatusBarHidden:!targetvisibility withAnimation:UIStatusBarAnimationFade];
	_hudVisibility = targetvisibility;
	[UIView setAnimationDelegate:self];
	[UIView commitAnimations];
}

- (IBAction)toggleHUDVisibility:(id)sender {
    self.hudVisibility = !self.hudVisibility;
}

- (IBAction)dismiss:(id)sender {
	[self.navigationController popViewControllerAnimated:NO];
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
	self.remainingTimeLabel.title = [[_mediaPlayer remainingTime] stringValue];
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
	// FIXME: Refresh the UI (change Play/Pause for instance)
    UIImage *playPauseImage;
    if ([_mediaPlayer state] == VLCMediaPlayerStatePaused)
        playPauseImage = [UIImage imageNamed:@"MVLCMovieViewHUDPlay.png"];
    else
        playPauseImage = [UIImage imageNamed:@"MVLCMovieViewHUDPause.png"];

    if ([_mediaPlayer state] == VLCMediaPlayerStatePlaying)
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    else
        [UIApplication sharedApplication].idleTimerDisabled = NO;

    [self.playOrPauseButton setImage:playPauseImage forState:UIControlStateNormal];
}
@end
