//
//  MVLCNoMediaViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 30/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVLCNoMediaViewController.h"

@implementation MVLCNoMediaViewController
@synthesize explanationLabel=_explanationLabel;
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
	_explanationLabel.text = [@"You currently don’t have any video in your VLC library. To add some videos for playback :\n  - Connect your __MVLC_DEVICE__ to your computer.\n  - In iTunes, select your __MVLC_DEVICE__, and then click the Apps tab.\n  - Below File Sharing, select \"VLC\" from the list, and then click Add.\n  - In the window that appears, select a file to transfer, and then click Choose." stringByReplacingOccurrencesOfString:@"__MVLC_DEVICE__" withString:[UIDevice currentDevice].model];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		return YES; // The iPhone only supports portrait
	} else {
		return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	}
}

- (void)dealloc {
	[_explanationLabel release];
	[super dealloc];
}

@end
