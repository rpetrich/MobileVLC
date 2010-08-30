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
#import "MVLCAboutViewController.h"

#define MVLC_INSET_BACKGROUND_HEIGHT 600.0f
#define MVLC_MOVIE_LIST_ANIMATION_DURATION 0.50f

static NSString * MVLCMovieListViewControllerMovieSelectionAnimation = @"MVLCMovieListViewControllerMovieSelectionAnimation";

@interface MVLCMovieListViewController (Private)
@property (readonly) UIView * _animatedView;
- (void)_setBackgroundForOrientation:(UIInterfaceOrientation)orientation;
- (MVLCMovieGridViewCellStyle)_styleForCellAtIndex:(NSUInteger)index inGridView:(AQGridView *)gridView;
@end

@implementation MVLCMovieListViewController
@synthesize gridView=_gridView;

#pragma mark -
#pragma mark Creation / deletion
- (void)viewDidLoad {
    [super viewDidLoad];

	_lastTransform = CGAffineTransformIdentity;

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
	headerInsetView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
	self.gridView.gridHeaderView = headerInsetView;
	[headerInsetView release];
	UIView * footerInsetView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, MVLC_INSET_BACKGROUND_HEIGHT)];
	footerInsetView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	footerInsetView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
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

#pragma mark -
#pragma mark Actions
- (IBAction)showAboutScreen:(id)sender {
	MVLCAboutViewController * aboutViewController = [[MVLCAboutViewController alloc] initWithNibName:@"MVLCAboutView" bundle:nil];
	[self.navigationController pushViewController:aboutViewController animated:YES];
	[aboutViewController release];
}

#pragma mark -
#pragma mark View life cycle
- (void)viewWillAppear:(BOOL)animated {
	[self _setBackgroundForOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	_lastTransform = self._animatedView.transform;
	self._animatedView.transform = CGAffineTransformIdentity;
}

- (void)viewDidDisappear:(BOOL)animated {
    [[MLMediaLibrary sharedMediaLibrary] libraryDidDisappear];
    [super viewDidAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[[MLMediaLibrary sharedMediaLibrary] libraryDidAppear];

	// Let's start the "zoom-out" animation
	self._animatedView.transform = _lastTransform;
	NSUInteger lastSelectionIndex = self.gridView.indexOfSelectedItem;
	[self.gridView deselectItemAtIndex:lastSelectionIndex animated:animated]; // Let's also enforce the de-selection
	[self.gridView.delegate gridView:self.gridView didDeselectItemAtIndex:lastSelectionIndex]; // For some reason, AQGridView doesn't do this

	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Interface orientation

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
- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView {
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

// all cells are placed in a logical 'grid cell', all of which are the same size. The default size is 96x128 (portrait).
// The width/height values returned by this function will be rounded UP to the nearest denominator of the screen width.
- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView {
	return [MVLCMovieGridViewCell cellSize];
}

#pragma mark -
#pragma mark AQGridViewDelegate
- (void)gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index {
	MVLCMovieGridViewCell * cell = (MVLCMovieGridViewCell *)[gridView cellForItemAtIndex:index];
	if (cell == nil) {
		return;
	}
	MVLCAssert([cell isKindOfClass:[MVLCMovieGridViewCell class]], @"Unexpected cell class !");

	[UIView beginAnimations:MVLCMovieListViewControllerMovieSelectionAnimation context:[_allMedia objectAtIndex:index]];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:MVLC_MOVIE_LIST_ANIMATION_DURATION];
	[UIView setAnimationDelegate:self];

	CGAffineTransform transform = CGAffineTransformIdentity;

	CGPoint transformationTargetCenter = [cell convertPoint:cell.posterImageView.center toView:self._animatedView];
	
	transform = CGAffineTransformScale(transform, 4.0f, 4.0f);
	transform = CGAffineTransformTranslate(transform, self._animatedView.bounds.size.width/2.0f - transformationTargetCenter.x, self._animatedView.bounds.size.height/2.0f - transformationTargetCenter.y);

	cell.contentView.backgroundColor = [UIColor blackColor];
	cell.overlayImageView.alpha = 0.0f;
	cell.posterImageView.alpha = 0.0f;
	cell.progressView.alpha = 0.0f;
	self._animatedView.transform = transform;

	[UIView commitAnimations];
}

- (void) gridView:(AQGridView *)gridView didDeselectItemAtIndex:(NSUInteger)index {
	MVLCMovieGridViewCell * cell = (MVLCMovieGridViewCell *)[gridView cellForItemAtIndex:index];
	MVLCAssert(cell == nil || [cell isKindOfClass:[MVLCMovieGridViewCell class]], @"Unexpected cell class !");

	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:MVLC_MOVIE_LIST_ANIMATION_DURATION];

	if (cell) {
		cell.contentView.backgroundColor = [UIColor clearColor];
		cell.overlayImageView.alpha = 1.0f;
		cell.posterImageView.alpha = 1.0f;
		cell.progressView.alpha = 1.0f;
	}

	self._animatedView.transform = CGAffineTransformIdentity;

	[UIView commitAnimations];
}

#pragma mark -
#pragma mark UIViewAnimationDelegate
- (void)animationWillStart:(NSString *)animationID context:(void *)context {
	
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([animationID isEqualToString:MVLCMovieListViewControllerMovieSelectionAnimation]) {
		if ([finished boolValue]) {
			MLFile * file = (MLFile *)context;
			if (file != nil) {
				MVLCAssert([file isKindOfClass:[MLFile class]], @"Unexpected animation context !");
				MVLCMovieViewController * movieViewController = [[MVLCMovieViewController alloc] init];
				movieViewController.file = file;
				[self.navigationController pushViewController:movieViewController animated:NO];
//				[movieViewController release]; // FIXME : VLCKit bug
			}
		}
	}
}
@end

@implementation MVLCMovieListViewController (Private)
- (UIView *)_animatedView {
	return self.view.window;
}
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
