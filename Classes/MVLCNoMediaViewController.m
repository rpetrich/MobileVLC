    //
//  MVLCNoMediaViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 30/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVLCNoMediaViewController.h"

@implementation MVLCNoMediaViewController
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}
@end
