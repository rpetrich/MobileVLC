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
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
	self.title = @"About";
#if MVLC_ABOUT_BEAUTIFY_WEBVIEW
	MVLCAboutViewControllerHideChildUIImageView(self.webView);
#endif
	NSString * sourceHTML = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MVLCAboutContent" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
	NSString * targetHTML = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		targetHTML = [sourceHTML stringByReplacingOccurrencesOfString:@"__MVLC_DEVICE_CSS__" withString:@".page { margin: 50px 50px 50px 0; -webkit-box-shadow: 0px 3px 10px #000000; }"];
	} else {
		targetHTML = [sourceHTML stringByReplacingOccurrencesOfString:@"__MVLC_DEVICE_CSS__" withString:@"body { font-size: 8pt; } .page { margin: 10px; }"];
	}
	[self.webView loadHTMLString:targetHTML baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
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
