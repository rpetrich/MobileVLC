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

@interface MVLCMovieListViewController (Private)
- (void)_setBackgroundForOrientation:(UIInterfaceOrientation)orientation;
- (MVLCMovieGridViewCellStyle)_styleForCellAtIndex:(NSUInteger)index inGridView:(AQGridView *)gridView;
@end

@implementation MVLCMovieListViewController
@synthesize gridView=_gridView;

- (void)viewDidLoad {
    [super viewDidLoad];

	self.gridView.alwaysBounceVertical = YES; // Allow the "bounce" animation even though the list is small (no scroll is really needed, but the animation looks and feels great)

	[self.gridView setLeftContentInset:47.0f];
	[self.gridView setRightContentInset:47.0f];
	

	self.gridView.separatorStyle = AQGridViewCellSeparatorStyleNone;

	UIView * backgroundView = [[UIView alloc] initWithFrame:self.gridView.bounds];
	backgroundView.backgroundColor = [UIColor clearColor];
	self.gridView.backgroundView = backgroundView;
	[backgroundView release];
	[self _setBackgroundForOrientation:self.interfaceOrientation];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self _setBackgroundForOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	NSIndexSet * visibleCellIndices = self.gridView.visibleCellIndices;
	AQGridView * gridView = self.gridView;
	for (NSUInteger index = [visibleCellIndices firstIndex]; index != NSNotFound; index = [visibleCellIndices indexGreaterThanIndex:index]) {
		MVLCMovieGridViewCell * cell = (MVLCMovieGridViewCell *)[gridView cellForItemAtIndex:index];
		MVLCAssert([cell isKindOfClass:[MVLCMovieGridViewCell class]], @"Unexpected cell class !");
		cell.style = [self _styleForCellAtIndex:index inGridView:gridView];
	}
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

//	MVLCLog(@"%d columns, index=%d, style = %d", gridView.numberOfColumns, index, cell.style);
	cell.style = [self _styleForCellAtIndex:index inGridView:gridView];
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

@implementation MVLCMovieListViewController (Private)
- (MVLCMovieGridViewCellStyle)_styleForCellAtIndex:(NSUInteger)index inGridView:(AQGridView *)gridView {
	switch (gridView.numberOfColumns) {
		case 2:
			return 2*(index%2);
		case 3:
			return index%3;
	}
	return MVLCMovieGridViewCellStyleNone;
}

- (void)_setBackgroundForOrientation:(UIInterfaceOrientation)orientation {
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			self.gridView.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCMovieListBackgroundPortrait.png"]];
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			self.gridView.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCMovieListBackgroundLandscape.png"]];
			break;
	}
}
@end
