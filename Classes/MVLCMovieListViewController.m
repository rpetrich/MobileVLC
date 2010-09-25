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
#import "MVLCMovieTableViewCell.h"
#import <CoreData/CoreData.h>
#import <MediaLibraryKit/MLMediaLibrary.h>
#import "MVLCAboutViewController.h"

#define MVLC_MOVIE_LIST_ANIMATION_DURATION 0.30f

static NSString * MVLCMovieListViewControllerMovieSelectionAnimation = @"MVLCMovieListViewControllerMovieSelectionAnimation";

@interface MVLCMovieListViewController (Private)
@property (readonly) UIView * _animatedView;
- (void)_setBackgroundForOrientation:(UIInterfaceOrientation)orientation;
- (MVLCMovieGridViewCellStyle)_styleForCellAtIndex:(NSUInteger)index inGridView:(AQGridView *)gridView;
- (void)_setEditMode:(BOOL)editMode;
- (BOOL)_isInEditMode;
@end

@implementation MVLCMovieListViewController
@synthesize noMediaViewController=_noMediaViewController, editBarButtonItem=_editBarButtonItem;

#pragma mark -
#pragma mark Creation / deletion
- (void)viewDidLoad {
    [super viewDidLoad];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		_tableView = nil;
		_gridView = [[AQGridView alloc] initWithFrame:self.view.bounds];
		_gridView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		_gridView.dataSource = self;
		_gridView.delegate = self;
		[self.view addSubview:_gridView];

		_gridView.alwaysBounceVertical = YES; // Allow the "bounce" animation even though the list is small (no scroll is really needed, but the animation looks and feels great)
		_gridView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		_gridView.separatorStyle = AQGridViewCellSeparatorStyleNone;
		[_gridView setLeftContentInset:47.0f];
		[_gridView setRightContentInset:47.0f];

		UIView * backgroundView = [[UIView alloc] initWithFrame:_gridView.bounds];
		backgroundView.backgroundColor = [UIColor clearColor];
		_gridView.backgroundView = backgroundView;
		[backgroundView release];
		[self _setBackgroundForOrientation:self.interfaceOrientation];

		// Let's add _inset_ header and footer views (i.e. header and footers that aren't in the grid view's "content") 
		CGFloat insetBackgroundHeight = 2.0f * MAX(self.view.bounds.size.width, self.view.bounds.size.height); // The height should be "max screen height x 2", because an empty screen can be scrolled
		UIView * headerInsetView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, insetBackgroundHeight)];
		headerInsetView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		headerInsetView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
		_gridView.gridHeaderView = headerInsetView;
		[headerInsetView release];
		UIView * footerInsetView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, insetBackgroundHeight)];
		footerInsetView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		footerInsetView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
		_gridView.gridFooterView = footerInsetView;
		[footerInsetView release];
		_gridView.contentInset = UIEdgeInsetsMake(-insetBackgroundHeight, 0.0f, -insetBackgroundHeight, 0.0f);
	} else {
		_gridView = nil;
		_tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
		_tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		_tableView.rowHeight = [MVLCMovieTableViewCell cellHeight];
		_tableView.dataSource = self;
		_tableView.delegate = self;
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
		_tableView.opaque = NO;

		// Let's add _inset_ header and footer views (i.e. header and footers that aren't in the table view's "content") 
		CGFloat insetBackgroundHeight = 2.0f * MAX(self.view.bounds.size.width, self.view.bounds.size.height); // The height should be "max screen height x 2", because an empty screen can be scrolled
		UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, insetBackgroundHeight)];
		headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
		_tableView.tableHeaderView = headerView;
		[headerView release];
		UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, insetBackgroundHeight)];
		footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCBackgroundPattern.png"]];
		_tableView.tableFooterView = footerView;
		[footerView release];
		_tableView.contentInset = UIEdgeInsetsMake(-insetBackgroundHeight, 0.0f, -insetBackgroundHeight, 0.0f);

		[self.view addSubview:_tableView];
	}
	[self _setEditMode:NO];

	_lastTransform = CGAffineTransformIdentity;

	[self reloadMedia];
}

- (void)dealloc {
	[_noMediaViewController release];
	[_allMedia release];
	[_gridView release];
	[_tableView release];
    [super dealloc];
}

