    //
//  MVLCMovieListViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVLCMovieListViewController.h"


@implementation MVLCMovieListViewController
@synthesize gridView=_gridView;
- (void)viewDidLoad {
    [super viewDidLoad];
	self.gridView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	[self.gridView reloadData];
}

- (void)dealloc {
	[_gridView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark AQGridViewDataSource
- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView {
	return 100;
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
	static NSString * MVLCMovieListGridCellIdentifier = @"MVLCMovieListGridCellIdentifier";
	AQGridViewCell * cell = [gridView dequeueReusableCellWithIdentifier:MVLCMovieListGridCellIdentifier];
	if (cell == nil) {
		cell = [[[AQGridViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f) reuseIdentifier:MVLCMovieListGridCellIdentifier] autorelease];
		UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MVLCIcon.png"]];
		[cell.contentView addSubview:iv];
		[iv release];
	}
	return cell; 
}



@end
