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
@synthesize movieView=_movieView, media=_media, positionSlider=_positionSlider, playOrPauseButton=_playOrPauseButton, volumeSlider=_volumeSlider, HUDView=_HUDView, topView=_topView, remainingTimeLabel=_remainingTimeLabel;
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
    [self setHudVisibility:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[self addObserver:self forKeyPath:@"media" options:0 context:nil];
	[_mediaPlayer setMedia:self.media];
    [_mediaPlayer play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_mediaPlayer pause];
	[self removeObserver:self forKeyPath:@"media"];

    // Make sure we unset this
    [UIApplication sharedApplication].idleTimerDisabled = NO;

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewDidDisappear:animated];
	[_mediaPlayer stop];
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

- (void)setHudVisibility:(BOOL)visibility
{
	if (_hudVisibility) {
        if (_hudVisibility != visibility)
            [UIView beginAnimations:MVLCMovieViewControllerHUDFadeInAnimation context:NULL];
		self.HUDView.alpha = 1.0f;
		self.topView.alpha = 1.0f;
	} else {
        if (_hudVisibility != visibility)
            [UIView beginAnimations:MVLCMovieViewControllerHUDFadeOutAnimation context:NULL];
		self.HUDView.alpha = 0.0f;
		self.topView.alpha = 0.0f;
	}
    _hudVisibility = visibility;
    //[self resetHudAutoHide];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    //[self resetHudAutoHide];
}

- (void)resetHudAutoHide
{
    if (!_hudVisibility)
        return;
    // Hide the HUD after 5 secs
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideHud) object:nil];
    [self performSelector:@selector(hideHud) withObject:nil afterDelay:5];
}

- (void)hideHud
{
    [self setHudVisibility:NO];
}

- (IBAction)toggleHUDVisibility:(id)sender {
    self.hudVisibility = !self.hudVisibility;

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