- (void)reloadMedia {
	[_allMedia release];
	_allMedia = [[NSMutableArray arrayWithArray:[MLFile allFiles]] retain];
	[_gridView reloadData];
    [_tableView reloadData];

	if ([_allMedia count] == 0 && self.noMediaViewController) { // Checking for self.noMediaViewController is important because on load it might be nil
		[self presentModalViewController:self.noMediaViewController animated:NO];
	} else {
		[self dismissModalViewControllerAnimated:NO];
	}
}

#pragma mark -
#pragma mark Actions
- (IBAction)showAboutScreen:(id)sender {
	MVLCAboutViewController * aboutViewController = [[MVLCAboutViewController alloc] initWithNibName:@"MVLCAboutView" bundle:nil];
	[self.navigationController pushViewController:aboutViewController animated:YES];
	[aboutViewController release];
}

- (IBAction)toggleEditMode:(id)sender {
	[self _setEditMode:![self _isInEditMode]];
}

- (void)deleteFile:(MLFile *)file {
    MVLCLog(@"Deleting file %@", file);
}

#pragma mark -
#pragma mark View life cycle
- (void)viewWillAppear:(BOOL)animated {
	[self _setBackgroundForOrientation:self.interfaceOrientation];
	[_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
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
	NSUInteger lastSelectionIndex = _gridView.indexOfSelectedItem;
	[_gridView deselectItemAtIndex:lastSelectionIndex animated:animated]; // Let's also enforce the de-selection
	[_gridView.delegate gridView:_gridView didDeselectItemAtIndex:lastSelectionIndex]; // For some reason, AQGridView doesn't do this

	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Interface orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self _setBackgroundForOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (_gridView) {
		NSIndexSet * visibleCellIndices = _gridView.visibleCellIndices;
		for (NSUInteger index = [visibleCellIndices firstIndex]; index != NSNotFound; index = [visibleCellIndices indexGreaterThanIndex:index]) {
			MVLCMovieGridViewCell * cell = (MVLCMovieGridViewCell *)[_gridView cellForItemAtIndex:index];
			MVLCAssert([cell isKindOfClass:[MVLCMovieGridViewCell class]], @"Unexpected cell class !");
			cell.style = [self _styleForCellAtIndex:index inGridView:_gridView];
		}
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
	if (cell == nil || cell.editMode) {
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
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [_allMedia count];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * MVLCMovieListTableCellIdentifier = @"MVLCMovieListTableCellIdentifier";
	MVLCMovieTableViewCell * cell = (MVLCMovieTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MVLCMovieListTableCellIdentifier];
	if (cell == nil) {
		cell = [MVLCMovieTableViewCell cellWithReuseIdentifier:MVLCMovieListTableCellIdentifier];
	}
    MLFile * file = [_allMedia objectAtIndex:[indexPath row]];
	cell.file = file;
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	MVLCMovieTableViewCell * movieCell = (MVLCMovieTableViewCell *)cell;
	[movieCell setEven:([indexPath row]%2 == 0)];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MLFile * file = [_allMedia objectAtIndex:[indexPath row]];
	MVLCMovieViewController * movieViewController = [[MVLCMovieViewController alloc] init];
	movieViewController.file = file;
	[self.navigationController pushViewController:movieViewController animated:YES];
	//				[movieViewController release]; // FIXME: VLCKit bug
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && tableView == _tableView) {
        [self deleteFile:[_allMedia objectAtIndex:[indexPath row]]];
    }
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
//				[movieViewController release]; // FIXME: VLCKit bug
			}
		}
	}
}
@end

@implementation MVLCMovieListViewController (Private)
- (UIView *)_animatedView {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return self.view.window;
	} else {
		return nil; // No zooming animation on the iPhone / iPod
	}
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
			_gridView.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCMovieListBackgroundPortrait.png"]];
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			_gridView.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MVLCMovieListBackgroundLandscape.png"]];
			break;
	}
}

- (void)_setEditMode:(BOOL)editMode {
	[_tableView setEditing:editMode animated:YES];
    if (_gridView) {
        for (NSUInteger i = 0; i < [_allMedia count]; i++) {
            [(MVLCMovieGridViewCell *)[_gridView cellForItemAtIndex:i] setEditMode:editMode];
        }
    }
	if (editMode) {
		self.editBarButtonItem.style = UIBarButtonItemStyleDone;
		self.editBarButtonItem.title = @"Done";
	} else {
		self.editBarButtonItem.style = UIBarButtonItemStylePlain;
		self.editBarButtonItem.title = @"Edit";
	}
}

- (BOOL)_isInEditMode {
	return (self.editBarButtonItem.style == UIBarButtonItemStyleDone);
}
@end
