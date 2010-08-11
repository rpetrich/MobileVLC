    //
//  MVLCMovieListViewController.m
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCMovieListViewController.h"
#import "MVLCMovieViewController.h"
#import "MVLCMovieGridViewCell.h"
#import <CoreData/CoreData.h>
#import "MLFile.h"
#import "MLMediaLibrary.h"
#import "UIImageView+WebCache.h"

#define MVLC_INSET_BACKGROUND_HEIGHT 600.0f

@implementation MVLCMovieListViewController
@synthesize gridView=_gridView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.gridView setLeftContentInset:47.0f];
	[self.gridView setRightContentInset:47.0f];
	

	UIView * backgroundView = [[UIView alloc] initWithFrame:self.gridView.bounds];
	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCMovieListBackground.png"]];
	self.gridView.separatorStyle = AQGridViewCellSeparatorStyleNone;
	self.gridView.backgroundView = backgroundView;
	[backgroundView release];
	
	self.gridView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

	UIView * headerInsetView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, MVLC_INSET_BACKGROUND_HEIGHT)];
	headerInsetView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	headerInsetView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCMovieListBackgroundPattern.png"]];
	self.gridView.gridHeaderView = headerInsetView;
	[headerInsetView release];
	UIView * footerInsetView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, MVLC_INSET_BACKGROUND_HEIGHT)];
	footerInsetView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	footerInsetView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCMovieListBackgroundPattern.png"]];
	self.gridView.gridFooterView = footerInsetView;
	[footerInsetView release];
	self.gridView.contentInset = UIEdgeInsetsMake(-MVLC_INSET_BACKGROUND_HEIGHT, 0.0f, -MVLC_INSET_BACKGROUND_HEIGHT, 0.0f);

    _allMedia = [[NSMutableArray arrayWithArray:[MLFile allFiles]] retain];
	[self.gridView reloadData];	
}

- (void)dealloc {
	[_allMedia release];
	[_gridView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES; // We support all 4 possible orientations
}

#pragma mark -
#pragma mark AQGridViewDataSource
- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView
{
	return [_allMedia count];
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
	static NSString * MVLCMovieListGridCellIdentifier = @"MVLCMovieListGridCellIdentifier";
	MVLCMovieGridViewCell * cell = (MVLCMovieGridViewCell *)[gridView dequeueReusableCellWithIdentifier:MVLCMovieListGridCellIdentifier];
	if (cell == nil) {
		cell = [MVLCMovieGridViewCell cellWithReuseIdentifier:MVLCMovieListGridCellIdentifier];
	}
    MLFile *file = [_allMedia objectAtIndex:index];

    cell.file = file;
	return cell;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[MLMediaLibrary sharedMediaLibrary] libraryDidDisappear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[MLMediaLibrary sharedMediaLibrary] libraryDidAppear];
}

// all cells are placed in a logical 'grid cell', all of which are the same size. The default size is 96x128 (portrait).
// The width/height values returned by this function will be rounded UP to the nearest denominator of the screen width.
- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView {
	return [MVLCMovieGridViewCell cellSize];
}

#pragma mark -
#pragma mark AQGridViewDelegate
- (void)gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index {
	MVLCMovieViewController * movieViewController = [[MVLCMovieViewController alloc] init];
    MLFile *file = [_allMedia objectAtIndex:index];
	movieViewController.file = file;
	[self.navigationController pushViewController:movieViewController animated:YES];
	[movieViewController release];
}

@end
