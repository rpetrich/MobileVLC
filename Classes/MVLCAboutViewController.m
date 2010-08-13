//
//  MVLCAboutViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 13/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVLCAboutViewController.h"

@implementation MVLCAboutViewController
@synthesize webView = _webView;
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
	self.title = @"About";
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.videolan.org"]]];
}

- (void)dealloc {
	[_webView release];
	[super dealloc];
}

- (IBAction)dismiss:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
