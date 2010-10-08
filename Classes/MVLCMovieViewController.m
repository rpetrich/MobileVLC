    //
//  MVLCMovieViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 06/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <MediaLibraryKit/MLFile.h>
#import "MLFile+HD.h"

#import "MVLCMovieViewController.h"

static NSString * MVLCMovieViewControllerHUDFadeInAnimation = @"MVLCMovieViewControllerHUDFadeInAnimation";
static NSString * MVLCMovieViewControllerHUDFadeOutAnimation = @"MVLCMovieViewControllerHUDFadeOutAnimation";

@implementation MVLCMovieViewController
@synthesize movieView=_movieView, file=_file, url=_url, positionSlider=_positionSlider, playOrPauseButton=_playOrPauseButton, volumeSlider=_volumeSlider, HUDView=_HUDView, topView=_topView, remainingTimeLabel=_remainingTimeLabel;

- (id)init {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self = [super initWithNibName:@"MVLCMovieView_iPad" bundle:nil];
	} else {
		self = [super initWithNibName:@"MVLCMovieView_iPhone" bundle:nil];
	}
	return self;
}

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

	_hudVisibility = YES;
//    [self setHudVisibility:NO]; // This triggers a bug in the transition animation on the iPhone
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_wasPushedAnimated = animated;
	if (_navigationController != self.navigationController) {
		[_navigationController release];
		_navigationController = [self.navigationController retain]; // Working around an UIKit bug - if we're poped non-animated, self.navigationController will be nil in viewWillDisappear
	}
	[_navigationController setNavigationBarHidden:YES animated:animated];
//	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	[self addObserver:self forKeyPath:@"file" options:0 context:nil];
    if (self.file) {
        [_mediaPlayer setMedia:[VLCMedia mediaWithURL:[NSURL URLWithString:self.file.url]]];
    } else if (self.url) {
        [_mediaPlayer setMedia:[VLCMedia mediaWithURL:self.url]];
    }
	if (self.file && self.file.isHD) {
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
															 message:[@"Your __MVLC_DEVICE__ is probably too slow to play this movie correctly." stringByReplacingOccurrencesOfString:@"__MVLC_DEVICE__" withString:[UIDevice currentDevice].model]
															delegate:self
												   cancelButtonTitle:@"Cancel"
												   otherButtonTitles:@"Try anyway", nil];
		[alertView show];
		[alertView release];
	} else {
		[_mediaPlayer play];
	}
    if (self.file && self.file.lastPosition && [self.file.lastPosition floatValue] < 0.99) {
        [_mediaPlayer setPosition:[self.file.lastPosition floatValue]];
	}
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
    if (self.file) {
        self.file.lastPosition = [NSNumber numberWithFloat:[_mediaPlayer position]];
    }
	[_mediaPlayer stop];
}

- (void)dealloc {
	[_topView release];
	[_HUDView release];
	[_playOrPauseButton release];
	[_positionSlider release];
	[_movieView release];
	[_mediaPlayer release];
    [_url release];
	[_file release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES; // We support all 4 orientations
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	// Let's work around the "rotate + statusbar = weird re-layout"
	if ([UIApplication sharedApplication].statusBarHidden) {
		// If the status bar isn't here, let's "save the spot"
		self.topView.frame = CGRectMake(0.0f, 20.0f, self.topView.frame.size.width, self.topView.frame.size.height);
	} else {
		self.topView.frame = CGRectMake(0.0f, 0.0f, self.topView.frame.size.width, self.topView.frame.size.height);
	}
}

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
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:_wasPushedAnimated];
    } else {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }
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
    UIImage *playPauseImage = nil;
    if ([_mediaPlayer state] == VLCMediaPlayerStatePaused) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			playPauseImage = [UIImage imageNamed:@"MVLCMovieViewHUDPlay_iPad.png"];
		} else {
			playPauseImage = [UIImage imageNamed:@"MVLCMovieViewHUDPlay_iPhone.png"];
		}
	} else {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			playPauseImage = [UIImage imageNamed:@"MVLCMovieViewHUDPause_iPad.png"];
		} else {
			playPauseImage = [UIImage imageNamed:@"MVLCMovieViewHUDPause_iPhone.png"];
		}
	}

    if ([_mediaPlayer state] == VLCMediaPlayerStatePlaying) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
	} else {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
	}

    [self.playOrPauseButton setImage:playPauseImage forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { // "Cancel" button
		[self dismiss:self];
	} else { // "Try anyway" button
		[_mediaPlayer play];
	}
}
@end
