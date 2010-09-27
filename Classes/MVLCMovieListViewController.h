//
//  MVLCMovieListViewController.h
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "MVLCNoMediaViewController.h"
#import <MediaLibraryKit/MLFile.h>

@interface MVLCMovieListViewController : UIViewController <AQGridViewDataSource, AQGridViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	AQGridView *      _gridView;  // Used on the iPad
	UITableView *     _tableView; // Used on the iPhone / iPod
	NSMutableArray *  _allMedia;
	CGAffineTransform _lastTransform;
	MVLCNoMediaViewController * _noMediaViewController;
	UIBarButtonItem * _editBarButtonItem;
}
@property (nonatomic, retain) IBOutlet UIBarButtonItem * editBarButtonItem;
- (IBAction)showAboutScreen:(id)sender;
- (IBAction)toggleEditMode:(id)sender;
- (void)reloadMedia;
- (void)deleteFile:(MLFile *)file;
@end
