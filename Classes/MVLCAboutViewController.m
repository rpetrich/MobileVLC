//
//  MVLCAboutViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 13/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVLCAboutViewController.h"

#define MVLC_ABOUT_BEAUTIFY_WEBVIEW 1

#if MVLC_ABOUT_BEAUTIFY_WEBVIEW
void MVLCAboutViewControllerHideChildUIImageView(UIView * view) {
	if ([view isKindOfClass:[UIImageView class]]) {
		view.hidden = YES; // This removes the ugly shadow
	} else {
		view.backgroundColor = [UIColor clearColor]; // Make the background transparent
		view.opaque = NO;
		for (UIView * subview in [view subviews]) {
			MVLCAboutViewControllerHideChildUIImageView(subview);
		}
	}
}
#endif

@implementation MVLCAboutViewController
@synthesize webView = _webView;
- (void)viewDidLoad {
	NSError * error = nil;
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
	self.title = @"About";
#if MVLC_ABOUT_BEAUTIFY_WEBVIEW
	MVLCAboutViewControllerHideChildUIImageView(self.webView);
#endif	
	[self.webView loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MVLCAboutContent" ofType:@"html"]
														   encoding:NSUTF8StringEncoding
															  error:&error]
						 baseURL:nil];
}

- (void)dealloc {
	[_webView release];
	[super dealloc];
}

#pragma mark -
#pragma mark UIViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Actions
- (IBAction)dismiss:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)visitApplidium:(id)sender {
	// Shameless advertising :-p
	// Honestly, we spent a *lot* of time working on this, we think we deserve this little link :-)
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://applidium.com"]];
}

@end
